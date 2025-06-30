//
//  Date+Extension.swift
//  ecg
//
//  Created by insung on 6/26/25.
//

import SwiftUI

extension Date {
    
    func fileName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmm"
        return "ecg_\(dateFormatter.string(from: self)).csv"
    }
}
