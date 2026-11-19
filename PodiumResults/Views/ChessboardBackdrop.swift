import SwiftUI

struct ChessboardBackdrop: View {
    private let dark = Color(hex: 0x2A1F1A)
    private let light = Color(hex: 0x3C2D24)

    var body: some View {
        Canvas { context, size in
            let square: CGFloat = 54
            context.translateBy(x: size.width * 0.62, y: -size.height * 0.1)
            context.rotate(by: .degrees(-24))
            context.scaleBy(x: 1, y: 0.72)

            for row in -2..<14 {
                for column in -8..<8 {
                    let rect = CGRect(x: CGFloat(column) * square, y: CGFloat(row) * square,
                                      width: square, height: square)
                    let isLight = (row + column).isMultiple(of: 2)
                    context.fill(Path(rect), with: .color(isLight ? light : dark))
                }
            }
        }
        .mask(
            LinearGradient(
                stops: [
                    .init(color: .black.opacity(0.85), location: 0),
                    .init(color: .black.opacity(0.4), location: 0.55),
                    .init(color: .clear, location: 1),
                ],
                startPoint: .topTrailing, endPoint: .bottomLeading
            )
        )
        .allowsHitTesting(false)
    }
}
