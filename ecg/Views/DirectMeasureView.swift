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
    
    private var bluetoothManager: CBCentralManager!
    
    private let segments = ["1-유도", "6-유도"]
    
    var body: some View {
        VStack {
            AppBarView(title: "직접 측정")
            
            Text("전극 접촉이 완료되면 측정을 시작해요.")
                .font(.titleFont)
                .padding()
            
            SegmentedControlView(
                selectedIndex: $viewModel.selectedMeasure,
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
                
                if (viewModel.selectedMeasure != 0) {
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
            .frame(maxHeight: .infinity, alignment: Alignment.center)
            .padding(.bottom, 60)
            
        }
        .background(Color.backgroundColor)
        .navigationBarHidden(true)
        .onAppear() {
            viewModel.resetForNextSession()
            BluetoothManager.shared.sendCommand(
                command: Constants.Bluetooth.MEASURE_START)
        }
        .onReceive(viewModel.$triggerNavigation) { push in
            if push {
                viewModel.markNavigationComplete() // ✅ 중복 방지
                router.push(to: .measuring)
            }
        }
    }
}

#Preview {
    DirectMeasureView()
}
