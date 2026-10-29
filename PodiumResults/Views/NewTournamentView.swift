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
                Color.podiumCream.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("TOURNAMENT")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                            TextField("Name", text: $name)
                                .textFieldStyle(.plain)
                            Divider()
                            TextField("Location", text: $location)
                                .textFieldStyle(.plain)
                            Divider()
                            TextField("Time control, e.g. 90 min + 30 sec", text: $timeControl)
                                .textFieldStyle(.plain)
                            Divider()
                            TextField("Arbiter / organizer", text: $arbiter)
                                .textFieldStyle(.plain)
                            Divider()
                            TextField("Categories, e.g. Open, U16, U12", text: $categories)
                                .textFieldStyle(.plain)
                            Divider()
                            HStack {
                                Text("Format")
                                Spacer()
                                Text("Round Robin")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .cardBackground()

                        VStack(alignment: .leading, spacing: 10) {
                            Text("PLAYERS (\(playerNames.count))")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)

                            ForEach(playerNames, id: \.self) { player in
                                HStack {
                                    PlayerAvatar(name: player, size: 28)
                                    Text(player)
                                    Spacer()
                                    Button {
                                        playerNames.removeAll { $0 == player }
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                if player != playerNames.last {
                                    Divider()
                                }
                            }

                            if !playerNames.isEmpty {
                                Divider()
                            }

                            HStack {
                                TextField("Add a player", text: $newPlayerName)
                                    .textFieldStyle(.plain)
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
                        .cardBackground()

                        if playerNames.count < 2 {
                            Text("Add at least 2 players to save the tournament.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("New Tournament")
            .navigationBarTitleDisplayMode(.inline)
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

