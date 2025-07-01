//
//  EventListViewModel.swift
//  ecg
//
//  Created by insung on 7/1/25.
//

import Foundation
import Combine

class EventListViewModel: ObservableObject {
    @Published var isSelected: Bool = false {
        didSet {
            for index in items.indices {
                items[index].isSelected = isSelected
            }
        }
    }
    
    @Published var items: [EventModel] = []
    
    init(items: [EventModel] = []) {
        self.items = items
    }
    
    // 아이템 선택 처리
    func selectedItem(for item: EventModel) {
        if let index = items.firstIndex(of: item) {
            items[index].isSelected.toggle()
        }
    }
    
    // 전체 체크
    func updateIsSelected() {
        isSelected = items.allSatisfy { $0.isSelected }
    }
}
