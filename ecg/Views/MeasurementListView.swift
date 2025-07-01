//
//  MeasurementListView.swift
//  ecg
//
//  Created by insung on 5/27/25.
//

import SwiftUI

struct MeasurementListView: View {
    @ObservedObject var viewModel: MeasurementListViewModel
    let item: MeasurementModel
    
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        let waveform = item.waveforms.last
        
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
                    Text(waveform?.leadType.name ?? "")
                        .font(.desciptionFont)
                        .foregroundColor(.primaryColor)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.primaryColor.opacity(0.2))
                        .cornerRadius(10)
                    Text(item.waveforms.arrhythmiaTypeName)
                        .font(.titleFont)
                    Spacer()
                    Image(uiImage: UIImage(named: "ic_bpm")!)
                    Text(waveform?.heartRate == -1 ? "---" : "\(waveform?.heartRate ?? 0) BPM")
                        .font(.desciptionFont)
                }
                Spacer()
                
                Text(item.waveforms.measureDate)
                    .font(.desciptionFont)
                
            }
        }
        .frame(height: 100)
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
    MeasurementListView(viewModel: MeasurementListViewModel(), item: MeasurementModel(id: UUID().uuidString))
}
