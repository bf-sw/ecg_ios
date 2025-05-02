//
//  MeasuringView.swift
//  ecg
//
//  Created by insung on 4/23/25.
//

import SwiftUI

struct MeasuringView: View {
    
    @EnvironmentObject var router: Router
    @EnvironmentObject var viewModel: WaveformViewModel
    @State private var elapsedTime: Double = 0.0
    
    var body: some View {
        VStack {
            AppBarView(title: "직접 측정")
                
            Text("심전도 측정 중이에요.")
                .font(.titleFont)
                .padding()
                
            HStack(alignment: .center) {
                VStack(spacing: 30) {
                    VStack(spacing: 4) {
                        Image(uiImage: UIImage(named: "ic_bpm")!)
                        Text("\(viewModel.heartRate)")
                            .font(.headerFont)
                        Text("BPM")
                            .font(.titleFont)
                    }
                        
                    VStack(spacing: 4) {
                        Image(uiImage: UIImage(named: "ic_time")!)
                        Text("\(Int(elapsedTime))")
                            .font(.headerFont)
                        Text("SEC")
                            .font(.titleFont)
                    }
                }
                LineChartView(elapsedTime: $elapsedTime)
                    .boxShadow()
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
            }
            .padding()
        }
        .background(Color.backgroundColor)
        .navigationBarHidden(true)
    }
}

#Preview {
    MeasuringView()
}
