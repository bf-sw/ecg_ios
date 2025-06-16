//
//  MeasurementListView.swift
//  ecg
//
//  Created by insung on 5/27/25.
//

import SwiftUI

struct MeasurementListView: View {
    @ObservedObject var viewModel: MeasurementListViewModel
    let item: MeasurementItem
    
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            if (viewModel.listMode == .selection) {
                Image(
                    uiImage: UIImage(
                        named: item.isSelected ? "ic_check_pre" : "ic_check_nor"
                    )!
                )
                .padding(.trailing, 8)
            }
            VStack(alignment: .leading) {
                HStack {
                    Text("1-유도")
                        .font(.desciptionFont)
                        .foregroundColor(.primaryColor)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.primaryColor.opacity(0.2))
                        .cornerRadius(10)
                    Text("심방세동")
                        .font(.titleFont)
                    Spacer()
                    Image(uiImage: UIImage(named: "ic_bpm")!)
                    Text("80")
                        .font(.desciptionFont)
                    Text("BPM")
                        .font(.desciptionFont)
                }
                Text("2026년 08월 10일 02:12")
                    .font(.desciptionFont)
                
            }
        }
        .padding(24)
        .boxShadow()
        .onTapGesture {
            if viewModel.listMode == .selection {
                viewModel.selectedItem(for: item)
            } else {
                onTap?()
            }
        }
    }
}

#Preview {
    MeasurementListView(viewModel: MeasurementListViewModel(), item: MeasurementItem())
}
