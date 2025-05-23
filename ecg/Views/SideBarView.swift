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
        VStack(spacing: 0) {
            Spacer()
            ForEach(SideBarTab.allCases, id: \.self) { tab in
                Button(action: {
                    router.selectedTab = tab
                    router.popToRoot()
                }) {
                    VStack {
                        let selectedColor: Color = router.selectedTab == tab ? .customPrimary : .customSurface
                        Image(uiImage: UIImage(named: tab.icon)!)
                            .renderingMode(.template)
                            .foregroundColor(selectedColor)
                        Text(LocalizedStringKey(tab.name))
                            .font(.titleFont)
                            .foregroundColor(selectedColor)
                    }
                    .padding(20)
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
