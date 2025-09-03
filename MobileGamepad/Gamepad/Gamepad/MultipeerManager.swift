//
//  MultipeerManager.swift
//  Gamepad
//
//  Created by Nick Watts on 8/31/25.
//

import Foundation
import MultipeerConnectivity
import SwiftUI
import UIKit
import Combine

// MARK: - Multipeer Connectivity (Sender)
// iOS-side manager that both advertises and browses to quickly form sessions among nearby peers.
// It sends key strings like "<LABEL>_(DOWN|UP)" to all connected peers.
// It also computes a stable theme index based on sorted peer display names for consistent theming.
class MultipeerManager: NSObject, ObservableObject {
    private let serviceType = "gamepad-input"
    
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    private let session: MCSession
    private let advertiser: MCNearbyServiceAdvertiser
    private let browser: MCNearbyServiceBrowser
    
    // UI state for theming and connection status.
    @Published var connectedPeersCount = 0
    @Published var myThemeIndex: Int = 1  // 1–4
    
    override init() {
        // Encryption required protects traffic on local network.
        session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: serviceType)
        browser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)
        
        super.init()
        
        session.delegate = self
        advertiser.delegate = self
        browser.delegate = self
        
        // Start both advertising and browsing to converge quickly without user prompts.
        advertiser.startAdvertisingPeer()
        browser.startBrowsingForPeers()
        
        updateThemeIndex()
    }
    
    deinit {
        advertiser.stopAdvertisingPeer()
        browser.stopBrowsingForPeers()
    }
    
    // MARK: Theme Indexing
    // Computes a stable index [1...4] based on the sorted display names of connected peers + self.
    // Rationale: Ensures each device gets a consistent theme without coordination.
    private func updateThemeIndex() {
        let allPeers = session.connectedPeers + [myPeerId]
        let sorted = allPeers.map { $0.displayName }.sorted()
        if let myIndex = sorted.firstIndex(of: myPeerId.displayName) {
            DispatchQueue.main.async {
                self.myThemeIndex = min(myIndex + 1, 4) // Clamp to 1–4
            }
        }
    }
    
    // MARK: Sending
    // Sends a single UTF-8 string to all connected peers. Skips if no peers are connected.
    // Reliability: Uses `.reliable` to ensure ordering and delivery for DOWN/UP semantics.
    func send(_ key: String) {
        guard !session.connectedPeers.isEmpty else {
            print("No peers connected yet. Skipping send: \(key)")
            return
        }
        if let data = key.data(using: .utf8) {
            do {
                try session.send(data, toPeers: session.connectedPeers, with: .reliable)
            } catch {
                print("Failed to send key \(key): \(error)")
            }
        }
    }
}

// MARK: - MCSessionDelegate
extension MultipeerManager: MCSessionDelegate {
    // MARK: Peer State Changes
    // Updates connection count and recomputes theme index on main thread.
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .notConnected:
            print("Peer \(peerID.displayName) not connected")
        case .connecting:
            print("Peer \(peerID.displayName) connecting")
        case .connected:
            print("Peer \(peerID.displayName) connected ✅")
        @unknown default:
            break
        }
        DispatchQueue.main.async {
            self.connectedPeersCount = session.connectedPeers.count
            self.updateThemeIndex()
        }
    }
    
    // Data/stream/resource not used by sender.
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

// MARK: - MCNearbyServiceAdvertiserDelegate
extension MultipeerManager: MCNearbyServiceAdvertiserDelegate {
    // Accept invitations automatically for zero-friction setup.
    // Consider adding UI confirmation for public networks.
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
}

// MARK: - MCNearbyServiceBrowserDelegate
extension MultipeerManager: MCNearbyServiceBrowserDelegate {
    // Proactively invites discovered peers to form a session quickly.
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("Found peer: \(peerID.displayName), sending invite...")
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Lost peer: \(peerID.displayName)")
    }
}

