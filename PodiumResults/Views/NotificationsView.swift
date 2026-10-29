import SwiftUI

struct NotificationsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.podiumCharcoal.ignoresSafeArea()

                VStack(spacing: 10) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 38))
                        .foregroundStyle(Color.podiumCopper)
                    Text("No Notifications Yet")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text("New rounds, results, and standings updates will show up here.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.podiumCharcoal, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .tint(.podiumCopper)
    }
}

#Preview {
    NotificationsView()
}

