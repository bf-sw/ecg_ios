//
//  UInt+Extension.swift
//  ecg
//
//  Created by insung on 4/23/25.
//

extension UInt8 {
    
    // 특정 비트 범위(하위 n비트)를 추출하는 함수
    func lowerBits(_ bitCount: Int) -> Int {
        return Int(self & UInt8((1 << bitCount) - 1))
    }

    // 특정 비트 위치가 1인지 여부 확인
    func isBitSet(at position: Int) -> Bool {
        return (self & (1 << position)) != 0
    }
}
