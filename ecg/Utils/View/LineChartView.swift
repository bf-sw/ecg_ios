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

    var waveforms: [Waveform] = []
    var isRealtimeMode: Bool = true

    @State private var dataPoints: [CGPoint] = []
    @State private var isMeasuring: Bool = true

    @State private var zoomScale: CGFloat = 1.0
    @State private var lastZoomScale: CGFloat = 1.0
    @State private var timer: Timer?

    let measurementDuration: Double = 30.0
    let timerInterval: Double = 0.004
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
                    .onChange(of: dataPoints) { _ in
                        withAnimation {
                            if measuredWidth > visibleWidth {
                                scrollProxy.scrollTo("GraphContent", anchor: .trailing)
                            } else {
                                scrollProxy.scrollTo("GraphStart", anchor: .leading)
                            }
                        }
                    }
                    .gesture(isMeasuring ? nil : MagnificationGesture()
                        .onChanged { value in
                            zoomScale = lastZoomScale * value
                        }
                        .onEnded { _ in
                            lastZoomScale = zoomScale
                        }
                    )
                }
            }
            .onAppear {
                if isRealtimeMode {
                    startMeasurement()
                } else {
                    setEntireDataFromWaveforms(waveforms)
                }
            }
            .onDisappear {
                timer?.invalidate()
                timer = nil
                isMeasuring = false
            }
        }
        .padding(.vertical, 40)
        .padding(.horizontal)
    }
    
    func setEntireDataFromWaveforms(_ waveforms: [Waveform]) {
        isMeasuring = false

        // 최대 7500개로 제한 (30초, 1초당 250개)
        let maxWaveforms = 250 * 30
        let trimmedWaveforms = Array(waveforms.prefix(maxWaveforms))

        let points = trimmedWaveforms.enumerated().map { index, wf in
            let x = Double(index) * (1.0 / 250.0) // = 0.004초 간격
            return CGPoint(x: x, y: Double(wf.lead1))
        }

        dataPoints = points
        elapsedTime = 30 // ✅ x축은 항상 30초로 고정
    }

    func startMeasurement() {
        dataPoints.removeAll()
        elapsedTime = 0.0
        isMeasuring = true
        zoomScale = 1.0
        lastZoomScale = 1.0

        timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { t in
            elapsedTime += timerInterval
            if elapsedTime > measurementDuration {
                t.invalidate()
                timer = nil
                isMeasuring = false
                viewModel.isMeasurementFinished = true
            } else {
                if let latest = viewModel.waveforms.last {
                    let yValue = Double(latest.lead1)
                    dataPoints.append(CGPoint(x: elapsedTime, y: yValue))
                }
            }
        }
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
    let xSpacing: CGFloat // ✅ 추가

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

            let verticalLines = Int(width / xSpacing) // ✅ xSpacing 기반으로 조정
            for i in 0...verticalLines {
                let x = CGFloat(i) * xSpacing
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: height))
            }
        }
        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
    }
}

// MARK: - Preview

#Preview {
    StatefulPreviewWrapper(30.0) { elapsed in
        LineChartView(elapsedTime: elapsed, isRealtimeMode: false)
            .environmentObject(WaveformViewModel())
    }
}
