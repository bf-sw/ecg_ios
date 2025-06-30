//
//  LoadingManager.swift
//  ecg
//
//  Created by insung on 6/26/25.
//

import Foundation
import Combine

final class LoadingManager: ObservableObject {
    static let shared = LoadingManager()
    
    @Published var isLoading: Bool = false
    
    private init() {}
    
    func show() {
        DispatchQueue.main.async {
            self.isLoading = true
        }
    }
    
    func hide() {
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
}
