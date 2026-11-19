import SwiftUI

struct ChessKingShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height

        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * w, y: rect.minY + y * h)
        }

        func box(_ x0: CGFloat, _ y0: CGFloat, _ x1: CGFloat, _ y1: CGFloat, radius: CGFloat) -> Path {
            Path(roundedRect: CGRect(x: rect.minX + x0 * w, y: rect.minY + y0 * h,
                                     width: (x1 - x0) * w, height: (y1 - y0) * h),
                 cornerRadius: radius * w)
        }

        var path = Path()

        path.addPath(box(0.455, 0.00, 0.545, 0.32, radius: 0.02))
        path.addPath(box(0.37, 0.06, 0.63, 0.14, radius: 0.02))

        var leftCrown = Path()
        leftCrown.move(to: point(0.25, 0.43))
        leftCrown.addCurve(to: point(0.36, 0.23), control1: point(0.22, 0.30), control2: point(0.27, 0.23))
        leftCrown.addCurve(to: point(0.485, 0.31), control1: point(0.43, 0.23), control2: point(0.465, 0.27))
        leftCrown.addLine(to: point(0.485, 0.43))
        leftCrown.closeSubpath()
        path.addPath(leftCrown)

        var rightCrown = Path()
        rightCrown.move(to: point(0.75, 0.43))
        rightCrown.addCurve(to: point(0.64, 0.23), control1: point(0.78, 0.30), control2: point(0.73, 0.23))
        rightCrown.addCurve(to: point(0.515, 0.31), control1: point(0.57, 0.23), control2: point(0.535, 0.27))
        rightCrown.addLine(to: point(0.515, 0.43))
        rightCrown.closeSubpath()
        path.addPath(rightCrown)

        path.addPath(box(0.24, 0.43, 0.76, 0.50, radius: 0.03))
        path.addPath(box(0.40, 0.50, 0.60, 0.58, radius: 0.02))
        path.addPath(box(0.30, 0.58, 0.70, 0.65, radius: 0.035))

        var body = Path()
        body.move(to: point(0.38, 0.65))
        body.addLine(to: point(0.62, 0.65))
        body.addCurve(to: point(0.74, 0.82), control1: point(0.62, 0.72), control2: point(0.70, 0.77))
        body.addLine(to: point(0.26, 0.82))
        body.addCurve(to: point(0.38, 0.65), control1: point(0.30, 0.77), control2: point(0.38, 0.72))
        body.closeSubpath()
        path.addPath(body)

        path.addPath(box(0.20, 0.82, 0.80, 0.89, radius: 0.035))
        path.addPath(box(0.12, 0.89, 0.88, 1.00, radius: 0.05))

        return path
    }
}

struct ChessKingView: View {
    var body: some View {
        ChessKingShape()
            .fill(
                LinearGradient(
                    colors: [Color(hex: 0xF1E6D6), Color.podiumBeige],
                    startPoint: .top, endPoint: .bottom
                )
            )
            .overlay(ChessKingShape().stroke(Color.podiumCopper.opacity(0.5), lineWidth: 0.8))
    }
}
