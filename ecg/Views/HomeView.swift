//
//  HomeView.swift
//  ecg
//
//  Created by insung on 4/9/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject var bluetoothManager = BluetoothManager.shared
    @StateObject private var deviceStatusViewModel = DeviceStatusViewModel()
    @EnvironmentObject var router: Router
    
    var body: some View {
        VStack {
            HStack(spacing: 16) {
                Image("img_home_logo")
                    .scaledToFit()
                Text("|")
                    .font(.titleFont)
                Text("DUAL ECG MONITOR")
                    .font(.titleFont)
                    .foregroundColor(.primaryColor)
                Spacer()
                if (bluetoothManager.connectedDevice != nil) {
                    deviceStatusViewModel.deviceStatus?.batteryStatus.imageBatteryStatus()
                }
            }
            .padding(20)
            
            HStack(spacing: 16) {
                // 기기 연결 카드
                if bluetoothManager.connectedDevice != nil {
                    connectedView()
                } else {
                    disconectedView()
                }
                
                VStack(spacing: 16) {
                    // 상단
                    VStack(spacing: 8) {
                        HStack {
                            Text("이벤트 측정 방법 알아보기")
                                .font(.titleFont)
                            Spacer()
                            Button("주의사항") {
                                // 주의사항 페이지
                                router.push(to: .caution)
                            }
                            .font(.desciptionFont)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .foregroundColor(.surfaceColor)
                            .background(Color.backgroundColor)
                            .cornerRadius(10)
                        }
                        .padding()
                        
                        Button(action: {
                            router.push(to: .eventGuide)
                        }) {
                            VStack {
                                Image("img_measure_device")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(minHeight: 140)
                                    .padding()
                                
                                Text("패치를 가슴에 부착하면\n연결이 끊겨도 부정맥을 체크할 수 있어요.")
                                    .font(.desciptionFont)
                                    .foregroundColor(.secondaryColor)
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        Spacer()
                    }
                    .padding(8)
                    .boxShadow()
                    
                    // 하단
                    VStack {
                        Text("아직 측정된 기록이 없어요.")
                            .font(.desciptionFont)
                            .foregroundColor(.secondaryColor)
                            .padding()
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(8)
                    .boxShadow()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxHeight: .infinity)
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 60)
            .background(Color.backgroundColor)
        }
        .background(Color.backgroundColor)
        .onAppear() {
            if bluetoothManager.connectedDevice != nil {
                PacketManager.shared.setDeviceTime()
            }
        }
        .onChange(of: deviceStatusViewModel.deviceStatus) { status in
            if let count = status?.eventCount, count > 0 {
                print("asd : \(status)")
                PopupManager.shared.showPopup(
                    title: "심전도를 측정하셨나요?",
                    messageHeader: "연결한 기기에 심전도 측정 기록이 있어요.\n측정 기록을 불러올까요?",
                    confirmTitle: "확인", cancelTitle: "다음에 하기", onConfirm: {
                        router.selectedTab = .event
                        router.push(to: .loadEvent)
                    })
            }
        }
    }
     
    func connectedView() -> some View {
        
        return VStack(spacing: 8) {
            HStack {
                Text("연결됨")
                    .font(.desciptionFont)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .foregroundColor(.blueColor)
                    .background(Color.backgroundBlueColor)
                    .cornerRadius(10)
                Text(bluetoothManager.connectedDevice?.name ?? "DEVICE NAME_1234")
                    .font(.titleFont)
                Spacer()
                Button("연결 해제") {
                    bluetoothManager.disconnect()
                }
                .font(.desciptionFont)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .foregroundColor(.surfaceColor)
                .boxRounded()
            }
            .padding(.vertical, 8)
            
            HStack(spacing: 16) {
                Button(action: {
                    router.push(to: .patchMeasure)
                }) {
                    VStack {
                        ZStack {
                            Color.surfaceVariantColor
                            Image("img_measure_patch")
                                .resizable()
                                .scaledToFit()
                        }
                        .padding(8)
                        
                        Text("패치 측정")
                            .font(.titleFont)
                            .foregroundColor(.surfaceColor)
                            .padding(8)
                        
                        Text("전극이 피부에 닿도록 부착하고 측정해요.")
                            .font(.desciptionFont)
                            .foregroundColor(.secondaryColor)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.vertical, 20)
                            .padding(.horizontal, 8)
                    }
                    .padding(.vertical, 20)
                    .boxShadow()
                }
                
                Button(action: {
                    router.push(to: .directMeasure)
                }) {
                    VStack {
                        ZStack {
                            Color.surfaceVariantColor
                            Image("img_measure_direct")
                                .resizable()
                                .scaledToFit()
                        }
                        .padding(8)
                        
                        Text("직접 측정")
                            .font(.titleFont)
                            .foregroundColor(.surfaceColor)
                            .padding(8)
                        
                        Text("전극을 접촉하여 심전도를 측정해요.")
                            .font(.desciptionFont)
                            .foregroundColor(.secondaryColor)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.vertical, 20)
                            .padding(.horizontal, 8)
                    }
                    .padding(.vertical, 20)
                    .boxShadow()
                }
            }
            
            HStack(spacing: 8) {
                Image(uiImage: UIImage(named: "ic_caution")!)
                Text("충전 중에는 심전도 측정이 어려워요.")
                    .font(.desciptionFont)
                    .foregroundColor(.secondaryColor)
                    .multilineTextAlignment(.center)
            }.padding()
           
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .boxShadow()
    }
    
    func disconectedView() -> some View {
        return VStack(spacing: 8) {
            HStack {
                Text("기기 연결")
                    .font(.titleFont)
                Spacer()
                Button("연결이 어려우신가요?") {
                    // 연결 가이드 페이지
                    router.push(to: .connectionGuide)
                }
                .font(.desciptionFont)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .foregroundColor(.surfaceColor)
                .background(Color.backgroundColor)
                .cornerRadius(10)
            }
            .padding(.vertical, 8)
            
            Spacer()
            
            Image("img_connect_device")
                .resizable()
                .scaledToFit()
            
            Text("아래의 전원 버튼을 누르고\n초록색 불빛이 깜빡이면 기기 연결을 눌러주세요.")
                .font(.desciptionFont)
                .foregroundColor(.secondaryColor)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            Button(action: {
                router.push(to: .bluetooth)
            }) {
                Text("기기 연결")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .font(.desciptionFont)
                    .foregroundColor(.onSurfaceColor)
                    .background(Color.surfaceColor)
                    .cornerRadius(10)
            }
            .padding()
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .boxShadow()
    }
}

#Preview {
    HomeView()
}
