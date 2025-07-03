//
//  EventLoadViewModel.swift
//  ecg
//
//  Created by insung on 7/2/25.
//


import Foundation
import Combine

class EventLoadViewModel: ObservableObject {
    @Published var events: [EventDataModel] = []
    @Published var receivedEvent: EventDataModel? = nil
    @Published var waveforms: [WaveformModel] = []

    private var cancellables = Set<AnyCancellable>()
    private var pendingBytes: [UInt8] = []
    private var waveformBuffer: [Int: [WaveformModel]] = [:]

    init() {
        BluetoothManager.shared.eventPublisher
            .sink { [weak self] event in
                switch event {
                case .savedEvent(let data):
                    DispatchQueue.global(qos: .userInitiated).async {
                        self?.appendAndParse(data: data)
                    }

                case .downloadEvent(let data):
                    self?.handleDownloadPacket(data)

                default:
                    break
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - 이벤트 패킷 파싱

    private func appendAndParse(data: Data) {
        pendingBytes.append(contentsOf: data)
        parseBufferedData()
    }

    private func parseBufferedData() {
        let header: UInt8 = Constants.Bluetooth.RECEIVE_EVENT
        let footer: UInt8 = Constants.Bluetooth.FOOTER

        while true {
            guard let headerIndex = pendingBytes.firstIndex(of: header) else {
                pendingBytes.removeAll()
                return
            }

            if headerIndex > 0 {
                pendingBytes.removeFirst(headerIndex)
            }

            if pendingBytes.count < 12 { return }

            guard let footerIndex = pendingBytes[1...].firstIndex(of: footer) else {
                return
            }

            let packetLength = footerIndex + 1
            guard pendingBytes.count >= packetLength else { return }

            let packet = Array(pendingBytes[0..<packetLength])
            guard packet.count >= 3 else {
                pendingBytes.removeFirst()
                continue
            }

            let receivedChecksum = packet[packet.count - 2]
            let checksumTarget = packet[0..<packet.count - 2]
            let sum: UInt16 = checksumTarget.reduce(0) { $0 + UInt16($1) }
            let expectedChecksum = UInt8(sum & 0x7F)

            if expectedChecksum != receivedChecksum {
                print("❌ 체크섬 불일치: 계산=\(expectedChecksum), 받은=\(receivedChecksum)")
                pendingBytes.removeFirst(headerIndex + 1)
                continue
            }

            let payload = Array(packet[1..<(packet.count - 2)])
            let eventCount = payload.count / 9

            for i in 0..<eventCount {
                let start = i * 9
                guard start + 9 <= payload.count else { break }
                let slice = Array(payload[start..<start + 9])

                let event = EventDataModel(
                    eventNumber: Int(slice[0]),
                    year: Int(slice[1]),
                    month: Int(slice[2]),
                    day: Int(slice[3]),
                    hour: Int(slice[4]),
                    minute: Int(slice[5]),
                    heartRate: (Int(slice[6] & 0x7F) << 7) | Int(slice[7] & 0x7F),
                    arrhythmiaCode: Int(slice[8]),
                    rawBytes: slice
                )

                DispatchQueue.main.async {
                    print("📥 이벤트 수신됨: \(event)")
                    self.events.append(event)
                    self.receivedEvent = event
                }
            }

            pendingBytes.removeSubrange(0..<packetLength)
        }
    }

    // MARK: - 다운로드 패킷 처리 및 저장

    private func handleDownloadPacket(_ data: Data) {
        let bytes = [UInt8](data)
        guard bytes.count == 128 else { return }
        guard bytes.first == Constants.Bluetooth.RECEIVE_EVENT_DOWNLOAD else { return }
        guard bytes.last == Constants.Bluetooth.FOOTER else { return }

        let checksum = bytes[126]
        let sum = bytes[0..<126].reduce(0) { UInt16($0) + UInt16($1) }
        let expected = UInt8(sum & 0x7F)
        guard checksum == expected else {
            print("❌ Waveform 체크섬 오류: \(checksum) != \(expected)")
            return
        }

        let index = Int(bytes[2])
        let samples = Array(bytes[3..<123])
        var models: [WaveformModel] = []

        for i in stride(from: 0, to: samples.count, by: 3) {
            guard i + 2 < samples.count else { break }

            let high = Int(samples[i] & 0x7F)
            let mid = Int(samples[i + 1] & 0x7F)
            let low = Int(samples[i + 2] & 0x7F)
            let raw = (high << 14) | (mid << 7) | low
            let signedValue = raw - 0x100000

            let model = WaveformModel(
                heartRate: 0,
                lead1: signedValue,
                lead2: signedValue,
                arrhythmiaCode: 0,
                leadType: .event,
                measureDate: .now
            )

            models.append(model)
        }

        DispatchQueue.main.async {
            self.waveformBuffer[index] = models
            print("📦 인덱스 \(index) 저장됨 (\(models.count)개)")

            if self.waveformBuffer.keys.count >= 125 {
                let sorted = (1...125).compactMap { self.waveformBuffer[$0] }.flatMap { $0 }
                self.waveforms = sorted
                print("✅ 총 \(self.waveforms.count)개 저장됨 → saveEventData 호출")
                DataManager.shared.saveEventData(self.waveforms)
            }
        }
    }
}
