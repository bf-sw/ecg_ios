//
//  BluetoothView.swift
//  ecg
//
//  Created by insung on 4/11/25.
//

import SwiftUI

struct BluetoothView: View {
    
    @EnvironmentObject var router: Router
    
    @StateObject private var viewModel = BluetoothViewModel()
    
    var body: some View {
        
        VStack {
            AppBarView(title: "기기 연결")
            
            VStack {
                HStack {
                    Text("연결 가능한 기기")
                        .font(.subtitleFont)
                        .foregroundColor(.surfaceColor)
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.scanDevices()
                    }) {
                        Text("재탐색")
                            .font(.desciptionFont)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .foregroundColor(.onSurfaceColor)
                            .background(Color.surfaceColor)
                            .cornerRadius(10)
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal, 40)
                
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(viewModel.devices, id: \.identifier) { device in
                            ListRow(title: device.name ?? "알수 없는 기기") {
                                viewModel.connectToDevice(device)
                            }
                            .boxShadow()
                        }
                    }
                    .padding()
                }
                .clipped(antialiased: false)
                .padding(.horizontal, 32)
            }
        }
        .background(Color.backgroundColor)
        .onAppear {
            viewModel.resetDevices()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                viewModel.scanDevices()
            })
        }
        .onChange(of: viewModel.connectedDevice) { value in
            if value != nil {
                router.pop()
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    BluetoothView()
}
