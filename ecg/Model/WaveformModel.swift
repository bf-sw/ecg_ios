//
//  Waveform.swift
//  ecg
//
//  Created by insung on 6/30/25.
//

import Foundation

enum GraphType: String {
    case none = "◼︎ electrocardiogram"
    case one = "◼︎ Lead I"
    case two = "◼︎ Lead II"
    case three = "◼︎ Lead III"
    case avr = "◼︎ aVR"
    case avl = "◼︎ aVL"
    case avf = "◼︎ aVF"
}

struct WaveformModel: Equatable, Codable, Hashable {
    let heartRate: Int
    let lead1: Int
    let lead2: Int
    let arrhythmiaCode: Int
    let moduleType: Bool
    let leadType: LeadType
    let isLead1Status: Bool
    let isLead2Status: Bool
    let isHeartbeatDetected: Bool
    let batteryStatus: BatteryStatus
    var measureDate: Date = .now
    
    var description: String {
            """
            🕒 MeasureDate: \(measureDate)
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

extension Array where Element == WaveformModel {
    
    // 빈맥 여부
    var hasATAC: Bool {
        self.contains { $0.arrhythmiaCode == 2 }
    }

    // 서맥 여부
    var hasSBRD: Bool {
        self.contains { $0.arrhythmiaCode == 3 }
    }

    // 부정맥 이름
    var arrhythmiaTypeName: String {
        switch (hasATAC, hasSBRD) {
        case (true, true): return "빈맥 및 서맥"
        case (true, false): return "빈맥"
        case (false, true): return "서맥"
        default: return "정상"
        }
    }

    // 부정맥 설명
    var arrhythmiaTypeDescription: String {
        switch (hasATAC, hasSBRD) {
        case (true, true): return "심전도에서 빠르거나 느린 심박이 번갈아 감지되었어요."
        case (true, false): return "심전도에서 심박수가 정상보다 빠른 빈맥 리듬이 감지되었어요."
        case (false, true): return "심전도에서 심박수가 정상보다 느린 서맥 리듬이 감지되었어요."
        default: return "심전도에서 심박 리듬이 정상 범위로 감지되었어요."
        }
    }
    
    // 날짜 표기
    var measureDate: String {
        guard let last = self.last?.measureDate else { return "-" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일 HH:mm"
        return formatter.string(from: last)
    }
}

