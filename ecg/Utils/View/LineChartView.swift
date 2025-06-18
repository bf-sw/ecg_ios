//
//  LineChartView.swift
//  ecg
//
//  Created by insung on 4/30/25.
//

import SwiftUI

struct LineChartView: View {
    @EnvironmentObject var viewModel: WaveformViewModel
    @Binding var elapsedTime: Double
    @Binding var dataPoints: [CGPoint]

    @State private var zoomScale: CGFloat = 1.0
    @State private var lastZoomScale: CGFloat = 1.0

    let measurementDuration: Double = 30.0
    let maxValue: Double = 5000    // Y축: ±5000 범위
    let xSpacing: CGFloat = 50.0

    var body: some View {
        GeometryReader { geometry in
            let effectiveXSpacing = xSpacing * zoomScale
            let fullChartWidth = CGFloat(Int(ceil(measurementDuration))) * effectiveXSpacing
            let graphHeight = geometry.size.height
            let measuredWidth = CGFloat(max(Int(ceil(elapsedTime)), 1)) * effectiveXSpacing
            let visibleWidth = geometry.size.width

            HStack(alignment: .top, spacing: 0) {
                YAxisView(maxValue: maxValue)
                    .frame(width: 40, height: graphHeight)

                ScrollViewReader { scrollProxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        VStack(spacing: 0) {
                            Color.clear.frame(width: 0, height: 0).id("GraphStart")

                            ZStack {
                                GridLinesView(maxValue: maxValue,
                                              chartSize: CGSize(width: fullChartWidth, height: graphHeight),
                                              xSpacing: effectiveXSpacing)

                                LinePathView(dataPoints: dataPoints,
                                             xSpacing: effectiveXSpacing,
                                             maxValue: maxValue)
                                    .stroke(Color.surfaceColor, lineWidth: 3)
                            }
                            .frame(width: measuredWidth, height: graphHeight)
                            .id("GraphContent")

                            XAxisView(elapsedTime: elapsedTime, xSpacing: effectiveXSpacing)
                                .frame(width: measuredWidth, height: 30)
                        }
                    }
                    .onChange(of: Int(elapsedTime * 10)) { _ in
                        withAnimation {
                            if measuredWidth > visibleWidth {
                                scrollProxy
                                    .scrollTo("GraphContent", anchor: .trailing)
                            } else {
                                scrollProxy
                                    .scrollTo("GraphStart", anchor: .leading)
                            }
                        }
                    }
                    .gesture(MagnificationGesture()
                        .onChanged { value in
                            zoomScale = lastZoomScale * value
                        }
                        .onEnded { _ in
                            lastZoomScale = zoomScale
                        }
                    )
                }
            }
        }
        .padding(.vertical, 40)
        .padding(.horizontal)
    }
}

// MARK: - Supporting Views

struct LinePathView: Shape {
    var dataPoints: [CGPoint]
    let xSpacing: CGFloat
    let maxValue: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard let first = dataPoints.first else { return path }
        let scaleY = rect.height / CGFloat(maxValue * 2)
        let offset = first.x

        let startY = rect.height / 2 - CGFloat(first.y) * scaleY
        path.move(to: CGPoint(x: 0, y: startY))

        for point in dataPoints {
            let x = CGFloat(point.x - offset) * xSpacing
            let y = rect.height / 2 - CGFloat(point.y) * scaleY
            path.addLine(to: CGPoint(x: x, y: y))
        }
        return path
    }
}

struct YAxisView: View {
    let maxValue: Double

    var body: some View {
        GeometryReader { geo in
            let h = geo.size.height
            ForEach(0...5, id: \.self) { i in
                let value = maxValue - (Double(i) * maxValue * 2 / 5)
                Text("\(Int(value))")
                    .font(.captionFont)
                    .position(x: geo.size.width / 2, y: h * CGFloat(i) / 5)
            }
        }
    }
}

struct XAxisView: View {
    let elapsedTime: Double
    let xSpacing: CGFloat

    var body: some View {
        let totalSeconds = Int(ceil(elapsedTime))
        HStack(spacing: 0) {
            ForEach(0...totalSeconds, id: \.self) { sec in
                if sec == 0 {
                    EmptyView()
                } else {
                    Text("\(sec)s")
                        .font(.captionFont)
                        .frame(width: xSpacing, alignment: .center)
                }
            }
        }
    }
}

struct GridLinesView: View {
    let maxValue: Double
    let chartSize: CGSize
    let xSpacing: CGFloat

    var body: some View {
        Path { path in
            let height = chartSize.height
            let width = chartSize.width
            let horizontalSegments = 5

            for i in 0...horizontalSegments {
                let y = height * CGFloat(i) / CGFloat(horizontalSegments)
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: width, y: y))
            }

            let verticalLines = Int(width / xSpacing)
            for i in 0...verticalLines {
                let x = CGFloat(i) * xSpacing
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: height))
            }
        }
        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
    }
}


//#Preview {
//    StatefulPreviewWrapper(30.0) { elapsed in
//        LineChartView(elapsedTime: elapsed, isRealtimeMode: false)
//            .environmentObject(WaveformViewModel())
//    }
//}
