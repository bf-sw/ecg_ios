//
//  PatchMeasureView.swift
//  ecg
//
//  Created by insung on 4/21/25.
//

import SwiftUI

struct PatchMeasureView: View {

    @EnvironmentObject var router: Router
    
    var body: some View {
        VStack {
            AppBarView(title: "패치 측정")
            
            Text("전극 패치의 보호 필름을 제거하고 가슴 중앙에 부착하면 측정을 시작해요.")
                .font(.titleFont)
                .padding()
            
            HStack {
                Button(action: {
                    router.push(to: .directMeasure)
                }) {
                    VStack {
                        Image("img_patch_point")
                            .resizable()
                            .scaledToFit()
                            .boxShadow(color: Color.clear)
                        
                        Text("전극 패치 부착 위치")
                            .font(.titleFont)
                            .foregroundColor(.surfaceColor)
                    }
                }
                Button(action: {
                    router.push(to: .directMeasure)
                }) {
                    VStack {
                        Image("img_device_point")
                            .resizable()
                            .scaledToFit()
                            .boxShadow(color: Color.clear)
                                
                        Text("본체 부착")
                            .font(.titleFont)
                            .foregroundColor(.surfaceColor)
                    }
                }
            }
            .padding(40)
            Spacer()
        }
        .background(Color.backgroundColor)
        .navigationBarHidden(true)
    }
}

#Preview {
    PatchMeasureView()
}
