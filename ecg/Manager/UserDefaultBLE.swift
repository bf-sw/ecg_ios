//
//  UserDefaultBLE.swift
//  ecg
//
//  Created by insung on 6/30/25.
//


import Foundation

class UserDefaultBLE {
    
    private static let connectedDeviceKey = "ConnectedUUID"

    // 연결된 기기 저장
    static func saveConnectedDevice(_ uuid: UUID) {
        UserDefaults.standard.set(uuid.uuidString, forKey: connectedDeviceKey)
    }

    // 연결된 기기 호출
    static func loadConnectedUUID() -> UUID? {
        if let uuidString = UserDefaults.standard.string(forKey: connectedDeviceKey) {
            return UUID(uuidString: uuidString)
        }
        return nil
    }

    // 연결된 기기 삭제
    static func clearConnectedDevice() {
        UserDefaults.standard.removeObject(forKey: connectedDeviceKey)
    }
}
