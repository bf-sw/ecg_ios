//
//  ContentView.swift
//  ecg
//
//  Created by insung on 4/9/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var router = Router()
    @StateObject var popupManager = PopupManager()
    @StateObject var appManager = AppManager.shared
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
                                } else if route == .manual{
                                    ManualView()
                                } else if route == .eventGuide{
                                    EventGudieView()
                                } else if route == .connectionGuide{
                                    ConnectionGuideView()
                                }
                            }
                    }
                case .record:
                    NavigationStack(path: $router.path) {
                        RecordView()
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
            .environmentObject(popupManager)
            
            // 연결 중 인디케이터
            if appManager.isLoading {
                LoadingView()
            } else if popupManager.isShowing {
                PopupView(
                    title: popupManager.config.title,
                    messageHeader: popupManager.config.messageHeader,
                    messages: popupManager.config.messages,
                    confirmTitle: popupManager.config.confirmTitle,
                    cancelTitle: popupManager.config.cancelTitle,
                    onConfirm: {
                        popupManager.isShowing = false
                        popupManager.config.onConfirm()
                    },
                    onCancel: {
                        popupManager.isShowing = false
                        popupManager.config.onCancel?()
                    }
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toast()
    }
}


#Preview {
    ContentView()
}
