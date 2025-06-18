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
    @State private var dataPoints: [CGPoint] = []
    @State private var allDataPoints: [[CGPoint]] = Array(repeating: [], count: 6)
    
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
                Text(viewModel.selectedLeadType == .one ? "1-유도" : "6-유도")
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
                Text(viewModel.heartRate == -1 ? "---" : "\(viewModel.heartRate)")
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
            
            if viewModel.selectedLeadType == .one {
                LineChartView(elapsedTime: $elapsedTime, dataPoints: $dataPoints)
                    .boxShadow()
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
            } else if viewModel.selectedLeadType == .six {
                GeometryReader { geometry in
                    let chartHeight = (
                        geometry.size.height - 32 - 40
                    ) / 3  // 3행, spacing 16*2, padding 40 고려
                    LazyVGrid(
                        columns: Array(
                            repeating: GridItem(.flexible(), spacing: 16),
                            count: 2
                        ),
                        spacing: 16
                    ) {
                        ForEach(0..<6, id: \.self) { index in
                            LineChartView(elapsedTime: $elapsedTime, dataPoints: $allDataPoints[index])
                                .frame(height: chartHeight)
                                .boxShadow()
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 20)
                }
            }
        }
        .background(Color.backgroundColor)
        .navigationBarHidden(true)
        .onAppear() {
            setEntireDataFromWaveforms()
        }
    }
    
    func setEntireDataFromWaveforms() {
        // 최대 7500개로 제한 (30초, 1초당 250개)
        let maxWaveforms = 250 * 30
        let trimmedWaveforms = Array(viewModel.waveforms.prefix(maxWaveforms))
        let leadType = viewModel.selectedLeadType
        
        if leadType == .one {
            
            let points = trimmedWaveforms.enumerated().map { index, wf in
                let x = Double(index) * (1.0 / 250.0) // = 0.004초 간격
                return CGPoint(x: x, y: Double(wf.lead1))
            }
            
            dataPoints = points
        } else if leadType == .six {
            // 6리드 사용하는 경우
            for i in 0..<6 {
                allDataPoints[i] = trimmedWaveforms
                    .enumerated()
                    .map { index, wf in
                        let x = Double(index) * (1.0 / 250.0)
                        let y: Double

                        switch i {
                        case 0: y = Double(wf.lead1)
                        case 1: y = Double(wf.lead2)
                        case 2: y = calculationLead3(waveform: wf)
                        case 3: y = calculationAVR(waveform: wf)
                        case 4: y = calculationAVL(waveform: wf)
                        case 5: y = calculationAVF(waveform: wf)
                        default: y = 0
                        }

                        return CGPoint(x: x, y: y)
                    }
            }
        }
    }
    
    func calculationLead3(waveform: Waveform) -> Double {
        return Double(waveform.lead2) - Double(waveform.lead1)
    }
    
    func calculationAVR(waveform: Waveform) -> Double {
        return -(Double(waveform.lead1) + Double(waveform.lead2))/2
    }
    
    func calculationAVL(waveform: Waveform) -> Double {
        return Double(waveform.lead1) - Double(waveform.lead2)/2
    }
    
    func calculationAVF(waveform: Waveform) -> Double {
        return Double(waveform.lead2) - Double(waveform.lead1)/2
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
