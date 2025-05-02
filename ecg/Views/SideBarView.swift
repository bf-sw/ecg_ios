//
//  SideBarView.swift
//  ecg
//
//  Created by insung on 4/14/25.
//

import SwiftUI

struct SideBarView: View {
    @EnvironmentObject var router: Router
    
    var body: some View {
        VStack(spacing: 80) {
            Spacer()
            ForEach(SideBarTab.allCases) { tab in
                Button(action: {
                    router.selectedTab = tab
                }) {
                    VStack {
                        Image(uiImage: UIImage(named: tab.icon)!)
                        Text(LocalizedStringKey(tab.rawValue))
                            .foregroundColor(router.selectedTab == tab ? .customSecondary : .customPrimary)
                    }
                    .padding(30)
                    .foregroundColor(router.selectedTab == tab ? .customSecondary : .customPrimary)
                    .background(router.selectedTab == tab ? .customPrimary : Color.clear)
                    .cornerRadius(20)
                }
            }
            .padding(20)
            Spacer()
        }
        .frame(maxHeight: .infinity)
        .padding(.vertical)
        .background(Color.backgroundColor)
    }
}
