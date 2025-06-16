//
//  MeasurementListViewModel.swift
//  ecg
//
//  Created by insung on 5/27/25.
//

import SwiftUI
import Combine

enum ListMode {
    case normal
    case selection
}

class MeasurementListViewModel: ObservableObject {
    @Published var listMode: ListMode = .normal
    @Published var isSelected: Bool = false {
        didSet {
            for index in items.indices {
                items[index].isSelected = isSelected
            }
        }
    }

    // TODO: 측정 데이터로 교체 필요
    @Published var items: [MeasurementItem] = [
        MeasurementItem(),
        MeasurementItem(),
        MeasurementItem(),
        MeasurementItem(),
        MeasurementItem(),
        MeasurementItem(),
    ]
    
    // 아이템 선택 처리
    func selectedItem(for item: MeasurementItem) {
        if let index = items.firstIndex(of: item) {
            items[index].isSelected.toggle()
            
        }
    }
    
    // 전체 체크
    func updateIsSelected() {
        isSelected = items.allSatisfy { $0.isSelected }
    }
}
