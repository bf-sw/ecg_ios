//
//  ListRow.swift
//  ecg
//
//  Created by insung on 4/14/25.
//

import SwiftUI

struct ListRow: View {
    var title: String
    var onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.subtitleFont)
                .foregroundColor(.surfaceColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 32)
                .padding(.horizontal, 20)
        }
    }
}

#Preview {
    ListRow(title: "기기", onTap: {})
}
