//
//  RealtimeLineChartView.swift
//  ecg
//
//  Created by insung on 4/30/25.
//

import SwiftUI

struct LineChartView: View {
    @EnvironmentObject var viewModel: WaveformViewModel
    
    @Binding var elapsedTime: Double
    
    @State private var isRealtimeMode: Bool = true
    // 측정 데이터: x는 시간(초), y는 0~100 사이 랜덤값
    @State private var dataPoints: [CGPoint] = []
    @State private var isMeasuring: Bool = true

    // 줌(scale) 관련 상태 (측정 중에는 제스처 비활성화)
    @State private var zoomScale: CGFloat = 1.0
    @State private var lastZoomScale: CGFloat = 1.0

    // 전체 측정 시간 및 타이머 간격
    let measurementDuration: Double = 30.0
    let timerInterval: Double = 0.2

    let maxValue: Double = 10000          // Y축 최대값 (0 ~ 100)
    let xSpacing: CGFloat = 50.0        // 기본 1초당 픽셀 수

    var body: some View {
        GeometryReader { geometry in
            // zoom 반영된 effectiveXSpacing
            let effectiveXSpacing = xSpacing * zoomScale
            // grid는 전체 측정Duration(30초) 기준으로 미리 그립니다.
            let fullChartWidth = CGFloat(Int(ceil(measurementDuration))) * effectiveXSpacing
            let graphHeight = geometry.size.height
            // 실제 데이터 영역의 너비는 elapsedTime에 따라 결정 (최소 1초)
            let measuredWidth = CGFloat(max(Int(ceil(elapsedTime)), 1)) * effectiveXSpacing
            let visibleWidth = geometry.size.width
            
            let lastTimestamp = viewModel.waveforms.last?.timestamp ?? Date()
            
            // (x: elapsedTime from lastTimestamp, y: lead1)
            let points: [CGPoint] = viewModel.waveforms.compactMap { wf in
                let x = lastTimestamp.timeIntervalSince(
                    wf.timestamp
                )  // 역방향 (최신 = 0)
                guard x <= measurementDuration else {
                    return nil
                }             // 30초 초과 데이터 제거
                return CGPoint(
                    x: measurementDuration - x,
                    y: Double(wf.lead1)
                ) // 최신 = 오른쪽
            }.sorted { $0.x < $1.x }  // x 오름차순 정렬
            
            HStack(alignment: .top, spacing: 0) {
                // 좌측 Y축: 0부터 maxValue까지 표시 (0은 하단 중앙)
                YAxisView(maxValue: maxValue)
                    .frame(width: 40, height: graphHeight)
                
                ScrollViewReader { scrollProxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        VStack(spacing: 0) {
                            // 초기 스크롤 위치를 지정하는 더미 뷰 (좌측 끝=0초)
                            Color.clear.frame(width: 0, height: 0)
                                .id("GraphStart")
                            
                            // 그래프 영역: 먼저 GridLinesView를 그리고 그 위에 선 그래프(LinePathView)를 표시
                            ZStack {
                                GridLinesView(maxValue: maxValue,
                                              chartSize: CGSize(width: fullChartWidth, height: graphHeight))
                                
                                LinePathView(dataPoints: dataPoints,
                                             xSpacing: effectiveXSpacing,
                                             maxValue: maxValue)
                                    .stroke(Color.surfaceColor, lineWidth: 3)
                            }
                            // 실제 데이터 영역은 measuredWidth만큼 표시됨
                            .frame(width: measuredWidth, height: graphHeight)
                            .id("GraphContent")
                            
                            // X축 레이블: HStack을 사용하여 1초부터 정수 단위로 표시 (1s, 2s, …)
                            XAxisView(elapsedTime: elapsedTime, xSpacing: effectiveXSpacing)
                                .frame(width: measuredWidth, height: 30)
                        }
                    }

                    // 데이터 갱신 시, 영역이 보이는 폭보다 넓으면 최신 데이터쪽으로 스크롤
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
                }
            }
        }
        .padding(.vertical, 40)
        .padding(.horizontal)
    }
    
    func setEntireData(_ points: [CGPoint]) {
        isMeasuring = false
        dataPoints = points
        elapsedTime = Double(points.last?.x ?? 0.0)
    }
    
    // 측정 시작 시 0초 데이터 포인트를 즉시 추가한 후, 0.2초마다 새 랜덤 데이터를 추가합니다.
    func startMeasurement() {
        dataPoints.removeAll()
        elapsedTime = 0.0
        isMeasuring = true
        zoomScale = 1.0
        lastZoomScale = 1.0
        
        // 0초 데이터
        dataPoints.append(CGPoint(x: elapsedTime, y: Double.random(in: 0...maxValue)))
        
        Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { timer in
            elapsedTime += timerInterval
            if elapsedTime > measurementDuration {
                timer.invalidate()
                isMeasuring = false
            } else {
                let newValue = Double.random(in: 0...maxValue)
                dataPoints.append(CGPoint(x: elapsedTime, y: newValue))
            }
        }
    }
}

/// 선 그래프를 그리는 Shape
/// 각 데이터 포인트의 x좌표는 (point.x - 첫 데이터의 x) * xSpacing, y좌표는 (rect.height / maxValue)에 비례.
struct LinePathView: Shape {
    var dataPoints: [CGPoint]
    let xSpacing: CGFloat
    let maxValue: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard let first = dataPoints.first else { return path }
        let scaleY = rect.height / CGFloat(maxValue)
        let offset = first.x
        
        let startY = rect.height - CGFloat(first.y) * scaleY
        path.move(to: CGPoint(x: 0, y: startY))
        
        for point in dataPoints {
            let x = CGFloat(point.x - offset) * xSpacing
            let y = rect.height - CGFloat(point.y) * scaleY
            path.addLine(to: CGPoint(x: x, y: y))
        }
        return path
    }
}

/// YAxisView: Y축 레이블 뷰
/// GeometryReader를 사용해 0부터 maxValue까지의 값이 경계선(상단: 100, 하단: 0)에 정확히 위치하도록 함.
struct YAxisView: View {
    let maxValue: Double

    var body: some View {
        GeometryReader { geo in
            let H = geo.size.height
            ForEach(0...5, id: \.self) { i in
                let value = maxValue - (Double(i) * maxValue / 5)
                Text("\(Int(value))")
                    .font(.caption)
                    .position(x: geo.size.width / 2, y: H * CGFloat(i) / 5)
            }
        }
    }
}

/// XAxisView: X축 레이블 뷰
/// 측정된 elapsedTime가 1초 미만이면 레이블은 나타나지 않고,
/// 1초 이상일 때부터 HStack을 사용하여 "1s", "2s", … 등을 고정 폭(xSpacing) 내에서 중앙 정렬하여 표시합니다.
struct XAxisView: View {
    let elapsedTime: Double
    let xSpacing: CGFloat

    var body: some View {
        if elapsedTime < 1.2 {
            EmptyView().frame(height: 30)
        } else {
            let count = Int(elapsedTime)
            HStack(spacing: 0) {
                ForEach(1...count, id: \.self) { sec in
                    Text("\(sec)s")
                        .font(.caption)
                        .frame(width: xSpacing, alignment: .center)
                }
            }
            .frame(height: 30)
        }
    }
}

/// GridLinesView: 배경 Grid 뷰
/// 전체 그래프 영역(fullChartWidth, graphHeight)을 기준으로 수평선 5개와 1초 단위 수직 그리드를 그립니다.
struct GridLinesView: View {
    let maxValue: Double
    let chartSize: CGSize

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
            // 수직 그리드선: 매 1초마다(기본 50픽셀 단위) 그립니다.
            let verticalLines = Int(width / 50)
            for i in 0...verticalLines {
                let x = CGFloat(i) * 50
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: height))
            }
        }
        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
    }
}

#Preview {
    StatefulPreviewWrapper(0) { value in
        LineChartView(elapsedTime: value)
            .environmentObject(WaveformViewModel())
    }
}

