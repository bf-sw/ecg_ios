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
    case eventGuide
    case connectionGuide
    case measuring
    case result(item: MeasurementModel)
    case loadEvent
}

enum SideBarTab: CaseIterable {
    case home
    case record
    case event
    case settings

    var name: String {
        switch self {
        case .home: return "tab_home"
        case .record: return "tab_record"
        case .event: return "tab_event"
        case .settings: return "tab_settings"
        }
    }

    var icon: String {
        switch self {
        case .home: return "ic_home"
        case .record: return "ic_record"
        case .event: return "ic_event"
        case .settings: return "ic_settings"
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
