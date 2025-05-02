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
                Image(uiImage: UIImage(named: "img_splash_logo")!)
            } else {
                PermissionView()
            }
        }
        .fullScreenCover(isPresented: $viewModel.isPermissionAllow) {
            ContentView()
        }.transaction({ transaction in
            transaction.disablesAnimations = true
        })
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                withAnimation {
                    viewModel.loadingSplash()
                }
            })
        }
    }
}

#Preview {
    SplashView()
}
