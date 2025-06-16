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
    let leadType: LeadType
    let isLead1Status: Bool
    let isLead2Status: Bool
    let isHeartbeatDetected: Bool
    let batteryStatus: BatteryStatus
    let timestamp: Date
    
    var description: String {
            """
            🕒 Timestamp: \(timestamp)
            📟 Waveform HeartRate: \(heartRate) Lead1: \(lead1) Lead2: \(lead2) ArrhythmiaCode: \(arrhythmiaCode) ModuleType: \(moduleType) LeadType: \(leadType) Lead1Status: \(isLead1Status) Lead2Status: \(isLead2Status) isHeartbeatDetected: \(isHeartbeatDetected) Battery Status: \(batteryStatus.rawValue)
            """
    }
}

class WaveformViewModel: ObservableObject {
    @Published var waveforms: [Waveform] = []
    @Published var triggerNavigation = false
    
    @Published var heartRate: Int = 0
    @Published var leadType: LeadType = .one
    @Published var isLead1Connected: Bool = false
    @Published var isLead2Connected: Bool = false
    @Published var batteryStatus: BatteryStatus = .unknown
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
                    DispatchQueue.global(qos: .userInitiated).async {
                        self?.parseReceivedData(data)
                    }
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

        // Checksum 검증 (1~10 byte 합 & 0x7F)
        let checksum = packet[10]
        let sum = packet[0..<10].reduce(0, { $0 &+ $1 })
        let expectedChecksum = UInt8(sum & 0x7F)
        guard checksum == expectedChecksum else {
            print("Checksum mismatch : \(checksum), \(expectedChecksum)")
            return nil
        }

        let hrLow = packet[1]
        let arrhythmia = packet[8]
        let status = packet[9]

        // Byte 9: bit 7, bit 6 → 심박수 상위 2비트
        let heartRateHighBits = (packet[8] >> 6) & 0b11 // 상위 2비트 추출

        // 최종 심박수 계산
        let heartRate = (Int(heartRateHighBits) << 7) | hrLow.lowerBits(7)
        
        // A 비트 (Lead 2 사용 여부)
        let moduleType = status.isBitSet(at: 6)
        
        // 유도 측정 방식: L 비트 (bit 5) - 0이면 1유도, 1이면 6유도
        let leadType = LeadType(from: status.isBitSet(at: 5) == true ? 1 : 0)
        
        let lead1 = calculateLead(from: packet, startIndex: 2)
        let lead2 = calculateLead(from: packet, startIndex: 5)
        
        return Waveform(
            heartRate: heartRate,
            lead1: lead1,
            lead2: lead2,
            arrhythmiaCode: arrhythmia,
            moduleType: moduleType,
            leadType: leadType,
            isLead1Status: status.isBitSet(at: 4),
            isLead2Status: status.isBitSet(at: 3),
            isHeartbeatDetected: status.isBitSet(at: 2),
            batteryStatus: BatteryStatus(from: status.lowerBits(2)),
            timestamp: .now
        )
    }
    

    // Lead 데이터 계산
    func calculateLead(from packet: [UInt8], startIndex: Int) -> Int {

        let high = packet[startIndex].lowerBits(7)
        let mid  = packet[startIndex + 1].lowerBits(7)
        let low  = packet[startIndex + 2].lowerBits(7)
        
        let raw = (high << 14) + (mid << 7) + low
        return raw - 0x100000
    }
    
    // 수신 데이터 파싱
    func parseReceivedData(_ data: Data) {
        var bytes = [UInt8](data)
        let header = Constants.Bluetooth.RECEIVE_WAVEFORM
        let footer = Constants.Bluetooth.FOOTER
        let packetLength = Constants.Bluetooth.WAVEFORM_COUNT

        while bytes.count >= packetLength {
            // 헤더 위치 탐색
            if let startIndex = bytes.firstIndex(of: header),
               startIndex + packetLength <= bytes.count {

                let potentialPacket = Array(bytes[startIndex..<startIndex + packetLength])

                // 패킷의 마지막 바이트가 footer인지 확인
                if potentialPacket.last == footer {
                    if let parsed = parseSingleWaveform(potentialPacket) {
                        DispatchQueue.main.async {
                            self.waveforms.append(parsed)

                            // 오래된 데이터 제거
                            if self.waveforms.count > self.maxWaveformCount {
                                self.waveforms.removeFirst(self.waveforms.count - self.maxWaveformCount)
                            }

                            // 상태 업데이트
                            self.heartRate = parsed.heartRate
                            self.isLead1Connected = parsed.isLead1Status
                            self.isLead2Connected = parsed.isLead2Status
                            self.batteryStatus = parsed.batteryStatus

                            // 트리거 조건
                            let shouldTrigger: Bool = {
                                switch parsed.leadType {
                                case .one:
                                    return parsed.isLead1Status
                                case .six:
                                    return parsed.isLead1Status && parsed.isLead2Status
                                }
                            }()

                            if shouldTrigger && !self.hasTriggeredNavigation && !self.hasMovedToNextPage {
                                self.hasTriggeredNavigation = true
                                self.triggerNavigation = true
                            }
                        }

                        // 사용한 바이트 제거
                        bytes.removeSubrange(startIndex..<startIndex + packetLength)
                    } else {
                        // 파싱 실패한 경우 해당 헤더부터 다음 바이트까지 제거하고 재시도
                        bytes.removeFirst(startIndex + 1)
                    }
                } else {
                    // 헤더는 있으나 유효한 패킷이 아닌 경우 건너뜀
                    bytes.removeFirst(startIndex + 1)
                }
            } else {
                // 헤더 자체가 없거나 남은 데이터가 부족할 경우 루프 종료
                break
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

extension WaveformViewModel {
    func startMeasurement(type: LeadType) {
        waveforms.removeAll()
        BluetoothManager.shared
            .sendCommand(
                command: type == .one ? Constants.Bluetooth.MEASURE_START_1 : Constants.Bluetooth.MEASURE_START_6
            )
        print("📡 측정 시작 커맨드 전송됨")
    }
    
    func stopMeasurement() {
        BluetoothManager.shared
            .sendCommand(command: Constants.Bluetooth.MEASURE_STOP)
        print("📡 측정 종료 커맨드 전송됨")
    }
}
