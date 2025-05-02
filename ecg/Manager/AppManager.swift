//
//  AppManager.swift
//  ecg
//
//  Created by insung on 4/21/25.
//

import Foundation
import Combine

class AppManager: ObservableObject {
    static let shared = AppManager()

    @Published var isLoading: Bool = false

    private init() {}
    
    func showLoading() {
        isLoading = true
    }
    
    func hideLoading() {
        isLoading = false
    }
}
