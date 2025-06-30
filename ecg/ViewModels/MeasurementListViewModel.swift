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

    @Published var items: [MeasurementItem] = []
    
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
    
    // 데이터 최신 측정으로 정렬
    func loadSavedMeasurementItems() {
        let items = loadSavedItems().sorted { ($0.waveforms.last?.measureDate)! > ($1.waveforms.last?.measureDate)! }
        self.items = items
    }
    
    // 저장된 데이터 불러오기
    func loadSavedItems() -> [MeasurementItem] {
        let keys = DataManager.shared.getAllDataKeys()
        
        let items: [MeasurementItem] = keys.compactMap { key -> MeasurementItem? in
            guard let waveforms = DataManager.shared.loadData(for: key) else {
                return nil
            }
            
            return MeasurementItem(
                id: key,
                waveforms: waveforms
            )
        }
        return items
    }
}
