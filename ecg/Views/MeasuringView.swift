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
                
            HStack() {
                VStack(spacing: 30) {
                    VStack(spacing: 4) {
                        Image(uiImage: UIImage(named: "ic_bpm")!)
                        Text(viewModel.heartRate == -1 ? "---" : "\(viewModel.heartRate)")
                            .font(.headerFont)
                        Text("BPM")
                            .font(.titleFont)
                    }
                        
                        
                    VStack(spacing: 4) {
                        Image(uiImage: UIImage(named: "ic_time")!)
                        Text("\(Int(30 - elapsedTime))")
                            .font(.headerFont)
                        Text("SEC")
                            .font(.titleFont)
                    }
                }
                .frame(width: 80)
                if viewModel.selectedLeadType == .one {
                    LineChartView(elapsedTime: $elapsedTime)
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
                                LineChartView(elapsedTime: $elapsedTime)
                                    .frame(height: chartHeight)
                                    .boxShadow()
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.bottom, 20)
                    }
                }
            }
            .padding()
        }
        .background(Color.backgroundColor)
        .navigationBarHidden(true)
        .onChange(of: viewModel.isLead1Connected) { _ in
            checkLeadConnection()
        }
        .onChange(of: viewModel.isLead2Connected) { _ in
            checkLeadConnection()
        }
        .onChange(of: viewModel.isMeasurementFinished) { finished in
            if finished {
                router.popToRoot()
                router.push(to: .result)
            }
        }
    }
    
    func checkLeadConnection() {
        
        let leadType = viewModel.selectedLeadType
        print("checkLeadConnection: \(leadType) viewModel.isLead1Connected: \(viewModel.isLead1Connected), viewModel.isLead1Connected: \(viewModel.isLead2Connected)")
        let disconnected = leadType == .one ? viewModel.isLead1Connected == false : viewModel.isLead1Connected == false || viewModel.isLead2Connected == false
        
        if disconnected {
            
            viewModel.stopMeasurement()
            PopupManager.shared.showPopup(title: "측정 실패",
                                     messageHeader: "다음 내용을 확인해 보세요.",
                                     messages: [
                                        "1. 측정이 완료될 때까지 전극을 접촉해 주세요.",
                                        "2. 기기 전원이 꺼져있는지 확인해 주세요.",
                                        "3. 블루투스가 연결되었는지 확인해 주세요.",
                                     ],
                                     confirmTitle: "재시도",
                                     cancelTitle: "취소",
                                     onConfirm: {
                router.pop()
            },
                                     onCancel: {
                router.popToRoot()
            })
        }
    }
}

#Preview {
    MeasuringView()
        .environmentObject(WaveformViewModel())
}
