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
    @StateObject var viewModel = EventListViewModel()
    @StateObject var bluetoothManager = BluetoothManager.shared
    
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
                                    if bluetoothManager.connectedDevice != nil {
                                        router.push(to: .loadEvent)
                                    } else {
                                        ToastManager.shared
                                            .show(message: "연결된 기기가 없습니다.")
                                        return
                                    }
                                }
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
                    emptyEvent()
                } else {
                    eventList()
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
                
                eventList()
                
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
            viewModel.loadSavedEventItems()
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
    func eventList() -> some View {
        return ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 24) {
                ForEach(viewModel.items) { item in
                    EventListView(viewModel: viewModel, item: item) {
                        router.push(to: .result(item: item))
                    }
                    .padding(.horizontal, 6)
                }
            }
        }
        .padding(.horizontal, 16)
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
