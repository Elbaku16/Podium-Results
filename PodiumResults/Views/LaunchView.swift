import SwiftUI

struct LaunchView: View {
    @State private var isShown = false

    var body: some View {
        ZStack {
            Color.podiumCharcoal.ignoresSafeArea()

            VStack(spacing: 18) {
                BrandLogo(width: 190)
                    .scaleEffect(isShown ? 1 : 0.85)
                    .opacity(isShown ? 1 : 0)

                Capsule()
                    .fill(Color.podiumCopper)
                    .frame(width: isShown ? 64 : 0, height: 3)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.9)) { isShown = true }
        }
    }
}

#Preview {
    LaunchView()
}
