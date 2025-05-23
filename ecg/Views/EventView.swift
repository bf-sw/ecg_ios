//
//  EventView.swift
//  ecg
//
//  Created by insung on 5/12/25.
//

import SwiftUI

struct EventView: View {
    @EnvironmentObject var router: Router
    @State private var selectedOption: ListOption = .none
    @State private var isChecked: Bool = false
    
    private let options: [ListOption] = [.load, .download, .delete]
    
    var body: some View {
        VStack {
            AppBarView(title: "이벤트", backAction: {
                router.selectedTab = .home
            }, rightContent: {
                AnyView(
                    Menu {
                        ForEach(options, id: \.self) { option in
                            Button(option.name) {
                                if option == .load {
                                    ToastManager.shared.show(message: "연결된 기기가 없습니다.")
                                    return
                                }
                                selectedOption = option;
                            }
                        }
                    } label: {
                        Label("", image: "ic_more")
                            .padding(.horizontal, 8)
                    }
                )
            })
            if selectedOption == .none {
                Spacer()
                emptyEvent()
                Spacer()
            } else {
                Text(selectedOption.title)
                    .font(.titleFont)
                    .foregroundColor(.surfaceColor)
                HStack {
                    Button(action: {
                        isChecked.toggle()
                    }) {
                        Image(
                            uiImage: UIImage(
                                named: isChecked ? "ic_check_pre" : "ic_check_nor"
                            )!
                        )
                        Text("전체")
                            .font(.subtitleFont)
                            .foregroundColor(.surfaceColor)
                    }
                    Spacer()
                }
                .padding()
                
                // 리스트 추가
                
                Spacer()
                HStack {
                    Text("0개 선택됨")
                        .font(.subtitleFont)
                        .padding()
                    Spacer()
                    Button(action: {

                    }) {
                        Text("취소")
                            .frame(width: 160)
                            .padding()
                            .font(.subtitleFont)
                            .foregroundColor(.onSurfaceColor)
                            .background(Color.surfaceColor)
                            .cornerRadius(10)
                    }
                    Button(action: {

                    }) {
                        Text(selectedOption.name)
                            .frame(width: 160)
                            .padding()
                            .font(.subtitleFont)
                            .foregroundColor(.onSurfaceColor)
                            .background(Color.primaryColor)
                            .cornerRadius(10)
                    }

                }
                .padding()
                .boxShadow(color: .backgroundColor)
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .background(Color.backgroundColor)
        .navigationBarHidden(true)
    }
    
    func emptyEvent() -> some View {
        return VStack {
            Text("이벤트 기록이 없어요.")
                .font(.desciptionFont)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
}


#Preview {
    EventView()
}

