//
//  String+Extension.swift
//  ecg
//
//  Created by insung on 4/16/25.
//

extension String {
    
    // 검색명에 지원하는 코드가 있는지
    func hasDeviceCode() -> Bool {
        return self.hasPrefix(Device.ecg.code)
    }
    
    func fileName() -> String? {
        let name = self.split(separator: "/").last.map(String.init) ?? ""
        return name.removingPercentEncoding
    }
}
