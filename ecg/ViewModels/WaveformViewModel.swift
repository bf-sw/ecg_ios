//
//  WaveformViewModel.swift
//  ecg
//
//  Created by insung on 4/29/25.
//

import Foundation
import Combine

enum GraphType: String {
    case none = "◼︎ electrocardiogram"
    case one = "◼︎ Lead I"
    case two = "◼︎ Lead II"
    case three = "◼︎ Lead III"
    case avr = "◼︎ aVR"
    case avl = "◼︎ aVL"
    case avf = "◼︎ aVF"
}

struct Waveform: Equatable {
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
    
    func calculateLead3() -> Double {
        return Double(lead2) - Double(lead1)
    }
    
    func calculateAVR() -> Double {
        return -(Double(lead1) + Double(lead2))/2
    }
    
    func calculateAVL() -> Double {
        return Double(lead1) - Double(lead2)/2
    }
    
    func calculateAVF() -> Double {
        return Double(lead2) - Double(lead1)/2
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
    @Published var selectedLeadType: LeadType = .one
    @Published var measureDate: Date = .now
    @Published var isMeasurementFinished = false
    
    @Published var lead1Points: [CGPoint] = []
    @Published var lead2Points: [CGPoint] = []
    @Published var lead3Points: [CGPoint] = []
    @Published var avfPoints: [CGPoint] = []
    @Published var avlPoints: [CGPoint] = []
    @Published var avrPoints: [CGPoint] = []

    private let maxCount = 7800
    private let bufferSize = 50
    
    private var pendingBuffer = [CGPoint]()
    private let bufferQueue = DispatchQueue(label: "graph.buffer.queue")

    private var dataIndex: Int = 0
    private var cancellables = Set<AnyCancellable>()
    private var hasTriggeredNavigation = false
    private var hasMovedToNextPage = false
    
    var elapsedTime: Double = 0.0
    private var timer: Timer?
    private let measurementDuration: Double = 30.0
    private let timerInterval: Double = 0.2
    
    
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
        let heartRate = ((Int(heartRateHighBits) << 7) | hrLow.lowerBits(7)) - 1
        
        // A 비트 (Lead 2 사용 여부)
        let moduleType = status.isBitSet(at: 6)
        
        // 유도 측정 방식: L 비트 (bit 5) - 0이면 1유도, 1이면 6유도
        // 사용 안함
//        let leadType = LeadType(from: status.isBitSet(at: 5) == true ? 1 : 0)
        
        let lead1 = calculateLead(from: packet, startIndex: 2)
        let lead2 = calculateLead(from: packet, startIndex: 5)
        
        return Waveform(
            heartRate: heartRate,
            lead1: lead1,
            lead2: lead2,
            arrhythmiaCode: arrhythmia,
            moduleType: moduleType,
            leadType: selectedLeadType,
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
        let mid = packet[startIndex + 1].lowerBits(7)
        let low = packet[startIndex + 2].lowerBits(7)
        
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

                let packet = Array(bytes[startIndex..<startIndex + packetLength])

                // 패킷의 마지막 바이트가 footer인지 확인
                if packet.last == footer {
                    if let parsed = parseSingleWaveform(packet) {
                        DispatchQueue.main.async {
                            self.waveforms.append(parsed)

                            // 오래된 데이터 제거
                            if self.waveforms.count > self.maxCount {
                                self.waveforms.removeFirst(self.waveforms.count - self.maxCount)
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
                                self.startTimer()
                            }
                            
                            if shouldTrigger {
                                self.addGraphPoints(parsed)
                            }
                        }

                        // 사용한 바이트 제거
                        bytes.removeSubrange(startIndex..<startIndex + packetLength)
                    } else {
                        // 파싱 실패한 경우 해당 헤더부터 다음 바이트까지 제거하고 재시도
                        bytes.removeFirst(startIndex + 1)
                    }
                }
            } else {
                // 헤더 자체가 없거나 남은 데이터가 부족할 경우 루프 종료
                break
            }
        }
    }
    
    private func addGraphPoints(_ waveform: Waveform) {
        let x = Double(dataIndex)
        dataIndex += 1

        let points = (
            lead1: CGPoint(x: x, y: Double(waveform.lead1)),
            lead2: CGPoint(x: x, y: Double(waveform.lead2)),
            lead3: CGPoint(x: x, y: waveform.calculateLead3()),
            avf:   CGPoint(x: x, y: waveform.calculateAVF()),
            avl:   CGPoint(x: x, y: waveform.calculateAVL()),
            avr:   CGPoint(x: x, y: waveform.calculateAVR())
        )

        DispatchQueue.main.async {
            self.append(&self.lead1Points, points.lead1)
            self.append(&self.lead2Points, points.lead2)
            self.append(&self.lead3Points, points.lead3)
            self.append(&self.avfPoints,   points.avf)
            self.append(&self.avlPoints,   points.avl)
            self.append(&self.avrPoints,   points.avr)
        }
    }
    
    private func append(_ array: inout [CGPoint], _ point: CGPoint) {
        array.append(point)
        if array.count > maxCount {
            array.removeFirst(array.count - maxCount)
        }
    }
    
    func resetData() {
        waveforms.removeAll()
        lead1Points.removeAll()
        lead2Points.removeAll()
        lead3Points.removeAll()
        avfPoints.removeAll()
        avlPoints.removeAll()
        avrPoints.removeAll()

        dataIndex = 0
        isMeasurementFinished = false
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
    
    func startTimer() {
        elapsedTime = 0
        timer?.invalidate()
        isMeasurementFinished = false
        timer = Timer
            .scheduledTimer(
                withTimeInterval: timerInterval,
                repeats: true
            ) { t in
                self.elapsedTime += self.timerInterval
                if self.elapsedTime >= self.measurementDuration {
                    self.isMeasurementFinished = true
                    self.stopMeasurement()
                }
            }
    }
    
    
    
    func startMeasurement(type: LeadType) {
        waveforms.removeAll()
        BluetoothManager.shared
            .sendCommand(
                command: type == .one ? Constants.Bluetooth.MEASURE_START_1 : Constants.Bluetooth.MEASURE_START_6
            )
        print("📡 측정 시작 커맨드 전송됨")
    }
    
    func stopMeasurement() {
        timer?.invalidate()
        timer = nil
        BluetoothManager.shared
            .sendCommand(command: Constants.Bluetooth.MEASURE_STOP)
        print("📡 측정 종료 커맨드 전송됨")
    }
}

extension WaveformViewModel {
    // 테스트 데이터
    static func previewSample(type: LeadType = .six) -> WaveformViewModel {
            let vm = WaveformViewModel()
            vm.selectedLeadType = type

            for i in 0..<7500 {
                let lead1 = Int(1000 * sin(Double(i) * 0.01))
                let lead2 = Int(1000 * cos(Double(i) * 0.01))
                let wf = Waveform(
                    heartRate: 80,
                    lead1: lead1,
                    lead2: lead2,
                    arrhythmiaCode: 0,
                    moduleType: true,
                    leadType: type,
                    isLead1Status: true,
                    isLead2Status: true,
                    isHeartbeatDetected: false,
                    batteryStatus: .full,
                    timestamp: .now
                )
                vm.waveforms.append(wf)
            }

            return vm
        }
}
