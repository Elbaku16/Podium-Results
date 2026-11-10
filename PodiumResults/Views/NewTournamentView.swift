import SwiftUI
import SwiftData

struct NewTournamentView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var name = ""
    @State private var location = ""
    @State private var timeControl = ""
    @State private var arbiter = ""
    @State private var categories = ""
    @State private var playerNames: [String] = []
    @State private var newPlayerName = ""
    @FocusState private var isPlayerFieldFocused: Bool

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && playerNames.count >= 2
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.podiumCharcoal.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("TOURNAMENT")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.podiumMuted)
                            TextField("Name", text: $name, prompt: Text("Name").foregroundStyle(Color.podiumMuted))
                                .textFieldStyle(.plain)
                                .foregroundStyle(.white)
                            Divider().overlay(.white.opacity(0.07))
                            TextField("Location", text: $location, prompt: Text("Location").foregroundStyle(Color.podiumMuted))
                                .textFieldStyle(.plain)
                                .foregroundStyle(.white)
                            Divider().overlay(.white.opacity(0.07))
                            TextField("Time control, e.g. 90 min + 30 sec", text: $timeControl, prompt: Text("Time control, e.g. 90 min + 30 sec").foregroundStyle(Color.podiumMuted))
                                .textFieldStyle(.plain)
                                .foregroundStyle(.white)
                            Divider().overlay(.white.opacity(0.07))
                            TextField("Arbiter / organizer", text: $arbiter, prompt: Text("Arbiter / organizer").foregroundStyle(Color.podiumMuted))
                                .textFieldStyle(.plain)
                                .foregroundStyle(.white)
                            Divider().overlay(.white.opacity(0.07))
                            TextField("Categories, e.g. Open, U16, U12", text: $categories, prompt: Text("Categories, e.g. Open, U16, U12").foregroundStyle(Color.podiumMuted))
                                .textFieldStyle(.plain)
                                .foregroundStyle(.white)
                            Divider().overlay(.white.opacity(0.07))
                            HStack {
                                Text("Format")
                                    .foregroundStyle(.white)
                                Spacer()
                                Text("Round Robin")
                                    .foregroundStyle(Color.podiumMuted)
                            }
                        }
                        .cardBackground(Color.white.opacity(0.06))

                        VStack(alignment: .leading, spacing: 10) {
                            Text("PLAYERS (\(playerNames.count))")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.podiumMuted)

                            ForEach(playerNames, id: \.self) { player in
                                HStack {
                                    PlayerAvatar(name: player, size: 28)
                                    Text(player)
                                        .foregroundStyle(.white)
                                    Spacer()
                                    Button {
                                        playerNames.removeAll { $0 == player }
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(Color.podiumMuted)
                                    }
                                }
                                if player != playerNames.last {
                                    Divider().overlay(.white.opacity(0.07))
                                }
                            }

                            if !playerNames.isEmpty {
                                Divider().overlay(.white.opacity(0.07))
                            }

                            HStack {
                                TextField("Add a player", text: $newPlayerName, prompt: Text("Add a player").foregroundStyle(Color.podiumMuted))
                                    .textFieldStyle(.plain)
                                .foregroundStyle(.white)
                                    .focused($isPlayerFieldFocused)
                                    .onSubmit { addPlayer() }
                                Button {
                                    addPlayer()
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundStyle(Color.podiumCopper)
                                }
                                .disabled(newPlayerName.trimmingCharacters(in: .whitespaces).isEmpty)
                            }
                        }
                        .cardBackground(Color.white.opacity(0.06))

                        if playerNames.count < 2 {
                            Text("Add at least 2 players to save the tournament.")
                                .font(.caption)
                                .foregroundStyle(Color.podiumMuted)
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("New Tournament")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.podiumCharcoal, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTournament()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!canSave)
                }
            }
        }
        .tint(.podiumCopper)
    }

    private func addPlayer() {
        let trimmed = newPlayerName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        playerNames.append(trimmed)
        newPlayerName = ""
        isPlayerFieldFocused = true
    }

    private func saveTournament() {
        let tournament = Tournament(name: name.trimmingCharacters(in: .whitespaces),
                                     location: location.trimmingCharacters(in: .whitespaces),
                                     timeControl: timeControl.trimmingCharacters(in: .whitespaces),
                                     arbiter: arbiter.trimmingCharacters(in: .whitespaces),
                                     categories: categories.trimmingCharacters(in: .whitespaces))
        modelContext.insert(tournament)
        for playerName in playerNames {
            let player = Player(name: playerName)
            player.tournament = tournament
            modelContext.insert(player)
        }
    }
}

#Preview {
    NewTournamentView()
        .modelContainer(for: [Tournament.self, Player.self, Match.self], inMemory: true)
}

