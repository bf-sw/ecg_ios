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
                
                NavigationStack(path: $router.path) {
                    Group {
                        switch router.selectedTab {
                        case .home:
                            HomeView()
                        case .record:
                            RecordView()
                        case .menu:
                            SettingsView()
                        }
                    }
                    .background(Color.backgroundColor)
                    .navigationDestination(for: Route.self) { route in
                        if case route = .bluetooth {
                            BluetoothView()
                        } else if case route = .patchMeasure {
                            PatchMeasureView()
                        } else if case route = .directMeasure {
                            DirectMeasureView()
                                .environmentObject(WaveformViewModel())
                        } else if case route = .measuring {
                            MeasuringView()
                                .environmentObject(WaveformViewModel())
                        } else if case route = .caution {
                            CautionView()
                        } else if case route = .manual{
                            ManualView()
                        }
                    }
                }
            }
            .frame(maxHeight: .infinity)
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
    }
}


#Preview {
    ContentView()
}
