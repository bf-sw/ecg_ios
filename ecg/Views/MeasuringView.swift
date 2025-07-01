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
    
    var body: some View {
        VStack {
            AppBarView(title: "직접 측정")
                
            Text("심전도 측정 중이에요.")
                .font(.titleFont)
                .padding()
                
            Spacer()
            HStack {
                infoPanel
                chartPanel
            }
            .padding()
            Spacer()
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
                DataManager.shared.saveData(viewModel.waveforms)
                let timestamp = Int(viewModel.waveforms.last?.measureDate.timeIntervalSince1970 ?? 0)
                let key = "waveform_\(timestamp)"
                router.push(to: .result(item: MeasurementModel(
                    id: key,
                    waveforms: viewModel.waveforms)
                ))
            }
        }
        .onAppear {
            viewModel.resetData()
        }
    }
        
    private var infoPanel: some View {
        VStack(spacing: 30) {
            VStack(spacing: 4) {
                Image(uiImage: UIImage(named: "ic_bpm")!)
                Text(
                    viewModel.heartRate == -1 ? "---" : "\(viewModel.heartRate)"
                )
                .font(.headerFont)
                Text("BPM")
                    .font(.titleFont)
            }
            VStack(spacing: 4) {
                Image(uiImage: UIImage(named: "ic_time")!)
                Text("\(Int(ceil(30 - viewModel.elapsedTime)))")
                    .font(.headerFont)
                Text("SEC")
                    .font(.titleFont)
            }
        }
        .frame(width: 80)
    }

    @ViewBuilder
    private var chartPanel: some View {
        if viewModel.selectedLeadType == .one {
            GeometryReader { geometry in
                LineChartView(
                    title: GraphType.none.rawValue,
                    showAxis: false,
                    dataPoints: $viewModel.lead1Points,
                    chartHeight: geometry.size.height - 60)
                .padding(20)
                .boxShadow()
            }
            .padding(.horizontal)
        } else if viewModel.selectedLeadType == .six {
            GeometryReader { geometry in
                let height = (geometry.size.height - 32 - 40 - 60) / 3
                LazyVGrid(
                    columns: Array(
                        repeating: GridItem(.flexible(), spacing: 16),
                        count: 2
                    ),
                    spacing: 12
                ) {
                    LineChartView(title: GraphType.one.rawValue, showAxis: false, dataPoints: $viewModel.lead1Points, chartHeight: height)
                    LineChartView(title: GraphType.two.rawValue, showAxis: false, dataPoints: $viewModel.lead2Points, chartHeight: height)
                    LineChartView(title: GraphType.three.rawValue, showAxis: false, dataPoints: $viewModel.lead3Points, chartHeight: height)
                    LineChartView(title: GraphType.avr.rawValue, showAxis: false, dataPoints: $viewModel.avrPoints, chartHeight: height)
                    LineChartView(title: GraphType.avl.rawValue, showAxis: false, dataPoints: $viewModel.avlPoints, chartHeight: height)
                    LineChartView(title: GraphType.avf.rawValue, showAxis: false, dataPoints: $viewModel.avfPoints, chartHeight: height)
                }
                .padding(20)
                .boxShadow()
            }
            .padding(.horizontal)
        }
    }
    
    func checkLeadConnection() {
        let leadType = viewModel.selectedLeadType
        let disconnected = leadType == .one ? viewModel.isLead1Connected == false : viewModel.isLead1Connected == false || viewModel.isLead2Connected == false
        
        if disconnected {
            viewModel.markNavigationComplete()
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
        .environmentObject(WaveformViewModel.previewSample(type: .six)) // or .one
}
