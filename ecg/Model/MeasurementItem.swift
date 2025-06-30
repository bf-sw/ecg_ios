//
//  MeasurementItem.swift
//  ecg
//
//  Created by insung on 5/27/25.
//

import SwiftUI

struct MeasurementItem: Identifiable, Equatable, Hashable {
    let id: String
    var isSelected: Bool = false
    var waveforms: [Waveform] = []
}
