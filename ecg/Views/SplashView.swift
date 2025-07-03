//
//  SplashView.swift
//  ecg
//
//  Created by insung on 4/7/25.
//

import SwiftUI

struct SplashView: View {
    @State private var isShowSplash: Bool = true
    @StateObject private var viewModel = SplashViewModel()

    var body: some View {
        ZStack {
            if viewModel.isShowSplash {
                SplashVideoPlayerView {
                    withAnimation {
                        viewModel.loadingSplash()
                    }
                }
            } else {
                PermissionView()
            }
        }
        .fullScreenCover(isPresented: $viewModel.isPermissionAllow) {
            ContentView()
        }
        .transaction { $0.disablesAnimations = true }
    }
}


#Preview {
    SplashView()
}
