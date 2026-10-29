import SwiftUI

struct HomeEmptyHeroView: View {
    let onCreateTournament: () -> Void

    var body: some View {
        ZStack {
            Image("ChessBackdrop")
                .resizable()
                .scaledToFill()
                .frame(height: 320)
                .clipped()
                .saturation(0.7)

            LinearGradient(
                colors: [Color.podiumCharcoal.opacity(0.35), Color.podiumCharcoal.opacity(0.98)],
                startPoint: .top, endPoint: .bottom
            )
            .frame(height: 320)

            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Your competition\nstarts here")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                        .lineSpacing(2)
                    Text("Create a tournament to generate pairings, track rounds, and publish real standings.")
                        .font(.subheadline)
                        .foregroundStyle(Color.podiumMuted)
                        .frame(maxWidth: 280, alignment: .leading)
                }

                Button(action: onCreateTournament) {
                    Text("+ Create Tournament")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 13)
                        .background(Color.podiumCopper)
                        .clipShape(Capsule())
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
            .frame(height: 320, alignment: .bottom)
        }
        .frame(height: 320)
    }
}
