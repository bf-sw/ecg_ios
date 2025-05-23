//
//  ListOptionModel.swift
//  ecg
//
//  Created by insung on 5/21/25.
//

enum ListOption: CaseIterable {
    case none
    case load
    case download
    case delete
    
    var name: String {
        switch self {
        case .load: return "측정기록 불러오기"
        case .download: return "CSV 다운로드"
        case .delete: return "삭제"
        default: return ""
        }
    }
    
    var title: String {
        switch self {
        case .load: return "저장할 데이터를 선택하세요."
        case .download: return "저장할 데이터를 선택하세요."
        case .delete: return "삭제할 데이터를 선택하세요."
        default: return ""
        }
    }
}
