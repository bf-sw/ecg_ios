import SwiftUI

struct LineChartView: View {
    var title: String
    var showAxis: Bool = true
    @Binding var dataPoints: [CGPoint]
    var chartHeight: CGFloat = 300

    let yMin: CGFloat = -5000
    let yMax: CGFloat = 5000
    let yGridCount: Int = 5
    let xGridSpacing: CGFloat = 100
    let yLabelWidth: CGFloat = 40

    @State private var baseSpacing: CGFloat = 1.0
    @GestureState private var magnifyBy: CGFloat = 1.0

    var body: some View {
        let currentSpacing = max(0.5, min(baseSpacing * magnifyBy, 5.0)) // 제한 줌 배율

        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .padding(.leading, 4)

            HStack(spacing: 0) {
                if showAxis {
                    // Y축 라벨
                    VStack(spacing: 0) {
                        ForEach(yLabelValues(), id: \.self) { value in
                            Text("\(Int(value))")
                                .font(.caption2)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .frame(height: chartHeight / CGFloat(yGridCount))
                        }
                    }
                    .frame(width: yLabelWidth)
                }

                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        let chartWidth = CGFloat(max(dataPoints.count, 1)) * currentSpacing

                        HStack(spacing: 0) {
                            Canvas { context, size in
                                drawGrid(context: &context, size: size, spacing: currentSpacing)
                                drawLine(context: &context, size: size, spacing: currentSpacing)
                            }
                            .frame(width: chartWidth, height: chartHeight)

                            Color.clear
                                .frame(width: 1, height: 1)
                                .id(dataPoints.count - 1)
                        }
                    }
                    .frame(height: chartHeight)
                    .onChange(of: dataPoints.count) { newValue in
                        withAnimation {
                            proxy.scrollTo(newValue - 1, anchor: .trailing)
                        }
                    }
                    .gesture(
                        MagnificationGesture()
                            .updating($magnifyBy) { value, state, _ in
                                state = value
                            }
                            .onEnded { value in
                                let newScale = baseSpacing * value
                                baseSpacing = max(0.5, min(newScale, 5.0))
                            }
                    )
                }
            }
        }
    }

    func yLabelValues() -> [CGFloat] {
        let step = (yMax - yMin) / CGFloat(yGridCount)
        return (0...yGridCount).map { yMax - CGFloat($0) * step }
    }

    func drawGrid(context: inout GraphicsContext, size: CGSize, spacing: CGFloat) {
        let yStep = size.height / CGFloat(yGridCount)
        let yLines = stride(from: 0, through: size.height, by: yStep)
        let xLines = stride(from: 0, through: size.width, by: xGridSpacing * spacing)

        var path = Path()
        for y in yLines {
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: size.width, y: y))
        }

        for x in xLines {
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: size.height))
        }

        context.stroke(path, with: .color(.gray.opacity(0.3)), lineWidth: 1)
    }
    
    func drawLine(context: inout GraphicsContext, size: CGSize, spacing: CGFloat) {
        guard dataPoints.count > 1 else { return }

        let scaleY = size.height / (yMax - yMin)

        var path = Path()
        let first = dataPoints[0]
        let x0 = CGFloat(0)
        let y0 = size.height - ((CGFloat(first.y) - yMin) * scaleY)
        path.move(to: CGPoint(x: x0, y: y0))

        for (i, point) in dataPoints.enumerated() {
            let x = CGFloat(i) * spacing
            let y = size.height - ((CGFloat(point.y) - yMin) * scaleY)
            path.addLine(to: CGPoint(x: x, y: y))
        }

        context.stroke(path, with: .color(.customSurface), lineWidth: 2)
    }
}
