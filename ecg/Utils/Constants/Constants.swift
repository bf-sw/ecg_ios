//
//  Constants.swift
//  ecg
//
//  Created by insung on 4/23/25.
//

enum Constants {
    enum Bluetooth {
        /// 버전
        static let VERSION: UInt8 = 0x80
        static let MEASURE_START_1: UInt8 = 0x82
        static let MEASURE_START_6: UInt8 = 0x83
        static let MEASURE_STOP: UInt8 = 0x84
        
        static let SEND_EVENT: UInt8 = 0x85
        static let EVENT_DELETE: UInt8 = 0x88
        static let EVENT_DOWNLOAD: UInt8 = 0x86

        static let RECEIVE_VERSION: UInt8 = 0x80
        static let RECEIVE_WAVEFORM: UInt8 = 0x86
        static let RECEIVE_EVENT: UInt8 = 0x90
        static let RECEIVE_EVENT_DELETE: UInt8 = 0x94
        static let RECEIVE_EVENT_DOWNLOAD: UInt8 = 0x91
        static let EMPTY_EVENT: UInt8 = 0x93
        static let FOOTER: UInt8 = 0xFE
        
        static let VERSION_COUNT: Int = 7
        static let WAVEFORM_COUNT: Int = 12
        
    }
}
