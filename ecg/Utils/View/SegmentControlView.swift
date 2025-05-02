//
//  SegmentControlView.swift
//  ecg
//
//  Created by insung on 4/22/25.
//

import SwiftUI

struct SegmentedControlView: View {
    
    @Binding var selectedIndex: Int
    
    let segments: [String]
    var height: CGFloat = 40
    var backgroundColor: Color = .backgroundColor
    var selectedColor: Color = .surfaceColor
    var textColor: Color = .surfaceColor
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(segments.indices, id: \.self) { index in
                Button(action: {
                    selectedIndex = index
                }) {
                    Text(segments[index])
                        .font(.subtitleFont)
                        .foregroundColor(selectedIndex == index ? .white : textColor)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            Group {
                                if selectedIndex == index {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(selectedColor)
                                } else {
                                    Color.clear
                                }
                            }
                        )
                }
            }
        }
        .frame(height: height)
        .padding(4)
        .background(RoundedRectangle(cornerRadius: 10).fill(backgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .animation(.easeInOut(duration: 0.2), value: selectedIndex)
    }
}


#Preview {
    StatefulPreviewWrapper(0) { selected in
        SegmentedControlView(selectedIndex: selected, segments: ["One", "Two"])
    }
    
}
