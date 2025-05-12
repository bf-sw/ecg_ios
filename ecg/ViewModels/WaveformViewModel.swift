//
//  WaveformViewModel.swift
//  ecg
//
//  Created by insung on 4/29/25.
//

import Foundation
import Combine

struct Waveform {
    let heartRate: Int
    let lead1: Int
    let lead2: Int
    let arrhythmiaCode: UInt8
    let moduleType: Bool
    let isLead1Status: Bool
    let isLead2Status: Bool
    let isHeartbeatDetected: Bool
    let batteryStatus: BatteryStatus
    let timestamp: Date
    
    var description: String {
            """
            🕒 Timestamp: \(timestamp)
            📟 Waveform HeartRate: \(heartRate) Lead1: \(lead1) Lead2: \(lead2) ArrhythmiaCode: \(arrhythmiaCode) ModuleType: \(moduleType) Lead1Status: \(isLead1Status) Lead2Status: \(isLead2Status) isHeartbeatDetected: \(isHeartbeatDetected) Battery Status: \(batteryStatus.rawValue)
            """
    }
}

class WaveformViewModel: ObservableObject {
    @Published var waveforms: [Waveform] = []
    @Published var triggerNavigation = false
    
    @Published var heartRate: Int = 0
    @Published var isLead1Connected: Bool = false
    @Published var isLead2Connected: Bool = false
    @Published var selectedMeasure: Int = 0
    @Published var measureDate: Date = .now
    
    private let maxWaveformCount = 100 // ✅ 유지할 최대 개수
    private var cancellables = Set<AnyCancellable>()
    private var hasTriggeredNavigation = false
    private var hasMovedToNextPage = false

    
    init() {
        BluetoothManager.shared.eventPublisher
            .sink { [weak self] event in
                if case .waveform(let data) = event {
                    self?.parseReceivedData(data)
                }
            }
            .store(in: &cancellables)
    }

    // 데이터 파싱
    func parseSingleWaveform(_ packet: [UInt8]) -> Waveform? {
        
        let header = packet.first
        let footer = packet.last
        guard packet.count == Constants.Bluetooth.WAVEFORM_COUNT,
              header == Constants.Bluetooth.RECEIVE_WAVEFORM,
              footer == Constants.Bluetooth.FOOTER else {
            print("❌ 헤더/푸터 오류")
            return nil
        }
        
        //        // Checksum 검증 (1~10 byte 합 & 0x7F)
        //        let checksum = packet[10]
        //        let expectedChecksum = packet[1..<10].reduce(0, +) & 0x7F
        //        guard checksum == expectedChecksum else {
        //            print("Checksum mismatch : \(checksum), \(expectedCh)")
        //            return nil
        //        }

        let hrLow = packet[1]
        let lead1High = packet[2]
        let lead1Middle = packet[3]
        let lead1Low = packet[4]
        let lead2High = packet[5]
        let lead2Middle = packet[6]
        let lead2Low = packet[7]
        let arrhythmia = packet[8]
        let status = packet[9]

        // 심박수 = 상위 1비트(H 비트) + hrLow (7비트)
        let heartRateHigh = status.isBitSet(at: 7) ? 1 : 0
        let heartRate = (heartRateHigh << 7) | hrLow.lowerBits(7)
        
        // A 비트 (Lead 2 사용 여부)
        let moduleType = status.isBitSet(at: 6)
        
        let lead1 = (Int(lead1High.lowerBits(7)) << 14) | (Int(lead1Middle.lowerBits(7)) << 7) | lead1Low.lowerBits(7)
        let lead2 = (Int(lead2High.lowerBits(7)) << 14) | (Int(lead2Middle.lowerBits(7)) << 7) | lead2Low.lowerBits(7)

        return Waveform(
            heartRate: heartRate,
            lead1: lead1,
            lead2: lead2,
            arrhythmiaCode: arrhythmia,
            moduleType: moduleType,
            isLead1Status: status.isBitSet(at: 4),
            isLead2Status: status.isBitSet(at: 3),
            isHeartbeatDetected: status.isBitSet(at: 2),
            batteryStatus: BatteryStatus(from: status.lowerBits(2)),
            timestamp: .now
        )
    }
    
    func parseReceivedData(_ data: Data) {
        var buffer: [UInt8] = []
        
        for byte in data {
            if byte == Constants.Bluetooth.RECEIVE_WAVEFORM {
                buffer.removeAll()
                buffer.append(byte)
            } else {
                buffer.append(byte)
                if byte == Constants.Bluetooth.FOOTER &&
                    buffer.count == Constants.Bluetooth.WAVEFORM_COUNT {
                    if let parsed = parseSingleWaveform(buffer) {
                        print("parseReceivedData: \(parsed)")
                        DispatchQueue.main.async {
                            self.waveforms.append(parsed)
                            
                            // ✅ 가장 오래된 데이터 제거
                            if self.waveforms.count > self.maxWaveformCount {
                                self.waveforms
                                    .removeFirst(
                                        self.waveforms.count - self.maxWaveformCount
                                    )
                            }
                            // ✅ 상태값 추출해서 퍼블리시
                            self.heartRate = parsed.heartRate
                            self.isLead1Connected = parsed.isLead1Status
                            self.isLead2Connected = parsed.isLead2Status
                            
                            // ✅ 조건 분기 트리거 로직
                            let shouldTrigger: Bool = {
                                switch self.selectedMeasure {
                                case 0:
                                    return parsed.isLead1Status
                                case 1:
                                    return parsed.isLead1Status && parsed.isLead2Status
                                default:
                                    return false
                                }
                            }()

                            if shouldTrigger == true,
                               self.hasTriggeredNavigation == false,
                               self.hasMovedToNextPage == false {
                                self.hasTriggeredNavigation = true
                                self.triggerNavigation = true
                            }
                        }
                    }
                    buffer.removeAll()
                } else if buffer.count > 12 {
                    buffer.removeAll()
                }
            }
        }
    }
    
    func markNavigationComplete() {
        hasMovedToNextPage = true
        hasTriggeredNavigation = false
        triggerNavigation = false
    }

    
    // 필요 시 외부에서 다시 리셋 가능
    func resetForNextSession() {
        hasMovedToNextPage = false
    }

}
