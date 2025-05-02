//
//  SplashViewModel.swift
//  ecg
//
//  Created by insung on 4/9/25.
//

import SwiftUI

class SplashViewModel: ObservableObject {
    @Published var isShowSplash = true
    @Published var isPermissionAllow = false
    
    
    func loadingSplash() {
        #if DEBUG
        checkPermission()
        #else
        self.checkAppVersion()
        #endif
    }
    
    
    func checkAppVersion() {
        print("checkAppVersion")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.checkPermission()
        })
    }
    
    func checkPermission() {
        print("checkPermission")
        isShowSplash = false
        isPermissionAllow = true
    }
    
}
