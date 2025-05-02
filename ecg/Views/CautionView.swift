//
//  CautionView.swift
//  ecg
//
//  Created by insung on 4/21/25.
//

import SwiftUI

struct CautionView: View {
    var body: some View {
        VStack {
            AppBarView(title: "주의사항")
            
            Text("앱 이용 시 다음과 같은 유의사항에 주의하세요.")
                .font(.titleFont)
                .padding()
            
            VStack {
                HStack(alignment: VerticalAlignment.top) {
                    Image(uiImage: UIImage(named: "ic_caution_check")!)
                    VStack(alignment: HorizontalAlignment.leading) {
                        Text("심장마비를 감지할 수 없습니다.")
                            .font(.titleFont)
                            .padding(.bottom, 4)
                        Text("흉통, 압박감, 뻐근함 또는 심장마비로 의심되는 증상을 경험했다면 즉시 의사와 상의하세요.")
                            .font(.subtitleFont)
                    }
                    Spacer()
                }
                .padding()
                HStack(alignment: VerticalAlignment.top) {
                    Image(uiImage: UIImage(named: "ic_caution_check")!)
                    VStack(alignment: HorizontalAlignment.leading) {
                        Text("혈전 또는 뇌졸중을 감지할 수 없습니다.")
                            .font(.titleFont)
                    }
                    Spacer()
                }
                .padding()
                HStack(alignment: VerticalAlignment.top) {
                    Image(uiImage: UIImage(named: "ic_caution_check")!)
                    VStack(alignment: HorizontalAlignment.leading) {
                        Text("기타 심장 관련 상태를 감지할 수 없습니다.")
                            .font(.titleFont)
                            .padding(.bottom, 4)
                        Text("고혈압, 울혈성 심부전, 고콜레스테롤 또는 기타 형태의 부정맥을 포함합니다.")
                            .font(.subtitleFont)
                    }
                    Spacer()
                }
                .padding()
                HStack(alignment: VerticalAlignment.top) {
                    Image(uiImage: UIImage(named: "ic_caution_check")!)
                    VStack(alignment: HorizontalAlignment.leading) {
                        Text("컨디션이 좋지 않다면 의사와 상의하세요.")
                            .font(.titleFont)
                    }
                    Spacer()
                }
                .padding()
                
            }
            .frame(maxWidth: 720, maxHeight: 420)
            .padding(40)
            .boxShadow()
            .padding(.top, 20)
            
            Spacer()
        }
        .background(Color.backgroundColor)
        .navigationBarHidden(true)
    }
}

#Preview {
    CautionView()
}
