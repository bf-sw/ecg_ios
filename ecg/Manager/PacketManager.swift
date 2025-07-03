import Foundation

final class PacketManager {

    static let shared = PacketManager()

    private var commandQueue: [Packet] = []
    private(set) var isSending = false
    private var currentDownload: Packet?

    private var pendingBytes: [UInt8] = []
    
    let downloadIndexRange: ClosedRange<Int> = 1...125

    private init() {}

    // MARK: - Public Command APIs

    func setDeviceTime() {
        let now = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: now) % 100
        let month = calendar.component(.month, from: now)
        let day = calendar.component(.day, from: now)
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)

        let baseData: [UInt8] = [UInt8(year), UInt8(month), UInt8(day), UInt8(hour), UInt8(minute)]
        sendCommand(Constants.Bluetooth.VERSION, with: baseData)
    }

    func searchEvent() {
        sendCommand(Constants.Bluetooth.SEND_EVENT)
    }

    func startMeasurement(from type: LeadType) {
        sendCommand(type == .one ? Constants.Bluetooth.MEASURE_START_1 : Constants.Bluetooth.MEASURE_START_6)
    }

    func stopMeasurement() {
        sendCommand(Constants.Bluetooth.MEASURE_STOP)
    }

    func deleteEvent(from num: Int) {
        sendCommand(Constants.Bluetooth.EVENT_DELETE, with: [UInt8(num)])
    }

    func downloadEvent(from itemNumber: Int) {
        for index in downloadIndexRange {
            sendCommand(Constants.Bluetooth.EVENT_DOWNLOAD, with: [UInt8(itemNumber), UInt8(index)], isDownload: true)
        }
        BluetoothManager.shared.processNextCommandIfNeeded()
    }

    // MARK: - Packet Queue Handling

    func sendCommand(_ command: UInt8, with baseData: [UInt8] = [], isDownload: Bool = false) {
        var packet = baseData
        packet.insert(command, at: 0)

        if packet.count != 1 {
            let checksum = calculateChecksum(for: packet)
            packet.append(checksum)
        }

        packet.append(Constants.Bluetooth.FOOTER)

        let queuedPacket: Packet
        if isDownload {
            let itemNumber = Int(baseData.first ?? 0)
            let index = Int(baseData.dropFirst().first ?? 0)
            queuedPacket = .download(itemNumber: itemNumber, index: index, bytes: packet)
        } else {
            queuedPacket = .regular(packet)
        }

        enqueue(packet: queuedPacket)
    }

    private func enqueue(packet: Packet) {
        commandQueue.append(packet)
        BluetoothManager.shared.processNextCommandIfNeeded()
    }

    func dequeueNextPacket() -> Packet? {
        guard !commandQueue.isEmpty else { return nil }
        let next = commandQueue.removeFirst()
        if case .download = next {
            currentDownload = next
        }
        return next
    }

    func setIsSending(_ sending: Bool) {
        isSending = sending
    }

    func onWriteComplete() {
        if case .download = currentDownload {
            // 다운로드 응답은 handleDownloadResponse에서 처리됨
        } else {
            isSending = false
            BluetoothManager.shared.processNextCommandIfNeeded()
        }
    }

    func resetQueue() {
        commandQueue.removeAll()
        pendingBytes.removeAll()
        isSending = false
        currentDownload = nil
    }

    // MARK: - 응답 처리 (BluetoothManager에서 직접 호출됨)

    func handleDownloadResponse(_ data: Data) {
        let bytes = [UInt8](data)
        pendingBytes.append(contentsOf: bytes)

        while let start = pendingBytes.firstIndex(of: Constants.Bluetooth.RECEIVE_EVENT_DOWNLOAD),
              let end = pendingBytes[start...].firstIndex(of: Constants.Bluetooth.FOOTER),
              end > start {

            let packet = Array(pendingBytes[start...end])
            if packet.count >= 5 {
                processDownloadPacket(packet)
            }

            pendingBytes.removeSubrange(start...end)
        }

        if pendingBytes.count > 1024 {
            pendingBytes.removeAll()
        }
    }

    private func processDownloadPacket(_ packet: [UInt8]) {
        guard packet.count >= 5,
              packet[0] == Constants.Bluetooth.RECEIVE_EVENT_DOWNLOAD,
              let current = currentDownload,
              case let .download(itemNumber, index, _) = current,
              packet[1] == UInt8(itemNumber),
              packet[2] == UInt8(index)
        else {
            print("⚠️ 다운로드 패킷 유효하지 않음")
            return
        }

        // 👉 수신 이벤트 발행
        BluetoothManager.shared.eventPublisher.send(.downloadEvent(Data(packet)))
        
        isSending = false
        currentDownload = nil
        BluetoothManager.shared.processNextCommandIfNeeded()
    }

    // MARK: - Checksum

    private func calculateChecksum(for data: [UInt8]) -> UInt8 {
        let sum = data.reduce(0) { $0 + UInt16($1) }
        return UInt8(sum & 0x7F)
    }

    // MARK: - Packet Model

    enum Packet {
        case regular([UInt8])
        case download(itemNumber: Int, index: Int, bytes: [UInt8])

        var bytes: [UInt8] {
            switch self {
            case .regular(let data): return data
            case .download(_, _, let data): return data
            }
        }
    }
}
