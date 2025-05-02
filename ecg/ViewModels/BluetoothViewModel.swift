//
//  BluetoothViewModel.swift
//  ecg
//
//  Created by insung on 4/14/25.
//

import Foundation
import CoreBluetooth
import Combine
import SwiftUICore

class BluetoothViewModel: ObservableObject {

    @Published var isLoading = false
    
    @Published var devices: [CBPeripheral] = []
    @Published var connectedDevice: CBPeripheral?

    private var bluetoothManager = BluetoothManager.shared
    
    init() {
        bluetoothManager.$discoveredDevices.assign(to: &$devices)
        bluetoothManager.$connectedDevice.assign(to: &$connectedDevice)
    }
    
    func resetDevices() {
        devices.removeAll()
    }

    func scanDevices() {
        isLoading = true
        bluetoothManager.startScan()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.bluetoothManager.stopScan()
            self.isLoading = false
        }
    }

    func connectToDevice(_ device: CBPeripheral) {
        bluetoothManager.connect(to: device)
    }
    
    func disconnect() {
        bluetoothManager.disconnect()
    }
    
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

        bluetoothManager.sendCommand(
            command: Constants.Bluetooth.VERSION,
            with: baseData)
    }
}
