//
//  DeviceStatusViewModel.swift
//  ecg
//
//  Created by insung on 4/23/25.
//

import Foundation
import Combine


enum LeadType: Int {
    case one = 0
    case six = 1
    
    init(from raw: Int) {
        switch raw {
        case 0: self = .one
        case 1: self = .six
        default: self = .one
        }
    }
}

enum BatteryStatus: Int {
    case empty = 0
    case level1 = 1
    case level2 = 2
    case full = 3
    case unknown
    
    init(from raw: Int) {
        switch raw {
        case 0: self = .empty
        case 1: self = .level1
        case 2: self = .level2
        case 3: self = .full
        default: self = .unknown
        }
    }
}

struct DeviceStatus {
    let major: Int
    let minor: Int
    let eventCount: Int
    let isControllerOnly: Bool
    let isCharging: Bool
    let batteryStatus: BatteryStatus
    
    var description: String {
            """
            📟 Device Status
            ├─ Major: \(major)
            ├─ Minor: \(minor)
            ├─ Event Count: \(eventCount)
            ├─ Controller Only: \(isControllerOnly ? "✅ Yes" : "❌ No")
            ├─ Charging: \(isCharging ? "🔌 Charging" : "🔋 Not Charging")
            └─ Battery Status: \(batteryStatus.rawValue)
            """
    }
}

class DeviceStatusViewModel: ObservableObject {
    @Published var deviceStatus: DeviceStatus?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        BluetoothManager.shared.eventPublisher
            .sink { [weak self] event in
                if case .deviceStatus(let data) = event {
                    self?.parseReceivedData(data)
                }
            }
            .store(in: &cancellables)
    }

    // 데이터 파싱
    func parseReceivedData(_ data: Data) {
        print("parseReceivedVersion data : \(data.count)")
        guard data.count >= 7 else {
            print("❌ 데이터 길이 부족")
            return
        }

        let header = data.first
        let footer = data.last
        guard header == Constants.Bluetooth.RECEIVE_VERSION,
              footer == Constants.Bluetooth.FOOTER else {
            print("❌ 헤더/푸터 오류")
            return
        }

        let major = data[1].lowerBits(4)
        let minor = data[2].lowerBits(7)
        let eventCount = data[3].lowerBits(5)

        let statusByte = data[4]
        let isControllerOnly = !statusByte.isBitSet(at: 3)
        let isCharging = statusByte.isBitSet(at: 2)
        // 하위 2비트 마스킹
        let batteryLevel = BatteryStatus(from: statusByte.lowerBits(2))

        let status = DeviceStatus(
            major: major,
            minor: minor,
            eventCount: eventCount,
            isControllerOnly: isControllerOnly,
            isCharging: isCharging,
            batteryStatus: batteryLevel
        )
        
        print("status.description : \(status.description)");

        DispatchQueue.main.async {
            self.deviceStatus = status
        }
    }
    
    
}
