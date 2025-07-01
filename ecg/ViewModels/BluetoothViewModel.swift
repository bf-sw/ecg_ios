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
}
