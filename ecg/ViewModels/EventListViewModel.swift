//
//  EventListViewModel.swift
//  ecg
//
//  Created by insung on 7/1/25.
//

import Foundation
import Combine

class EventListViewModel: ObservableObject {
    @Published var listMode: ListMode = .normal
    @Published var isSelected: Bool = false {
        didSet {
            for index in items.indices {
                items[index].isSelected = isSelected
            }
        }
    }
    
    @Published var items: [MeasurementModel] = []
    
    init(items: [MeasurementModel] = []) {
        self.items = items
    }
    
    // 아이템 선택 처리
    func selectedItem(for item: MeasurementModel) {
        if let index = items.firstIndex(of: item) {
            items[index].isSelected.toggle()
        }
    }
    
    // 전체 체크
    func updateIsSelected() {
        isSelected = items.allSatisfy { $0.isSelected }
    }
    
    // 데이터 최신 측정으로 정렬
    func loadSavedEventItems() {
        let items = loadSavedItems().sorted { ($0.waveforms.last?.measureDate)! > ($1.waveforms.last?.measureDate)! }
        self.items = items
    }
    
    // 저장된 데이터 불러오기
    func loadSavedItems() -> [MeasurementModel] {
        let keys = DataManager.shared.getAllEventKeys()
        
        let items: [MeasurementModel] = keys.compactMap { key -> MeasurementModel? in
            guard let waveforms = DataManager.shared.loadEventData(for: key) else {
                return nil
            }
            
            return MeasurementModel(
                id: key,
                waveforms: waveforms
            )
        }
        return items
    }
}
