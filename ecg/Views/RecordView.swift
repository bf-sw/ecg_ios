//
//  RecordView.swift
//  ecg
//
//  Created by insung on 4/11/25.
//

import SwiftUI

struct RecordView: View {
    @EnvironmentObject var router: Router
    @State private var selectedOption: ListOption = .none
    @State private var isChecked: Bool = false
    
    private let options: [ListOption] = [.download, .delete]
    
    var body: some View {
        VStack {
            AppBarView(title: "측정 기록", backAction: {
                router.selectedTab = .home
            }, rightContent: {
                AnyView(
                    Menu {
                        ForEach(options, id: \.self) { option in
                            Button(option.name) {
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
                emptyMeasurement()
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
    
    func emptyMeasurement() -> some View {
        return VStack {
            Text("측정 기록이 없어요.\n심전도를 측정해 보세요.")
                .font(.desciptionFont)
                .multilineTextAlignment(.center)
                .padding()
            HStack(spacing: 16) {
                Button("패치 측정") {
                    router.selectedTab = .home
                    router.push(to: .patchMeasure)
                }
                .font(.desciptionFont)
                .padding(.vertical, 16)
                .padding(.horizontal, 30)
                .foregroundColor(.surfaceColor)
                .boxRounded()
                
                Button("직접 측정") {
                    router.selectedTab = .home
                    router.push(to: .directMeasure)
                }
                .font(.desciptionFont)
                .padding(.vertical, 16)
                .padding(.horizontal, 30)
                .foregroundColor(.surfaceColor)
                .boxRounded()
            }
        }
    }
}

#Preview {
    RecordView()
}
