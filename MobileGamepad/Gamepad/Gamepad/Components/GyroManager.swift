//
//  GyroManager.swift
//  
//
//  Created by Nick Watts on 9/2/25.
//

import CoreMotion
import Combine

@available(iOS 26.0, *)
final class GyroManager: ObservableObject {
    private let motionManager = CMMotionManager()
    private var timer: Timer?
    
    @Published var isActive = false
    private var isLeftPressed = false
    private var isRightPressed = false
    
    private var yawOffset: Double = 0.0
    
    // MARK: Start/Stop Motion
    // Begins deviceMotion updates and periodically evaluates yaw to generate LEFT/RIGHT DOWN/UP events.
    // Mapping contract: We emit "<mapping.right>_DOWN" when yaw goes left (negative) and vice versa.
    // This inversion matches the intended game control orientation; adjust if your UI differs.
    func startGyroUpdates(mapping: KeyMapping, send: @escaping (String) -> Void) {
        guard !motionManager.isDeviceMotionActive else { return }
        isActive = true
        
        motionManager.deviceMotionUpdateInterval = 0.1
        motionManager.startDeviceMotionUpdates(using: .xArbitraryCorrectedZVertical)
        
        // Timer on main run loop polls motion data and computes threshold crossings.
        // Consider using OperationQueue/handler-based updates if you need tighter timing.
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self, let data = motionManager.deviceMotion else { return }
            
            // Use yaw instead of roll; subtract baseline to allow recentering during play.
            let yaw = data.attitude.yaw - yawOffset
            
            // Threshold tuned to avoid jitter; adjust for sensitivity.
            let threshold = 0.08
            
            if yaw < -threshold {
                if !isLeftPressed {
                    send("\(mapping.right)_DOWN")
                    isLeftPressed = true
                }
            } else if yaw > threshold {
                if !isRightPressed {
                    send("\(mapping.left)_DOWN")
                    isRightPressed = true
                }
            } else {
                // Neutral -> release both
                if isLeftPressed {
                    send("\(mapping.right)_UP")
                    isLeftPressed = false
                }
                if isRightPressed {
                    send("\(mapping.left)_UP")
                    isRightPressed = false
                }
            }
        }
    }
    
    // Stops motion updates and ensures any pressed keys are released.
    func stopGyroUpdates(mapping: KeyMapping, send: @escaping (String) -> Void) {
        motionManager.stopDeviceMotionUpdates()
        timer?.invalidate()
        timer = nil
        isActive = false
        
        if isLeftPressed {
            send("\(mapping.left)_UP")
            isLeftPressed = false
        }
        if isRightPressed {
            send("\(mapping.right)_UP")
            isRightPressed = false
        }
    }
    
    // MARK: Recenter
    // Captures current yaw as the new baseline. Subsequent readings are relative to this offset.
    func recenter() {
        if let data = motionManager.deviceMotion {
            yawOffset = data.attitude.yaw
        }
    }
}

