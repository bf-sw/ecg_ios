//
//  MeasurementResultView.swift
//  ecg
//
//  Created by insung on 5/14/25.
//

import SwiftUI

struct MeasurementResultView: View {
    
    @EnvironmentObject var viewModel: WaveformViewModel
    @State private var elapsedTime: Double = 30.0
    
    private let options: [ListOption] = [.download, .delete]
    
    var body: some View {
        VStack {
            AppBarView(title: "\(viewModel.measureDate)", rightContent: {
                AnyView(
                    Menu {
                        ForEach(options, id: \.self) { option in
                            Button(option.name) {
                                updateSelectedOption(to: option)
                            }
                        }
                    } label: {
                        Label("", image: "ic_more")
                            .padding(.horizontal, 8)
                    }
                )
            })
            
            HStack {
                Text(viewModel.leadType == .one ? "1-유도" : "2-유도")
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
                Text("\(viewModel.heartRate)")
                    .font(.headerFont)
                    .foregroundColor(.primaryColor)
                Text("BPM")
                    .font(.desciptionFont)
                    .foregroundColor(.primaryColor)
            }
            .padding()
            .boxShadow()
            .padding()
            
            Spacer()
            
            LineChartView(elapsedTime: $elapsedTime, waveforms: viewModel.waveforms, isRealtimeMode: false)
                .boxShadow()
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
        }
        .background(Color.backgroundColor)
        .navigationBarHidden(true)
    }
    
    // 옵션 선택 적용
    private func updateSelectedOption(to option: ListOption) {
        if (option == .download) {
            print("download ")
        } else {
            print("option : \(option)")
        }
    }
}

#Preview {
    MeasurementResultView()
        .environmentObject(WaveformViewModel())
}
