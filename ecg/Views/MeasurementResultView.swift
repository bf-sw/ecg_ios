//
//  MeasurementResultView.swift
//  ecg
//
//  Created by insung on 5/14/25.
//

import SwiftUI

struct MeasurementResultView: View {
    
    @State private var elapsedTime: Double = 30.0
    
    var body: some View {
        VStack {
            
            HStack {
                Text("1-유도")
                    .font(.subtitleFont)
                    .foregroundColor(.primaryColor)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.primaryColor.opacity(0.2))
                    .cornerRadius(10)
                Text("심방세동")
                    .font(.titleFont)
                Image(uiImage: UIImage(named: "ic_info")!)
                Text("심전도")
                    .font(.desciptionFont)
                Spacer()
                Image(uiImage: UIImage(named: "ic_bpm")!)
                Text("80")
                    .font(.headerFont)
                    .foregroundColor(.primaryColor)
                Text("BPM")
                    .font(.desciptionFont)
                    .foregroundColor(.primaryColor)
            }
            .padding()
            .boxShadow()
            .padding()
            LineChartView(elapsedTime: $elapsedTime)
                .boxShadow()
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
        }
    }
}

#Preview {
    MeasurementResultView()
        .environmentObject(WaveformViewModel())
}
