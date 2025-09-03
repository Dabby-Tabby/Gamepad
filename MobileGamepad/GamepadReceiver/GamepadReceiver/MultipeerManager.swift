//
//  MultipeerManager.swift
//  GamepadReceiver
//
//  Created by Nick Watts on 8/31/25.
//

import Foundation
import MultipeerConnectivity
import Combine

// MARK: - Multipeer Connectivity (Receiver)
// Hosts an MCNearbyServiceAdvertiser and accepts invitations from senders (iOS gamepads).
// Publishes incoming "<KEY>_(DOWN|UP)" messages via lastKeyPressed.
// Threading: MCSession delegate callbacks arrive on a private queue; UI updates are dispatched to main.
class MultipeerManager: NSObject, ObservableObject {
    private let serviceType = "gamepad-input"
    
    private let myPeerId = MCPeerID(displayName: Host.current().localizedName ?? "Mac")
    private let session: MCSession
    private let advertiser: MCNearbyServiceAdvertiser
    
    // Latest key event received (nil if nothing yet). Observed by ContentView.
    @Published var lastKeyPressed: String? = nil

    override init() {
        // Encryption required protects traffic on local network.
        session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: serviceType)
        
        super.init()
        
        session.delegate = self
        advertiser.delegate = self
        
        // Start listening for invitations from nearby peers.
        advertiser.startAdvertisingPeer()
    }
    
    deinit {
        advertiser.stopAdvertisingPeer()
    }
}

// MARK: - MCSessionDelegate
extension MultipeerManager: MCSessionDelegate {
    // MARK: Peer State Changes
    // Useful for debugging/telemetry; does not alter behavior.
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("Peer \(peerID.displayName) changed state: \(state.rawValue)")
    }
    
    // MARK: Data Handling
    // Receives UTF-8 strings like "A_DOWN" / "A_UP" and publishes to UI on main thread.
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let key = String(data: data, encoding: .utf8) {
            DispatchQueue.main.async {
                self.lastKeyPressed = key
            }
        }
    }
    
    // Required stubs (streams/resources not used in this app).
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

// MARK: - MCNearbyServiceAdvertiserDelegate
extension MultipeerManager: MCNearbyServiceAdvertiserDelegate {
    // Accept all invitations automatically to minimize friction.
    // Security: In a real app, consider prompting the user or validating peer identity.
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
}

