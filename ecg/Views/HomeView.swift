//
//  HomeView.swift
//  ecg
//
//  Created by insung on 4/9/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var bluetoothViewModel = BluetoothViewModel()
    @StateObject private var deviceStatusViewModel = DeviceStatusViewModel()
    @EnvironmentObject var router: Router
    @EnvironmentObject var manager: PopupManager
    
    var body: some View {
        VStack {
            HStack(spacing: 16) {
                Image("img_home_logo")
                    .scaledToFit()
                Text("|")
                    .font(.titleFont)
                Text("HAMONICA")
                    .font(.titleFont)
                    .foregroundColor(.primaryColor)
                Spacer()
                if (bluetoothViewModel.connectedDevice != nil) {
                    imageBatteryStatus()
                }
            }
            .padding(20)
            
            HStack(spacing: 16) {
                // 기기 연결 카드
                if bluetoothViewModel.connectedDevice != nil {
                    connectedView()
                } else {
                    disconectedView()
                }
                
                VStack(spacing: 16) {
                    // 상단
                    VStack(spacing: 8) {
                        HStack {
                            Text("수동 측정 방법 알아보기")
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
                        
                        Image("img_measure_device")
                            .resizable()
                            .scaledToFit()
                            .frame(minHeight: 140)
                        
                        Text("패치를 가슴에 부착하면 얼굴을 켜지 않아도\n부정맥을 체크할 수 있어요.")
                            .font(.desciptionFont)
                            .foregroundColor(.secondaryColor)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Button(action: {
                            // 사용설명서 페이지
                            router.push(to: .manual)
                        }) {
                            Text("사용설명서")
                                .padding()
                                .font(.desciptionFont)
                                .foregroundColor(.onSurfaceColor)
                                .background(Color.surfaceColor)
                                .cornerRadius(10)
                        }
                        .padding(.top, 16)
                        
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
            if bluetoothViewModel.connectedDevice != nil {
                bluetoothViewModel.setDeviceTime()
            }
        }
    }
    
    func imageBatteryStatus() -> Image? {
        guard let status = deviceStatusViewModel.deviceStatus else {
            return nil
        }
        var imageName = ""
        if status.isCharging == true {
            imageName = "ic_battery_charge"
        } else {
            switch status.batteryStatus {
            case .empty:
                imageName = "ic_battery0"
                break
            case .level1:
                imageName = "ic_battery1"
                break
            case .level2:
                imageName = "ic_battery2"
                break
            case .full:
                imageName = "ic_battery3"
                break
            default:
                break
            }
        }
        if imageName.isEmpty == false {
            return Image(uiImage: UIImage(named: imageName)!)
        } else {
            return nil
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
                Text(bluetoothViewModel.connectedDevice?.name ?? "DEVICE NAME_1234")
                    .font(.titleFont)
                Spacer()
                Button("연결 해제") {
                    bluetoothViewModel.disconnect()
                }
                .font(.desciptionFont)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .foregroundColor(.surfaceColor)
                .background(Color.surfaceVariantColor)
                .cornerRadius(10)
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
