//
//  DirectMeasureView.swift
//  ecg
//
//  Created by insung on 4/21/25.
//

import SwiftUI
import CoreBluetooth

struct DirectMeasureView: View {
    
    @EnvironmentObject var router: Router
    @EnvironmentObject var viewModel: WaveformViewModel
    
    private var bluetoothManager = BluetoothManager.shared
    
    private let segments = ["1-유도", "6-유도"]
    
    var body: some View {
        VStack {
            AppBarView(title: "직접 측정", rightContent: {
                AnyView(
                    viewModel.batteryStatus.imageBatteryStatus()
                )
            })
            
            Text("전극 접촉이 완료되면 측정을 시작해요.")
                .font(.titleFont)
                .padding()
            
            SegmentedControlView(
                selectedIndex: Binding(
                    get: { viewModel.selectedLeadType == .one ? 0 : 1 },
                    set: { viewModel.selectedLeadType = $0 == 0 ? .one : .six }
                ),
                segments: segments,
                height: 60,
                backgroundColor: Color.white,
                selectedColor: Color.surfaceColor,
                textColor: Color.surfaceColor
            )
            .frame(maxWidth: 420)
            .pickerStyle(.segmented)
            .boxShadow()
            .padding()
            .onChange(of: viewModel.selectedLeadType) { newValue in
                viewModel.startMeasurement(type: newValue)
            }

            ZStack {
                VStack {
                    HStack {
                        Text("왼손")
                            .font(.desciptionFont)
                            .foregroundColor(.surfaceColor)
                            .padding()
                            .boxShadow(color: Color.surfaceVariantColor)
                        ZStack {
                            Image("img_device_front")
                                .scaledToFit()
                            if viewModel.isLead1Connected == true {
                                Image("img_device_left_a")
                                    .scaledToFit()
                                Image("img_device_right_a")
                                    .scaledToFit()
                            }
                        }
                        Text("오른손")
                            .font(.desciptionFont)
                            .foregroundColor(.surfaceColor)
                            .padding()
                            .boxShadow(color: Color.surfaceVariantColor)
                    }
                    
                    if (viewModel.selectedLeadType != .one) {
                        VStack {
                            ZStack {
                                Image("img_device_back")
                                    .scaledToFit()
                                if viewModel.isLead2Connected == true {
                                    Image("img_device_back_a")
                                        .scaledToFit()
                                }
                            }
                            Text("왼쪽 모릎 혹은 발목")
                                .font(.desciptionFont)
                                .foregroundColor(.surfaceColor)
                                .padding()
                                .boxShadow(color: Color.surfaceVariantColor)
                        }
                    }
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(
                            viewModel.selectedLeadType == .one ?
                            "img_measure_guide_1" : "img_measure_guide_6"
                        )
                        .scaledToFit()
                        .padding(.horizontal, 24)
                    }
                }
            }
            .frame(maxHeight: .infinity, alignment: Alignment.center)
            .padding(.bottom, 60)
            
        }
        .background(Color.backgroundColor)
        .navigationBarHidden(true)
        .onAppear() {
            print("여기로 오닝")
            viewModel.startMeasurement(type: viewModel.selectedLeadType)
        }
        .onDisappear() {
            if (viewModel.triggerNavigation == false) {
                print("스탑")
                viewModel.stopMeasurement()
            }
        }
        .onReceive(viewModel.$triggerNavigation) { push in
            if push {
                viewModel.markNavigationComplete()
                router.push(to: .measuring)
            }
        }
    }
}

#Preview {
    DirectMeasureView().environmentObject(WaveformViewModel())
}
