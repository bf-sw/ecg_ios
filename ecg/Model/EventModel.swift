//
//  EventModel.swift
//  ecg
//
//  Created by insung on 6/30/25.
//

import Foundation

struct EventModel: Identifiable, Equatable, Hashable {
    let id: String
    var isSelected: Bool = false
    var event: EventDataModel?
}


struct EventDataModel: Hashable, Codable {
    let eventNumber: Int
    let year: Int  // (25~99)
    let month: Int // (1~12)
    let day: Int   // (1~31)
    let hour: Int  // (0~23)
    let minute: Int // (0~59)
    let heartRate: Int // 14bit
    let arrhythmiaCode: Int
    let rawBytes: [UInt8]
    
    var date: Date? {
        var components = DateComponents()
        components.year = 2000 + year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components)
    }
    
    var description: String {
                            """
                            🕒 [Event \(eventNumber)] \(year)년 \(month)월 \(day)일 \(hour):\(minute) | 심박수 \(heartRate)회 | 부정맥 \(arrhythmiaCode)
                            """
    }
    
    // 빈맥 여부
    var hasATAC: Bool {
        arrhythmiaCode == 2
    }

    // 서맥 여부
    var hasSBRD: Bool {
        arrhythmiaCode == 3
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
        return "\(year)년 \(month)월 \(day)일 \(hour):\(minute)"
    }

}
