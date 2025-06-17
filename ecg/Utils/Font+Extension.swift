//
//  Font+Extension.swift
//  ecg
//
//  Created by insung on 4/9/25.
//

import SwiftUI

extension Font {
    static let headerFont = customFont(40, weight: .bold)
    static let titleFont = customFont(24, weight: .bold)
    static let subtitleFont = customFont(24, weight: .medium)
    static let desciptionFont = customFont(20, weight: .medium)
    static let popupHeaderFont = customFont(30, weight: .bold)
    static let popupTitleFont = customFont(28, weight: .bold)
    static let popupDescriptionFont = customFont(28, weight: .medium)
    static let captionFont = customFont(10, weight: .medium)
    
    static func customFont(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
            let fontName: String
            switch weight {
            case .bold:
                fontName = "BodyFriendB"
            case .medium:
                fontName = "BodyFriendM"
            case .light:
                fontName = "BodyFriendL"
            default:
                fontName = "BodyFriendM"
            }
            return Font.custom(fontName, size: size)
        }
}
