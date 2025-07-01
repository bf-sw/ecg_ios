//
//  EventViewModel.swift
//  ecg
//
//  Created by insung on 6/30/25.
//

import Foundation
import Combine

class EventViewModel: ObservableObject {
    @Published var events: [EventDataModel] = []
    @Published var receivedEvent: EventDataModel? = nil

    private var cancellables = Set<AnyCancellable>()
    private var pendingBytes: [UInt8] = []

    init() {
        BluetoothManager.shared.eventPublisher
            .sink { [weak self] event in
                if case .savedEvent(let data) = event {
                    DispatchQueue.global(qos: .userInitiated).async {
                        self?.appendAndParse(data: data)
                    }
                }
            }
            .store(in: &cancellables)
    }

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

            if pendingBytes.count < 12 {
                return
            }

            guard let footerIndex = pendingBytes[1...].firstIndex(of: footer) else {
                return
            }

            let packetLength = footerIndex + 1
            guard pendingBytes.count >= packetLength else {
                return
            }

            let packet = Array(pendingBytes[0..<packetLength])

            guard packet.count >= 3 else {
                pendingBytes.removeFirst()
                continue
            }

            let receivedChecksum = packet[packet.count - 2]
            let checksumTarget = packet[0..<packet.count - 2]
            let expectedChecksum = UInt8(checksumTarget.reduce(0, &+) & 0x7F)

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
}
