//
//  ContentView.swift
//  ecg
//
//  Created by insung on 4/9/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var router = Router()
    @StateObject var bluetoothManager = BluetoothManager.shared
    @StateObject var waveViewModel = WaveformViewModel()

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                SideBarView()
                
                Divider()
                
                switch router.selectedTab {
                case .home:
                    NavigationStack(path: $router.path) {
                        HomeView()
                            .navigationDestination(for: Route.self) { route in
                                if route == .bluetooth {
                                    BluetoothView()
                                } else if route == .patchMeasure {
                                    PatchMeasureView()
                                } else if route == .directMeasure {
                                    DirectMeasureView()
                                        .environmentObject(waveViewModel)
                                } else if route == .measuring {
                                    MeasuringView()
                                        .environmentObject(waveViewModel)
                                } else if route == .caution {
                                    CautionView()
                                } else if route == .manual {
                                    ManualView()
                                } else if route == .eventGuide {
                                    EventGudieView()
                                } else if route == .connectionGuide {
                                    ConnectionGuideView()
                                } else if route == .result {
                                    MeasurementResultView()
                                }
                            }
                    }
                case .record:
                    NavigationStack(path: $router.path) {
                        RecordView()
                            .navigationDestination(for: Route.self) { route in
                                if route == .result {
                                    MeasurementResultView()
                                }
                            }
                    }
                case .event:
                    NavigationStack(path: $router.path) {
                        EventView()
                    }
                case .settings:
                    NavigationStack(path: $router.path) {
                        SettingsView()
                    }
                }
            }
            .environmentObject(router)
        }
        .onChange(of: bluetoothManager.bluetoothState) { state in
            if state == .connecting {
                PopupManager.shared.showLoading()
            } else if state == .disconnected {
                self.router.popToRoot()
                ToastManager.shared.show(message: "블루투스 연결이 해제되었습니다.")
//                PopupManager.shared.showPopup(title: "블루투스 연결이 해제되었습니다.", confirmTitle: "확인", onConfirm: {
//                    self.router.popToRoot()
//                })
            }
        }
        
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toast()
        .popup()
    }
}


#Preview {
    ContentView()
}
