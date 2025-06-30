//
//  LoadingView.swift
//  ecg
//
//  Created by insung on 4/21/25.
//

import SwiftUI

struct LoadingView: View {
    var title: String = ""
    var subtitle: String = ""
    
    var body: some View {
        ZStack {
            // 어두운 반투명 배경
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 60) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .customPrimary))
                    .scaleEffect(2.5)
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(.subtitleFont)
                        .foregroundColor(.surfaceColor)
                    Text(subtitle)
                        .font(.subtitleFont)
                        .foregroundColor(.surfaceColor)
                }
            }
            .frame(minWidth: 420, minHeight: 240)
            .padding(40)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
        }
    }
}

#Preview {
    LoadingView()
}
