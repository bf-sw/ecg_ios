//
//  ManualView.swift
//  ecg
//
//  Created by insung on 4/22/25.
//

import SwiftUI

struct ManualView: View {
    
    @EnvironmentObject var router: Router
    
    var body: some View {
        VStack {
            AppBarView(title: "사용설명서")
            
            Text("심전도 모듈과 연결을 완료했어요.")
                .font(.titleFont)
                .padding()
            
            HStack(alignment: VerticalAlignment.top) {
                VStack {
                    Image("img_connect_patch")
                        .resizable()
                        .scaledToFit()
                        .boxShadow(color: Color.clear)
                        
                    Text("패치 측정")
                        .font(.titleFont)
                        .foregroundColor(.surfaceColor)
                    
                    Text("패치를 붙이고 \n가슴 중앙에 부착하여 측정해요")
                        .font(.desciptionFont)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(4)
                }
                VStack {
                    Image("img_connect_1_direct")
                        .resizable()
                        .scaledToFit()
                        .boxShadow(color: Color.clear)
                                
                    Text("1-유도")
                        .font(.titleFont)
                        .foregroundColor(.surfaceColor)
                    
                    Text("기기를 양손으로 잡고 측정해요")
                        .font(.desciptionFont)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(4)
                }
                VStack {
                    Image("img_connect_6_direct")
                        .resizable()
                        .scaledToFit()
                        .boxShadow(color: Color.clear)
                                
                    Text("6-유도")
                        .font(.titleFont)
                        .foregroundColor(.surfaceColor)
                    
                    Text("기기를 양손으로 잡고 왼쪽 무릎 혹은 발목에 접촉하여 측정해요")
                        .font(.desciptionFont)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(4)
                }
            }
            .padding(40)

            Spacer()
            
            Button(action: {
                router.pop()
            }) {
                Text("확인")
                    .frame(maxWidth: 420)
                    .padding()
                    .font(.desciptionFont)
                    .foregroundColor(.onSurfaceColor)
                    .background(Color.surfaceColor)
                    .cornerRadius(10)
                    .padding(40)
            }
        }
        .background(Color.backgroundColor)
        .navigationBarHidden(true)
    }
}

#Preview {
    ManualView()
}
