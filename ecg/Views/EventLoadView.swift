//
//  EventLoadView.swift
//  ecg
//
//  Created by insung on 7/1/25.
//

import SwiftUI

struct EventLoadView: View {
    @EnvironmentObject var router: Router
    @StateObject var viewModel = EventListViewModel()
    @StateObject var eventViewModel = EventViewModel()
    
    var body: some View {
        VStack {
            AppBarView(title: "측정 기록 불러오기", backAction: {
                router.selectedTab = .home
                router.popToRoot()
            })
            Text("저장할 데이터를 선택하세요.")
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
                
            // 리스트 추가
            measurementList()
                
            Spacer()
            HStack {
                Text("\(viewModel.items.filter { $0.isSelected }.count)개 선택됨")
                    .font(.subtitleFont)
                    .padding()
                Spacer()
                Button(action: {
                    let items = viewModel.items.filter { $0.isSelected }
                    items.forEach { it in
                        if let event = it.event {
                            PacketManager.shared
                                .deleteEvent(from: event.eventNumber)
                            DispatchQueue.main.async {
                                viewModel.items
                                    .removeAll { item in
                                        item == it
                                    }
                            }
                        }
                    }
                    ToastManager.shared.show(message: "삭제 되었습니다.")
                }) {
                    Text("선택 삭제")
                        .frame(width: 160)
                        .padding()
                        .font(.subtitleFont)
                        .foregroundColor(.onSurfaceColor)
                        .background(Color.surfaceColor)
                        .cornerRadius(10)
                }
                Button(action: {

                }) {
                    Text("저장")
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
        .ignoresSafeArea(.all, edges: .bottom)
        .background(Color.backgroundColor)
        .navigationBarHidden(true)
        .onAppear() {
            PacketManager.shared.searchEvent()
        }
        .onReceive(eventViewModel.$events) { newEvents in
            let newModels = newEvents.map { EventModel(id: UUID().uuidString, event: $0) }
            viewModel.items = newModels
        }
    }
    
    // 리스트
    func measurementList() -> some View {
        return ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 24) {
                ForEach(viewModel.items) { item in
                    EventListView(viewModel: viewModel, item: item)
                        .padding(.horizontal, 12)
                }
            }
        }
        .padding(.horizontal, 16)
    }
}

//#Preview {
//    EventLoadView()
//}

