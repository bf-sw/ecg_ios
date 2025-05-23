//
//  AppBarView.swift
//  ecg
//
//  Created by insung on 4/11/25.
//

import SwiftUI

struct AppBarView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var title: String
    var backAction: (() -> Void)? = nil
    var rightContent: (() -> AnyView)? = nil

    var body: some View {
        ZStack {
            HStack {
                Button(action: {
                    guard let action = backAction else {
                        presentationMode.wrappedValue.dismiss()
                        return
                    }
                    action()
                }) {
                    Image(uiImage: UIImage(named: "ic_back")!)
                }
                Spacer()
            }
            Text(title)
                .font(.headerFont)
                .foregroundColor(.surfaceColor)
            
            HStack {
                Spacer()
                if let rightView = rightContent {
                    rightView()
                }
            }
        }
        .padding()
        .background(Color.backgroundColor)
    }
}

#Preview {
    AppBarView(title: "기기 연결")
}
