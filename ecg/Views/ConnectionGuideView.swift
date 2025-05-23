//
//  ConnectionGuideView.swift
//  ecg
//
//  Created by insung on 5/13/25.
//

import SwiftUI

struct ConnectionGuideView: View {
    
    @EnvironmentObject var router: Router
    
    var body: some View {
        VStack {
            AppBarView(title: "연결방법")
            
            Text("기기 연결이 어렵다면 아래 방법을 확인해 보세요.")
                .font(.titleFont)
                .padding()
            
            HStack(alignment: VerticalAlignment.top, spacing: 0) {
                VStack {
                    Image("img_connect_step1")
                        .resizable()
                        .scaledToFit()
                        .boxShadow(color: Color.clear)
                        
                    Text("1. 전원 켜기")
                        .font(.titleFont)
                        .foregroundColor(.surfaceColor)
                    
                    Text("전원 버튼을 2초 이상 누른 후\n상태 표시등에 녹색 불빛이\n깜박이는지 확인해 주세요.")
                        .font(.desciptionFont)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(4)
                }
                VStack {
                    Image("img_connect_step2")
                        .resizable()
                        .scaledToFit()
                        .boxShadow(color: Color.clear)
                                
                    Text("2. 필수 접근 권한 허용")
                        .font(.titleFont)
                        .foregroundColor(.surfaceColor)
                    
                    Text("필수 항목에 대한 접근 권한이\n허용되었는지 확인해 주세요.")
                        .font(.desciptionFont)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(4)
                }
                VStack {
                    Image("img_connect_step3")
                        .resizable()
                        .scaledToFit()
                        .boxShadow(color: Color.clear)
                                
                    Text("3. 기기 연결")
                        .font(.titleFont)
                        .foregroundColor(.surfaceColor)
                    
                    Text("[기기 연결] 버튼을 눌러\n화면에서 탐색된 연결할 기기를\n선택해 주세요.")
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
    ConnectionGuideView()
}
