//
//  View+Extension.swift
//  ecg
//
//  Created by insung on 4/11/25.
//

import SwiftUI

extension View {
    
    func boxShadow(color: Color = Color.onSurfaceColor) -> some View {
        return self
                .background(color)
                .cornerRadius(16)
                .shadow(color: Color.shadowColor, radius: 20)
    }
}
