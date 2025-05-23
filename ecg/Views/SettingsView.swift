//
//  SettingsView.swift
//  ecg
//
//  Created by insung on 4/11/25.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var router: Router
    
    @State private var password = ""
    @State private var confirmPassword: String = ""
    @State private var isChecked: Bool = false
    
    var isPasswordValid: Bool {
        let isDigits = password.allSatisfy { $0.isNumber }
        return password.count == 4 && isDigits
    }

    var isConfirmValid: Bool {
        password == confirmPassword
    }

    var canSubmit: Bool {
        isPasswordValid && isConfirmValid && isChecked
    }
    
    var body: some View {
        VStack {
            AppBarView(title: "비밀번호 설정") {
                router.selectedTab = .home
            }
            Text("비밀번호를 설정해 주세요.")
                .font(.titleFont)
                .padding()
            
            VStack(spacing: 20) {
                HStack {
                    Text("비밀번호")
                        .frame(width: 150, alignment: .leading)
                        .font(.subtitleFont)
                    SecureTextField(placeholder: "숫자 4자리 입력", text: $password)
                        .font(.subtitleFont)
                        .frame(maxWidth: 720)
                        .padding(20)
                        .boxShadow()
                }
                HStack {
                    Text("비밀번호 확인")
                        .frame(width: 150, alignment: .leading)
                        .font(.subtitleFont)
                    SecureTextField(placeholder: "숫자 4자리 재입력", text: $confirmPassword)
                        .font(.subtitleFont)
                        .frame(maxWidth: 720)
                        .padding(20)
                        .boxShadow()
                        
                }
            }
            .padding(40)
            
            Button(action: {
                isChecked.toggle()
            }) {
                Image(uiImage: UIImage(named: isChecked ? "ic_check_pre" : "ic_check_nor")!)
                Text("비밀번호는 따로 저장되지 않기 때문에 분실 시 복구가 불가합니다.")
                    .font(.subtitleFont)
                    .foregroundColor(.surfaceColor)
            }
            .padding()
            
            Spacer()
            
            Button(action: {
                // 저장된 비밀번호 변경
            }) {
                Text("변경")
                    .frame(maxWidth: 420)
                    .padding()
                    .font(.desciptionFont)
                    .foregroundColor(.onSurfaceColor)
                    .background(
                        canSubmit ? Color.primaryColor : Color.gray.opacity(0.4)
                    )
                    .disabled(!canSubmit)
                    .cornerRadius(10)
                    .padding(40)
            }
        }
        
        .background(Color.backgroundColor)
        .navigationBarHidden(true)
    }
}

#Preview {
    SettingsView()
}
