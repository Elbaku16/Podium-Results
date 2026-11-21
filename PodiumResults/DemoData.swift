#if DEBUG
import SwiftUI
import SwiftData

private struct SilentNotifier: NotificationServiceProtocol {
    func isAllowed() async -> Bool { false }
    func requestPermission() async -> Bool { false }
    func deliver(title: String, body: String) {}
}

private struct SeededRandom {
    private var state: UInt64

    init(seed: UInt64) { state = seed }

    mutating func next() -> Double {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return Double(state >> 33) / Double(1 << 31)
    }
}

enum DemoData {
    static func reset(in context: ModelContext) {
        try? context.delete(model: Tournament.self)
        try? context.delete(model: AppNotification.self)

        let silent = TournamentDetailViewModel(modelContext: context, notifier: SilentNotifier())
        var random = SeededRandom(seed: 25)

        let test = makeTournament(
            "Test Tournament", date: day(18), location: "", timeControl: "10 min + 5 sec",
            players: [("Ana", 1750), ("Beto", 1620), ("Carla", 1580), ("Diego", 1490)], in: context
        )
        silent.generateSchedule(for: test)
        play(test, rounds: 1...3, extraGames: 0, with: silent, random: &random)

        let cetis = makeTournament(
            "Tournament Cetis 25", date: day(20), location: "CETIS 25", timeControl: "15 min + 10 sec",
            players: [
                ("Ana Torres", 1820), ("Luis Ram\u{00ED}rez", 1760), ("Carla Mendoza", 1710), ("Diego Herrera", 1690),
                ("Sof\u{00ED}a Vargas", 1640), ("Mateo Cruz", 1600), ("Valeria Ortiz", 1570), ("Emilio Salazar", 1540),
                ("Camila Reyes", 1510), ("Santiago Lara", 1480), ("Daniela Pineda", 1450), ("Andr\u{00E9}s Navarro", 1420),
                ("Fernanda R\u{00ED}os", 1390), ("Joaqu\u{00ED}n Castillo", 1360), ("Regina Montes", 1330), ("Iv\u{00E1}n Aguilar", 1300),
            ], in: context
        )
        silent.generateSchedule(for: cetis)
        play(cetis, rounds: 1...7, extraGames: 3, with: silent, random: &random)

        try? context.save()
        let generated = (try? context.fetch(FetchDescriptor<AppNotification>())) ?? []
        generated.forEach(context.delete)
        try? context.save()
    }

    private static func day(_ number: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: 2026, month: 11, day: number, hour: 9)) ?? .now
    }

    private static func makeTournament(_ name: String, date: Date, location: String, timeControl: String,
                                       players: [(String, Int)], in context: ModelContext) -> Tournament {
        let tournament = Tournament(name: name, date: date, location: location, timeControl: timeControl,
                                    arbiter: "Lenin Cortez", categories: "Open")
        context.insert(tournament)
        for (playerName, _) in players {
            let player = Player(name: playerName)
            player.tournament = tournament
            context.insert(player)
        }
        ratings[name] = Dictionary(uniqueKeysWithValues: players.map { ($0.0, $0.1) })
        return tournament
    }

    private static var ratings: [String: [String: Int]] = [:]

    private static func play(_ tournament: Tournament, rounds: ClosedRange<Int>, extraGames: Int,
                             with viewModel: TournamentDetailViewModel, random: inout SeededRandom) {
        let table = ratings[tournament.name] ?? [:]
        var games = tournament.matches
            .filter { rounds.contains($0.round) && $0.player2 != nil }
            .sorted { $0.round < $1.round }
        let nextRound = (rounds.upperBound + 1)
        games += tournament.matches.filter { $0.round == nextRound && $0.player2 != nil }.prefix(extraGames)

        for match in games {
            guard let white = match.player1, let black = match.player2 else { continue }
            let gap = Double((table[white.name] ?? 1500) - (table[black.name] ?? 1500))
            let whiteExpected = 1 / (1 + pow(10, -gap / 400))
            let roll = random.next()
            let drawChance = 0.22
            let result: (Double, Double)
            if roll < drawChance {
                result = (0.5, 0.5)
            } else if (roll - drawChance) / (1 - drawChance) < whiteExpected {
                result = (1, 0)
            } else {
                result = (0, 1)
            }
            viewModel.recordResult(for: match, score1: result.0, score2: result.1)
        }
    }
}

private struct DemoSeedModifier: ViewModifier {
    @Environment(\.modelContext) private var context

    func body(content: Content) -> some View {
        content.task {
            guard ProcessInfo.processInfo.arguments.contains("-seedDemoData") else { return }
            DemoData.reset(in: context)
        }
    }
}

extension View {
    @ViewBuilder
    func seedDemoDataIfRequested() -> some View {
        modifier(DemoSeedModifier())
    }
}
#else
import SwiftUI

extension View {
    func seedDemoDataIfRequested() -> some View { self }
}
#endif
