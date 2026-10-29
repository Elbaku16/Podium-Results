import SwiftUI
import Combine

struct ChessTravelAnimation: View {
    var progress: Double? = nil

    private let squareCount = 7
    @State private var stepIndex = 0
    @State private var isHopping = false
    @State private var sparkleOpacity: Double = 0
    @State private var sparkleScale: CGFloat = 0.4
    @State private var tapBounce = false

    private let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geo in
            let squareSize = geo.size.width / CGFloat(squareCount)

            ZStack(alignment: .bottomLeading) {
                HStack(spacing: 0) {
                    ForEach(0..<squareCount, id: \.self) { i in
                        Rectangle()
                            .fill(i.isMultiple(of: 2) ? Color.podiumBeige.opacity(0.9) : Color.podiumEspresso.opacity(0.95))
                            .frame(width: squareSize, height: squareSize)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color.podiumCopper.opacity(0.4), lineWidth: 1))

                Image(systemName: "trophy.fill")
                    .font(.system(size: squareSize * 0.4))
                    .foregroundStyle(Color.podiumCopper.opacity(0.8))
                    .frame(width: squareSize, height: squareSize)
                    .offset(x: CGFloat(squareCount - 1) * squareSize)

                ZStack {
                    sparkleBurst
                    Image(systemName: "crown.fill")
                        .font(.system(size: squareSize * 0.52))
                        .foregroundStyle(Color.podiumCream)
                        .shadow(color: .black.opacity(0.4), radius: 3, y: 2)
                }
                .frame(width: squareSize, height: squareSize)
                .scaleEffect(tapBounce ? 1.35 : 1)
                .offset(x: CGFloat(stepIndex) * squareSize, y: isHopping ? -squareSize * 0.65 : 0)
                .onTapGesture { bounceFromTap() }
            }
        }
        .frame(height: 54)
        .onAppear { syncToProgress() }
        .onChange(of: progress) { _, _ in syncToProgress() }
        .onReceive(timer) { _ in
            guard progress == nil else { return }
            hop()
        }
    }

    private func syncToProgress() {
        guard let progress else { return }
        let target = Int((progress * Double(squareCount - 1)).rounded())
        withAnimation(.interpolatingSpring(stiffness: 140, damping: 16)) {
            stepIndex = target
        }
    }

    private var sparkleBurst: some View {
        ForEach(0..<6, id: \.self) { i in
            Circle()
                .fill(Color.podiumCopper)
                .frame(width: 4, height: 4)
                .offset(sparkleOffset(for: i))
                .scaleEffect(sparkleScale)
                .opacity(sparkleOpacity)
        }
    }

    private func sparkleOffset(for index: Int) -> CGSize {
        let angle = Double(index) / 6 * 2 * .pi
        return CGSize(width: cos(angle) * 22 * sparkleScale, height: sin(angle) * 22 * sparkleScale)
    }

    private func hop() {
        withAnimation(.easeOut(duration: 0.18)) { isHopping = true }
        withAnimation(.easeIn(duration: 0.18).delay(0.18)) { isHopping = false }
        withAnimation(.interpolatingSpring(stiffness: 180, damping: 14)) {
            stepIndex = (stepIndex + 1) % squareCount
        }
    }

    private func bounceFromTap() {
        withAnimation(.easeOut(duration: 0.12)) { tapBounce = true }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.4).delay(0.12)) { tapBounce = false }

        sparkleOpacity = 1
        sparkleScale = 0.4
        withAnimation(.easeOut(duration: 0.4)) {
            sparkleScale = 1.3
            sparkleOpacity = 0
        }
    }
}

#Preview {
    ChessTravelAnimation()
        .padding(24)
        .background(Color.podiumCharcoal)
}

