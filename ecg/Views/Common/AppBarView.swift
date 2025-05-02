//
//  AppBarView.swift
//  ecg
//
//  Created by insung on 4/11/25.
//

import SwiftUI

struct AppBarView: View {
    @StateObject private var viewModel = BluetoothViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var title: String

    var body: some View {
        ZStack {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
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
                if (viewModel.connectedDevice != nil) {
                    Image(uiImage: UIImage(named: "ic_battery3")!)
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
