//
//  ToastManager.swift
//  ecg
//
//  Created by insung on 5/23/25.
//

import Foundation
import Combine

class ToastManager: ObservableObject {
    static let shared = ToastManager()

    @Published var message: String? = nil
    private var dismissCancellable: AnyCancellable?

    private init() {}

    func show(message: String, duration: TimeInterval = 2.0) {
        self.message = message

        dismissCancellable?.cancel()
        dismissCancellable = Just(())
            .delay(for: .seconds(duration), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.message = nil
            }
    }
}
