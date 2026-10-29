import SwiftUI

struct ConfettiView: View {
    private struct Piece: Identifiable {
        let id = UUID()
        var x: CGFloat
        var color: Color
        var rotation: Double
        var delay: Double
    }

    @State private var pieces: [Piece] = []

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(pieces) { piece in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(piece.color)
                        .frame(width: 8, height: 14)
                        .rotationEffect(.degrees(piece.rotation))
                        .position(x: piece.x, y: 0)
                        .modifier(FallDown(height: geo.size.height, delay: piece.delay))
                }
            }
            .onAppear {
                pieces = (0..<26).map { _ in
                    Piece(
                        x: .random(in: 20...max(40, geo.size.width - 20)),
                        color: [Color.boardGreen, .boardGold, .boardGreenLight, .boardBronze].randomElement()!,
                        rotation: .random(in: 0...360),
                        delay: .random(in: 0...0.2)
                    )
                }
            }
        }
        .allowsHitTesting(false)
    }

    private struct FallDown: ViewModifier {
        let height: CGFloat
        let delay: Double
        @State private var animate = false

        func body(content: Content) -> some View {
            content
                .offset(y: animate ? height + 60 : -20)
                .opacity(animate ? 0 : 1)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.1).delay(delay)) {
                        animate = true
                    }
                }
        }
    }
}

