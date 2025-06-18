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
    @State private var timer: Timer?
    @State private var dataPoints: [CGPoint] = []
    @State private var allDataPoints: [[CGPoint]] = Array(repeating: [], count: 6)
    
    @State private var zoomScale: CGFloat = 1.0
    @State private var lastZoomScale: CGFloat = 1.0
    
    let measurementDuration: Double = 30.0
    let timerInterval: Double = 0.004
   
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
                        Text("\(Int(ceil(30 - elapsedTime)))")
                            .font(.headerFont)
                        Text("SEC")
                            .font(.titleFont)
                    }
                }
                .frame(width: 80)
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
        .onAppear {
            startMeasurement()
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
    
    func startMeasurement() {
        dataPoints.removeAll()
        elapsedTime = 0.0
        zoomScale = 1.0
        lastZoomScale = 1.0

        timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { t in
            elapsedTime += timerInterval
            if elapsedTime > measurementDuration {
                t.invalidate()
                timer = nil
                viewModel.isMeasurementFinished = true
            } else {
                let leadType = viewModel.selectedLeadType
                if leadType == .one {
                    if let latest = viewModel.waveforms.last {
                        let yValue = Double(latest.lead1)
                        dataPoints.append(CGPoint(x: elapsedTime, y: yValue))
                    }
                } else if leadType == .six {
                    if let latest = viewModel.waveforms.last {
                        DispatchQueue.main.async(execute: {
                            allDataPoints[0]
                                .append(
                                    CGPoint(x: elapsedTime, y: Double(latest.lead1))
                                )
                            allDataPoints[1]
                                .append(
                                    CGPoint(x: elapsedTime, y: Double(latest.lead2))
                                )
                            allDataPoints[2]
                                .append(
                                    CGPoint(x: elapsedTime, y: calculationLead3(waveform: latest))
                                )
                            allDataPoints[3]
                                .append(
                                    CGPoint(x: elapsedTime, y: calculationAVR(waveform: latest))
                                )
                            allDataPoints[4]
                                .append(
                                    CGPoint(x: elapsedTime, y: calculationAVL(waveform: latest))
                                )
                            allDataPoints[5]
                                .append(
                                    CGPoint(x: elapsedTime, y: calculationAVF(waveform: latest))
                                )
                        })
                    }
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
    
    func checkLeadConnection() {
        
        let leadType = viewModel.selectedLeadType
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
