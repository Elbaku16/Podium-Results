import SwiftUI

struct AddPlayerView: View {
    let existingNames: [String]
    let hasSchedule: Bool
    let onAdd: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @FocusState private var isFocused: Bool

    private var trimmed: String { name.trimmingCharacters(in: .whitespaces) }

    private var isDuplicate: Bool {
        existingNames.contains { $0.lowercased() == trimmed.lowercased() }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.podiumCharcoal.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 12) {
                    Text("PLAYER NAME")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.podiumMuted)

                    TextField("Name", text: $name, prompt: Text("Name").foregroundStyle(Color.podiumMuted))
                        .focused($isFocused)
                        .foregroundStyle(.white)
                        .padding(16)
                        .background(Color.white.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .onSubmit(save)

                    if isDuplicate {
                        Text("There is already a player with that name.")
                            .font(.caption)
                            .foregroundStyle(Color.podiumCopper)
                    } else if hasSchedule {
                        Text("The new player gets one extra round against each current player.")
                            .font(.caption)
                            .foregroundStyle(Color.podiumMuted)
                    }

                    Spacer()
                }
                .padding(16)
            }
            .navigationTitle("Add Player")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.podiumCharcoal, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add", action: save)
                        .fontWeight(.semibold)
                        .disabled(trimmed.isEmpty || isDuplicate)
                }
            }
            .onAppear { isFocused = true }
        }
        .tint(.podiumCopper)
        .presentationDetents([.medium])
    }

    private func save() {
        guard !trimmed.isEmpty, !isDuplicate else { return }
        onAdd(trimmed)
        dismiss()
    }
}
