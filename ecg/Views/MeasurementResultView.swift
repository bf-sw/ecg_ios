//
//  MeasurementResultView.swift
//  ecg
//
//  Created by insung on 5/14/25.
//

import SwiftUI

struct MeasurementResultView: View {
    @EnvironmentObject var router: Router
//    @EnvironmentObject var viewModel: WaveformViewModel
    let item: MeasurementModel
    
    private let options: [ListOption] = [.download, .delete]
    
    var body: some View {
        let waveforms = item.waveforms
        let leadType = waveforms.last?.leadType ?? .one
        
        let lead1 = waveforms.enumerated().map {
            CGPoint(x: Double($0.offset), y: Double($0.element.lead1))
        }

        let lead2 = waveforms.map { Double($0.lead2) }
        let lead3 = waveforms.map { $0.calculateLead3() }
        let avf = waveforms.map { $0.calculateAVF() }
        let avl = waveforms.map { $0.calculateAVL() }
        let avr = waveforms.map { $0.calculateAVR() }

        let lead2Points = zip(0..., lead2).map {
            CGPoint(x: Double($0.0), y: $0.1)
        }
        let lead3Points = zip(0..., lead3).map {
            CGPoint(x: Double($0.0), y: $0.1)
        }
        let avfPoints = zip(0..., avf).map {
            CGPoint(x: Double($0.0), y: $0.1)
        }
        let avlPoints = zip(0..., avl).map {
            CGPoint(x: Double($0.0), y: $0.1)
        }
        let avrPoints = zip(0..., avr).map {
            CGPoint(x: Double($0.0), y: $0.1)
        }
        
        VStack {
            AppBarView(title: waveforms.measureDate, backAction: {
                router.popToRoot()
            }, rightContent: {
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
                Text(leadType.name)
                    .font(.subtitleFont)
                    .foregroundColor(.primaryColor)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.primaryColor.opacity(0.2))
                    .cornerRadius(10)
                Text("\(waveforms.arrhythmiaTypeName)")
                    .font(.titleFont)
                Image(uiImage: UIImage(named: "ic_info")!)
                Text("\(waveforms.arrhythmiaTypeDescription)")
                    .font(.desciptionFont)
                Spacer()
                Image(uiImage: UIImage(named: "ic_bpm")!)
                Text(waveforms.last?.heartRate == -1 ? "---" : "\(waveforms.last?.heartRate ?? 0)")
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
            
            if leadType == .one {
                GeometryReader { geometry in
                    LineChartView(
                        title: GraphType.none.rawValue,
                        dataPoints: .constant(lead1),
                        chartHeight: geometry.size.height - 140)
                    .padding(20)
                    .boxShadow()
                }
                .padding(.horizontal)
            } else if leadType == .six {
                GeometryReader { geometry in
                    let height = (geometry.size.height - 32 - 40  - 140) / 3
                    LazyVGrid(
                        columns: Array(
                            repeating: GridItem(.flexible(), spacing: 16),
                            count: 2
                        ),
                        spacing: 12
                    ) {
                        LineChartView(title: GraphType.one.rawValue, dataPoints: .constant(lead1), chartHeight: height)
                        LineChartView(title: GraphType.two.rawValue, dataPoints: .constant(lead2Points), chartHeight: height)
                        LineChartView(title: GraphType.three.rawValue, dataPoints: .constant(lead3Points), chartHeight: height)
                        LineChartView(title: GraphType.avr.rawValue, dataPoints: .constant(avrPoints), chartHeight: height)
                        LineChartView(title: GraphType.avl.rawValue, dataPoints: .constant(avlPoints), chartHeight: height)
                        LineChartView(title: GraphType.avf.rawValue, dataPoints: .constant(avfPoints), chartHeight: height)
                    }
                    .padding(20)
                    .boxShadow()
                }
                .padding(.horizontal)
            }
        }
        .background(Color.backgroundColor)
        .navigationBarHidden(true)
    }
    
    // 옵션 선택 적용
    private func updateSelectedOption(to option: ListOption) {
        if (option == .download) {
            DataManager.shared.exportCSVFiles(from: [item])
        } else {
            print("option : \(option)")
        }
    }
}


//#Preview {
//    MeasurementResultView()
//        .environmentObject(WaveformViewModel.previewSample(type: .one))
//}
