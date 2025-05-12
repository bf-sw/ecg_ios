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
    @EnvironmentObject var popupManager: PopupManager
    
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
        .onChange(of: viewModel.isLead1Connected) { _ in
            checkLeadConnection()
        }
        .onChange(of: viewModel.isLead2Connected) { _ in
            checkLeadConnection()
        }
    }
    
    func checkLeadConnection() {
        
        let selected = viewModel.selectedMeasure
        print("checkLeadConnection: \(selected) viewModel.isLead1Connected: \(viewModel.isLead1Connected), viewModel.isLead1Connected: \(viewModel.isLead2Connected)")
        let lead1Disconnected = selected == 0 && viewModel.isLead1Connected == false
        let lead2Disconnected = selected == 1 && (viewModel.isLead1Connected == false || viewModel.isLead2Connected == false)
        
        if lead1Disconnected || lead2Disconnected {
            
            BluetoothManager.shared.sendCommand(
                command: Constants.Bluetooth.MEASURE_STOP)
            
            popupManager.showPopup(
                config: PopupManager
                    .PopupConfig(title: "측정 실패",
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
                                 }
                                )
            )
        }
    }
}

#Preview {
    MeasuringView()
}
