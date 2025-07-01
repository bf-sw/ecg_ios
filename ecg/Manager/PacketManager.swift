//
//  PacketManager.swift
//  ecg
//
//  Created by insung on 6/30/25.
//

import Foundation

final class PacketManager {
    
    static let shared = PacketManager()
    
    private let manager = BluetoothManager.shared
 
    // 디바이스 시간 설정
    func setDeviceTime() {
        let now = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: now) % 100
        let month = calendar.component(.month, from: now)
        let day = calendar.component(.day, from: now)
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)

        let baseData: [UInt8] = [
            UInt8(year),
            UInt8(month),
            UInt8(day),
            UInt8(hour),
            UInt8(minute)
        ]

        manager.sendCommand(
            Constants.Bluetooth.VERSION,
            with: baseData)
    }
    
    // 저장된 Event 검색
    func searchEvent() {
        manager.sendCommand(Constants.Bluetooth.SEND_EVENT)
    }
    
    
    // 측정 시작
    func startMeasurement(from type: LeadType) {
        manager.sendCommand(type == .one ? Constants.Bluetooth.MEASURE_START_1 : Constants.Bluetooth.MEASURE_START_6)
    }
    
    // 측정 종료
    func stopMeasurement() {
        manager.sendCommand(Constants.Bluetooth.MEASURE_STOP)
    }
    
    // 이벤트 삭제
    func deleteEvent(from num: Int) {
        let eventByte = UInt8(num & 0x7F)
        manager.sendCommand(Constants.Bluetooth.EVENT_DELETE, with: [eventByte])
    }
    
    // 이벤트 삭제
    func downloadEvent() {
        manager.sendCommand(Constants.Bluetooth.MEASURE_STOP)
    }
}
