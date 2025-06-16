//
//  BluetoothManager.swift
//  ecg
//
//  Created by insung on 4/14/25.
//

import Foundation
import CoreBluetooth
import SwiftUICore
import Combine

enum BluetoothEvent {
    case deviceStatus(Data)
    case waveform(Data)
}

enum BluetoothState {
    case notConnection
    case connecting
    case connected
    case failed
    case disconnected
}

class BluetoothManager: NSObject, ObservableObject {
    static let shared = BluetoothManager()
    
    private var centralManager: CBCentralManager!
    private var writeCharacteristic: CBCharacteristic?

    @EnvironmentObject var router: Router
    @Published var discoveredDevices: [CBPeripheral] = []
    @Published var connectedDevice: CBPeripheral?
    @Published var bluetoothState: BluetoothState = .notConnection
    
    let eventPublisher = PassthroughSubject<BluetoothEvent, Never>()
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    // 스캔 시작
    func startScan() {
        discoveredDevices = []
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }

    // 스캔 멈춤
    func stopScan() {
        centralManager.stopScan()
    }

    // 연결
    func connect(to peripheral: CBPeripheral) {
        bluetoothState = .connecting
        self.centralManager.connect(peripheral, options: nil)
    }
    
    // 연결 해제
    func disconnect() {
        if let device = connectedDevice {
            centralManager.cancelPeripheralConnection(device)
            connectedDevice = nil
            bluetoothState = .notConnection
        }
    }
    
    /// 주어진 데이터에 checksum 및 종료 바이트 추가 후 전송
    func sendCommand(command: UInt8, with baseData: [UInt8] = []) {
        print("sendCommand : \(command)")
        
        var packet = baseData
        
        // 헤더
        packet.insert(command, at: 0)
        
        // 헤더만 있을 경우 제외
        if (packet.count != 1) {
            // 체크섬
            let checksum = calculateChecksum(for: packet)
            packet.append(checksum)
        }
        
        // 테일
        packet.append(Constants.Bluetooth.FOOTER)

        send(packet: packet)
    }
    
    // 체크섬 계산
    private func calculateChecksum(for data: [UInt8]) -> UInt8 {
        let sum = data.reduce(0) { $0 + UInt16($1) }
        return UInt8(sum & 0x7F)
    }

    
    // 데이터 송신
    func send(packet: [UInt8]) {
        guard let peripheral = connectedDevice,
              let characteristic = writeCharacteristic else { return }

        print("🛜 packet 전송 : \(packet)")
        let data = Data(packet)
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }
}

// MARK: - CBCentralManagerDelegate
extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state != .poweredOn {
            print("Bluetooth is not available")
        } else {
            print("Bluetooth is ready")
        }
    }

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        
        guard let name = peripheral.name else {
            return
        }
        
        if (name.hasDeviceCode()) {
            if discoveredDevices.contains(peripheral) == false {
                discoveredDevices.append(peripheral)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("✅ 연결 성공: \(peripheral.name ?? "Unknown")")
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        
        bluetoothState = .connected
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.connectedDevice = peripheral
            PopupManager.shared.hideLoading()
        })
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("❌ 연결 실패: \(error?.localizedDescription ?? "unknown error")")
        connectedDevice = nil
        bluetoothState = .failed
        PopupManager.shared.hideLoading()
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, timestamp: CFAbsoluteTime, isReconnecting: Bool, error: (any Error)?) {
        print("🍎 연결 끊김: \(error?.localizedDescription ?? "unknown error")")
        bluetoothState = .disconnected
        connectedDevice = nil
    }
}

// MARK: - CBPeripheralDelegate
extension BluetoothManager: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("❌ 서비스 탐색 실패: \(error.localizedDescription)")
            return
        }

        guard let services = peripheral.services else { return }

        for service in services {
            print("🔍 발견된 서비스: \(service.uuid)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            
            // 읽기
            if characteristic.uuid == CBUUID(string: "FFF1") {
                peripheral.setNotifyValue(true, for: characteristic)
            }
            
            // 쓰기
            if characteristic.uuid == CBUUID(string: "FFF2") {
                self.writeCharacteristic = characteristic
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        guard let value = characteristic.value else { return }
        
        if let data = characteristic.value {
            let hexString = data.map { String(format: "%02X", $0) }.joined(separator: " ")
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "mm:ss:SSSS"
            dateFormatter.string(from: .now)
            print("🔢 \(dateFormatter.string(from: .now)) HEX: \(hexString)")
        }
        
        if let firstByte = value.first {
            switch firstByte {
            case Constants.Bluetooth.RECEIVE_VERSION:
                eventPublisher.send(.deviceStatus(value))
//            case Constants.Bluetooth.RECEIVE_WAVEFORM:
//                eventPublisher.send(.waveform(value))
            default:
                eventPublisher.send(.waveform(value))
//                print("알 수 없는 데이터 타입: \(firstByte)")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("❌ 데이터 전송 실패: \(error.localizedDescription)")
        } else {
            print("✅ 데이터 전송 성공 to characteristic")
        }
    }
}
