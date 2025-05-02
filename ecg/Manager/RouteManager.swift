//
//  RouteManager.swift
//  ecg
//
//  Created by insung on 4/11/25.
//

import SwiftUI

enum Route: Hashable {
    case bluetooth
    case patchMeasure
    case directMeasure
    case caution
    case manual
    case measuring
}

enum SideBarTab: String, CaseIterable, Identifiable {
    case home = "tab_home"
    case record = "tab_record"
    case menu = "tab_menu"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .home: return "ic_home_nor"
        case .record: return "ic_record_nor"
        case .menu: return "ic_menu_nor"
        }
    }
}

class Router: ObservableObject {
    @Published var path = NavigationPath()
    @Published var selectedTab: SideBarTab = .home

    func push(to route: Route) {
        path.append(route)
    }

    func pop() {
        path.removeLast()
    }

    func popToRoot() {
        path.removeLast(path.count)
    }
}
