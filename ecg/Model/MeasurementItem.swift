//
//  MeasurementItem.swift
//  ecg
//
//  Created by insung on 5/27/25.
//

import SwiftUI

struct MeasurementItem: Identifiable, Equatable {
    let id: UUID = UUID()
    var isSelected: Bool = false
}
