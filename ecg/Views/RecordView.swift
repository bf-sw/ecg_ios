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
    @StateObject var viewModel = MeasurementListViewModel()
    
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
                                updateSelectedOption(to: option)
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
                if viewModel.items.isEmpty {
                    emptyMeasurement()
                } else {
                    measurementList()
                        .padding(.vertical, 24)
                }
                Spacer()
            } else {
                Text(selectedOption.title)
                    .font(.titleFont)
                    .foregroundColor(.surfaceColor)
                HStack {
                    Button(action: {
                        viewModel.isSelected.toggle()
                    }) {
                        Image(
                            uiImage: UIImage(
                                named: viewModel.isSelected ? "ic_check_pre" : "ic_check_nor"
                            )!
                        )
                        Text("전체")
                            .font(.subtitleFont)
                            .foregroundColor(.surfaceColor)
                    }
                    Spacer()
                }
                .padding()
                
                measurementList()
                
                Spacer()
                HStack {
                    Text("\(viewModel.items.filter { $0.isSelected }.count)개 선택됨")
                        .font(.subtitleFont)
                        .padding()
                    Spacer()
                    Button(action: {
                        updateSelectedOption(to: .none)
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
        .onAppear() {
            viewModel.loadSavedMeasurementItems()
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .background(Color.backgroundColor)
        .navigationBarHidden(true)
    }
    
    // 옵션 선택 적용
    private func updateSelectedOption(to option: ListOption) {
        viewModel.isSelected = false
        selectedOption = option
        updateListMode()
    }
    
    // 리스트 모드가 선택모드인지 구분
    private func updateListMode() {
        viewModel.listMode = (selectedOption == .none) ? .normal : .selection
    }
    
    // 리스트
    func measurementList() -> some View {
        return ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 24) {
                ForEach(viewModel.items) { item in
                    MeasurementListView(viewModel: viewModel, item: item) {
                        router.push(to: .result(item: item))
                    }
                    .padding(.horizontal, 6)
                }
            }
        }
        .padding(.horizontal, 16)
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
                    if BluetoothManager.shared.connectedDevice == nil {
                        router.selectedTab = .home
                        router.push(to: .bluetooth)
                        return
                    }
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
