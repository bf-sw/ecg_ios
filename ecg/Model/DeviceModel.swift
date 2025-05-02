//
//  DeviceModel.swift
//  ecg
//
//  Created by insung on 4/16/25.
//

enum Device {
    case ecg
    
    var name: String {
        switch self {
        case .ecg: return "ECG"
        }
    }
    
    var code: String {
        switch self {
        case .ecg: return "MHM"
        }
    }
}


