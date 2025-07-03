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
    case savedEvent(Data)
    case emptyEvent(Data)
    case downloadEvent(Data)
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

    private var reconnectTimeoutTimer: Timer?
    private let reconnectTimeoutInterval: TimeInterval = 5.0

    @EnvironmentObject var router: Router
    @Published var discoveredDevices: [CBPeripheral] = []
    @Published var connectedDevice: CBPeripheral?
    @Published var bluetoothState: BluetoothState = .notConnection

    let eventPublisher = PassthroughSubject<BluetoothEvent, Never>()

    // --- 조각 수신 누적 처리
    private var pendingBytes: [UInt8] = []
    private let footer: UInt8 = Constants.Bluetooth.FOOTER
    private let headerBytes: [UInt8] = [
        Constants.Bluetooth.RECEIVE_EVENT_DOWNLOAD,
        Constants.Bluetooth.RECEIVE_VERSION,
        Constants.Bluetooth.RECEIVE_EVENT,
        Constants.Bluetooth.EMPTY_EVENT
    ]

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func startScan() {
        discoveredDevices = []
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }

    func stopScan() {
        centralManager.stopScan()
    }

    func connect(to peripheral: CBPeripheral) {
        bluetoothState = .connecting
        self.centralManager.connect(peripheral, options: nil)
    }

    func disconnect() {
        if let device = connectedDevice {
            centralManager.cancelPeripheralConnection(device)
            connectedDevice = nil
            bluetoothState = .notConnection
        }
    }

    private func startReconnectTimeoutTimer(for peripheral: CBPeripheral) {
        reconnectTimeoutTimer?.invalidate()
        reconnectTimeoutTimer = Timer.scheduledTimer(withTimeInterval: reconnectTimeoutInterval, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            print("⏰ 자동 재연결 타임아웃 발생")
            self.centralManager.cancelPeripheralConnection(peripheral)
            self.bluetoothState = .failed
            PopupManager.shared.hideLoading()

            ToastManager.shared.show(message: "자동 연결에 실패했습니다.\n다시 시도해 주세요.")
            UserDefaultBLE.clearConnectedDevice()
        }
    }

    // 전송 큐 처리
    func processNextCommandIfNeeded() {
        guard !PacketManager.shared.isSending,
              let packet = PacketManager.shared.dequeueNextPacket(),
              let peripheral = connectedDevice,
              let characteristic = writeCharacteristic else { return }

        PacketManager.shared.setIsSending(true)

        let data = Data(packet.bytes)
        peripheral.writeValue(data, for: characteristic, type: .withResponse)

        print("🛜 전송: \(packet.bytes.map { String(format: "0x%02X", $0) }.joined(separator: " "))")
    }

    func onWriteResponse(error: Error?) {
        if let error = error {
            print("❌ 전송 실패: \(error.localizedDescription)")
        } else {
            print("✅ 전송 성공")
        }
        PacketManager.shared.onWriteComplete()
    }

    // 수신 데이터 누적 및 파싱
    private func parsePendingBytes() {
        while let start = pendingBytes.firstIndex(where: { headerBytes.contains($0) }),
              let end = pendingBytes[start...].firstIndex(of: footer),
              end > start {

            let packet = Array(pendingBytes[start...end])
            guard packet.count >= 3 else { break }

            let header = packet[0]

            switch header {
            case Constants.Bluetooth.RECEIVE_EVENT_DOWNLOAD:
                PacketManager.shared.handleDownloadResponse(Data(packet))
            case Constants.Bluetooth.RECEIVE_VERSION:
                eventPublisher.send(.deviceStatus(Data(packet)))
            case Constants.Bluetooth.RECEIVE_EVENT:
                eventPublisher.send(.savedEvent(Data(packet)))
            case Constants.Bluetooth.EMPTY_EVENT:
                eventPublisher.send(.emptyEvent(Data(packet)))
            case Constants.Bluetooth.RECEIVE_WAVEFORM:
                eventPublisher.send(.waveform(Data(packet)))
            default:
                break
            }

            pendingBytes.removeSubrange(start...end)
        }

        if pendingBytes.count > 2048 {
            pendingBytes.removeAll()
        }
    }
}

// MARK: - CBCentralManagerDelegate
extension BluetoothManager: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state != .poweredOn {
            print("Bluetooth is not available")
        } else {
            print("Bluetooth is ready")

            if let uuid = UserDefaultBLE.loadConnectedUUID(),
               let peripheral = central.retrievePeripherals(withIdentifiers: [uuid]).first {
                print("🔁 최근 연결 기기 재연결 시도: \(peripheral.name ?? "Unknown")")
                connect(to: peripheral)
                startReconnectTimeoutTimer(for: peripheral)
            } else {
                startScan()
            }
        }
    }

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any],
                        rssi RSSI: NSNumber) {

        guard let name = peripheral.name, name.hasDeviceCode() else { return }

        if discoveredDevices.contains(peripheral) == false {
            discoveredDevices.append(peripheral)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("✅ 연결 성공: \(peripheral.name ?? "Unknown")")
        peripheral.delegate = self
        peripheral.discoverServices(nil)

        reconnectTimeoutTimer?.invalidate()

        bluetoothState = .connected
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.connectedDevice = peripheral
            PopupManager.shared.hideLoading()
            PacketManager.shared.setDeviceTime()
        }

        UserDefaultBLE.saveConnectedDevice(peripheral.identifier)
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
            if characteristic.uuid == CBUUID(string: "FFF1") {
                peripheral.setNotifyValue(true, for: characteristic)
            }
            if characteristic.uuid == CBUUID(string: "FFF2") {
                self.writeCharacteristic = characteristic
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        guard let value = characteristic.value else { return }

        let hexString = value.map { String(format: "%02X", $0) }.joined(separator: " ")
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss:SSSS"
        print("🔢 \(formatter.string(from: .now)) HEX: \(hexString)")

        pendingBytes.append(contentsOf: [UInt8](value))
        parsePendingBytes()
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        onWriteResponse(error: error)
    }
}
