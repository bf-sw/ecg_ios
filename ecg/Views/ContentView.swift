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
                                switch route {
                                case .bluetooth:
                                    BluetoothView()
                                case .patchMeasure:
                                    PatchMeasureView()
                                case .directMeasure:
                                    DirectMeasureView()
                                        .environmentObject(waveViewModel)
                                case .measuring:
                                    MeasuringView()
                                        .environmentObject(waveViewModel)
                                case .caution:
                                    CautionView()
                                case .manual:
                                    ManualView()
                                case .eventGuide:
                                    EventGudieView()
                                case .connectionGuide:
                                    ConnectionGuideView()
                                case .result(let item):
                                    MeasurementResultView(item: item)
                                case .loadEvent:
                                    EventLoadView()
                                default:
                                    EmptyView()
                                }
                            }
                    }
                case .record:
                    NavigationStack(path: $router.path) {
                        RecordView()
                            .navigationDestination(for: Route.self) { route in
                                switch route {
                                case .result(let item):
                                    MeasurementResultView(item: item)
                                default:
                                    EmptyView()
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
                PopupManager.shared.showLoading(title: "기기와 연결 중입니다.", subtitle: "잠시만 기다려 주세요.")
            } else if state == .disconnected {
                self.router.popToRoot()
                ToastManager.shared.show(message: "블루투스 연결이 해제되었습니다.")
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
