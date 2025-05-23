//
//  EventGudieView.swift
//  ecg
//
//  Created by insung on 5/22/25.
//

import SwiftUI

struct EventGudieView: View {
    @EnvironmentObject var router: Router
    
    var body: some View {
        VStack {
            AppBarView(title: "이벤트 측정 방법")
            
            Text("모바일 앱을 연결하지 않아도 일회용 패치를 가슴에 부착 후\n본체를 연결하고 전원을 켜면 심전도를 측정할 수 있어요.")
                .multilineTextAlignment(.center)
                .font(.titleFont)
                .padding()
            
            HStack(alignment: VerticalAlignment.top, spacing: 0) {
                VStack {
                    Image("img_patch_step1")
                        .resizable()
                        .scaledToFit()
                        .boxShadow(color: Color.clear)
                        
                    Text("1. 가슴 전극 패치 부착")
                        .font(.titleFont)
                        .foregroundColor(.surfaceColor)
                    
                    Text("가슴에 일회용 전극 패치를 부착해요")
                        .font(.desciptionFont)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(4)
                }
                VStack {
                    Image("img_patch_step2")
                        .resizable()
                        .scaledToFit()
                        .boxShadow(color: Color.clear)
                                
                    Text("2. 컨트롤러 전원 켜기")
                        .font(.titleFont)
                        .foregroundColor(.surfaceColor)
                    
                    Text("컨트롤러의 전원을 켜고\n패치에 컨트롤러를 부착해요")
                        .font(.desciptionFont)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(4)
                }
                VStack {
                    Image("img_patch_step3")
                        .resizable()
                        .scaledToFit()
                        .boxShadow(color: Color.clear)
                                
                    Text("3. 전원 버튼 누르기")
                        .font(.titleFont)
                        .foregroundColor(.surfaceColor)
                    
                    Text("전원 버튼을 누르는 시점에 20초간\n1-유도 심전도가 측정 돼요.")
                        .font(.desciptionFont)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(4)
                }
            }
            .padding(40)

            Text("* 5분 동안 연결되지 않거나, 모든 전극에 신체 일부가 접촉되지 않으면 자동으로 전원이 꺼집니다.")
                .font(.desciptionFont)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding()
            
            Spacer()
        }
        .background(Color.backgroundColor)
        .navigationBarHidden(true)
    }
}

#Preview {
    EventGudieView()
}
