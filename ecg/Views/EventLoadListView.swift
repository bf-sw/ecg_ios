//
//  EventLoadListView.swift
//  ecg
//
//  Created by insung on 7/2/25.
//

import SwiftUI

struct EventLoadListView: View {
    @ObservedObject var viewModel: EventLoadListViewModel
    let item: EventModel
    
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        if let event = item.event {
            HStack {
                Image(
                    uiImage: UIImage(
                        named: item.isSelected ? "ic_check_pre" : "ic_check_nor"
                    )!
                )
                .padding(.trailing, 8)
                VStack(alignment: .leading) {
                    Text(event.measureDate)
                        .font(.desciptionFont)
                    Spacer()
                    HStack {
                        Text(event.heartRate == -1 ? "---" : "\(event.heartRate) BPM")
                            .font(.desciptionFont)
                        Text(event.arrhythmiaTypeName)
                            .font(.titleFont)
                        Spacer()
                    }
                }
            }
            .frame(height: 60)
            .padding(24)
            .boxShadow()
            .onTapGesture {
                viewModel.selectedItem(for: item)
            }
        } else {
            EmptyView()
        }
    }
}
