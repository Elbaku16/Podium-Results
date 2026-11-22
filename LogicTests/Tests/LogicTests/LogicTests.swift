import XCTest
import SwiftData
@testable import Logic

@MainActor
final class LogicTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!

    override func setUp() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Tournament.self, Player.self, Match.self, AppNotification.self, configurations: config)
        context = ModelContext(container)
    }

    private func makeTournament(players names: [String]) -> Tournament {
        let t = Tournament(name: "Test")
        context.insert(t)
        for n in names {
            let p = Player(name: n)
            p.tournament = t
            context.insert(p)
        }
        return t
    }

    private func vm() -> TournamentDetailViewModel { TournamentDetailViewModel(modelContext: context) }
    private func realGames(_ t: Tournament) -> [Match] { t.matches.filter { $0.player2 != nil } }

    // pairings
    func testRoundRobinEvenEveryonePlaysOnce() {
        let t = makeTournament(players: ["A", "B", "C", "D"])
        let p = RoundRobinPairingService().generateSchedule(for: t.players)
        XCTAssertEqual(p.count, 6)
        var seen = Set<Set<String>>()
        for x in p { let k: Set<String> = [x.player1.name, x.player2!.name]; XCTAssertFalse(seen.contains(k)); seen.insert(k) }
    }
    func testRoundRobinOddGivesByes() {
        let t = makeTournament(players: ["A", "B", "C"])
        let p = RoundRobinPairingService().generateSchedule(for: t.players)
        XCTAssertEqual(p.filter { $0.player2 == nil }.count, 3)
    }
    func testNobodyPlaysTwiceInTheSameRound() {
        let t = makeTournament(players: ["A", "B", "C", "D", "E", "F"])
        let p = RoundRobinPairingService().generateSchedule(for: t.players)
        for r in Set(p.map(\.round)) {
            let n = p.filter { $0.round == r }.flatMap { [$0.player1.name, $0.player2?.name].compactMap { $0 } }
            XCTAssertEqual(n.count, Set(n).count)
        }
    }
    // status and results
    func testStatusLifecycle() {
        let t = makeTournament(players: ["A", "B"])
        XCTAssertEqual(t.status, .upcoming)
        vm().generateSchedule(for: t)
        XCTAssertEqual(t.status, .upcoming)
        vm().recordResult(for: t.matches.first { $0.player2 != nil }!, score1: 1, score2: 0)
        XCTAssertEqual(t.status, .finished)
    }
    func testCorrectingResultDoesNotDoubleCount() {
        let t = makeTournament(players: ["A", "B"])
        vm().generateSchedule(for: t)
        let m = t.matches[0]
        vm().recordResult(for: m, score1: 1, score2: 0)
        vm().recordResult(for: m, score1: 0.5, score2: 0.5)
        XCTAssertEqual(m.player1!.score, 0.5); XCTAssertEqual(m.player2!.score, 0.5)
        vm().recordResult(for: m, score1: 0, score2: 1)
        XCTAssertEqual(m.player1!.score, 0); XCTAssertEqual(m.player2!.score, 1)
    }

    // late entry
    func testAddPlayerBeforeScheduleOnlyAddsPlayer() {
        let t = makeTournament(players: ["A", "B"])
        XCTAssertTrue(vm().addPlayer(named: "C", to: t))
        XCTAssertEqual(t.players.count, 3); XCTAssertTrue(t.matches.isEmpty)
    }
    func testAddPlayerBeforeAnyGameRegeneratesSchedule() {
        let t = makeTournament(players: ["A", "B", "C", "D"])
        vm().generateSchedule(for: t)
        XCTAssertTrue(vm().addPlayer(named: "E", to: t))
        XCTAssertEqual(t.players.map(\.score).reduce(0, +), 5)
        XCTAssertEqual(Set(t.matches.map(\.round)).count, 5)
        XCTAssertEqual(t.matches.count, 15, "5 rounds x (2 games + 1 bye), no old games left")
    }
    func testEntryRoundIsNextRoundAfterLastPlayed() {
        let t = makeTournament(players: ["A", "B", "C", "D"])
        vm().generateSchedule(for: t)
        XCTAssertNil(vm().entryRound(for: t))
        for m in t.matches.filter({ $0.round == 1 }) { vm().recordResult(for: m, score1: 1, score2: 0) }
        XCTAssertEqual(vm().entryRound(for: t), 2)
    }
    func testLateEntryKeepsPlayedRoundsAndGivesMissedRoundPoints() {
        let t = makeTournament(players: ["A", "B", "C", "D"])
        vm().generateSchedule(for: t)
        let r1 = t.matches.filter { $0.round == 1 }
        for m in r1 { vm().recordResult(for: m, score1: 1, score2: 0) }
        let before = r1.map { ($0.player1!.name, $0.player2!.name) }
        XCTAssertTrue(vm().addPlayer(named: "E", to: t, missedRoundPoints: 0.5))
        let e = t.players.first { $0.name == "E" }!
        let missed = t.matches.filter { $0.round == 1 && $0.player1?.id == e.id && $0.player2 == nil }
        XCTAssertEqual(missed.count, 1); XCTAssertEqual(missed.first?.score1, 0.5)
        for (i, m) in r1.enumerated() {
            XCTAssertEqual(m.player1!.name, before[i].0); XCTAssertEqual(m.player2!.name, before[i].1); XCTAssertTrue(m.isComplete)
        }
        XCTAssertFalse(realGames(t).contains { $0.round == 1 && ($0.player1?.id == e.id || $0.player2?.id == e.id) })
    }
    func testLateEntryWithZeroPoints() {
        let t = makeTournament(players: ["A", "B", "C", "D"])
        vm().generateSchedule(for: t)
        for m in t.matches.filter({ $0.round == 1 }) { vm().recordResult(for: m, score1: 1, score2: 0) }
        vm().addPlayer(named: "E", to: t, missedRoundPoints: 0)
        let e = t.players.first { $0.name == "E" }!
        XCTAssertEqual(t.matches.first { $0.round == 1 && $0.player1?.id == e.id }?.score1, 0)
    }
    func testFinishedTournamentRejectsPlayers() {
        let t = makeTournament(players: ["A", "B"])
        vm().generateSchedule(for: t)
        vm().recordResult(for: t.matches[0], score1: 1, score2: 0)
        XCTAssertFalse(vm().addPlayer(named: "C", to: t))
    }
    func testLateEntryPlaysFromNextRoundOnly() {
        let t = makeTournament(players: ["A", "B", "C", "D", "E", "F"])
        vm().generateSchedule(for: t)
        for m in t.matches.filter({ $0.round == 1 }) { vm().recordResult(for: m, score1: 1, score2: 0) }
        XCTAssertTrue(vm().addPlayer(named: "G", to: t, missedRoundPoints: 0))
        let g = t.players.first { $0.name == "G" }!
        let games = realGames(t).filter { $0.player1?.id == g.id || $0.player2?.id == g.id }
        XCTAssertFalse(games.isEmpty)
        XCTAssertTrue(games.allSatisfy { $0.round >= 2 })
        XCTAssertEqual(Set(games.map(\.round)).count, games.count)
        var opp = Set<UUID>()
        for m in games { let o = m.player1?.id == g.id ? m.player2!.id : m.player1!.id; XCTAssertFalse(opp.contains(o)); opp.insert(o) }
    }
    func testLateEntryNobodyPlaysTwiceInARound() {
        let t = makeTournament(players: ["A", "B", "C", "D", "E", "F"])
        vm().generateSchedule(for: t)
        for m in t.matches.filter({ $0.round == 1 }) { vm().recordResult(for: m, score1: 0.5, score2: 0.5) }
        vm().addPlayer(named: "G", to: t, missedRoundPoints: 0.5)
        for r in Set(t.matches.map(\.round)) {
            let n = t.matches.filter { $0.round == r }.flatMap { [$0.player1?.name, $0.player2?.name].compactMap { $0 } }
            XCTAssertEqual(n.count, Set(n).count, "round \(r)")
        }
    }
    func testLateEntryOddFieldFillsTheByes() {
        let t = makeTournament(players: ["A", "B", "C"])
        vm().generateSchedule(for: t)
        for m in t.matches.filter({ $0.round == 1 && $0.player2 != nil }) { vm().recordResult(for: m, score1: 1, score2: 0) }
        XCTAssertTrue(vm().addPlayer(named: "D", to: t, missedRoundPoints: 0))
        let d = t.players.first { $0.name == "D" }!
        let games = realGames(t).filter { $0.player1?.id == d.id || $0.player2?.id == d.id }
        XCTAssertEqual(games.count, 2); XCTAssertTrue(games.allSatisfy { !$0.isComplete })
    }
    func testLateEntryScoresStayConsistent() {
        let t = makeTournament(players: ["A", "B", "C", "D"])
        vm().generateSchedule(for: t)
        for m in t.matches.filter({ $0.round == 1 }) { vm().recordResult(for: m, score1: 1, score2: 0) }
        vm().addPlayer(named: "E", to: t, missedRoundPoints: 0.5)
        for p in t.players {
            let total = t.matches.reduce(0.0) { sum, m in
                guard m.isComplete else { return sum }
                if m.player2 == nil { return sum + (m.player1?.id == p.id ? m.score1 : 0) }
                if m.player1?.id == p.id { return sum + m.score1 }
                if m.player2?.id == p.id { return sum + m.score2 }
                return sum
            }
            XCTAssertEqual(p.score, total, accuracy: 0.001, "\(p.name)")
        }
    }
    func testAddPlayerRejectsEmptyAndDuplicates() {
        let t = makeTournament(players: ["Ana", "Beto"])
        XCTAssertFalse(vm().addPlayer(named: "   ", to: t)); XCTAssertFalse(vm().addPlayer(named: "ana", to: t))
        XCTAssertEqual(t.players.count, 2)
    }
    // tiebreaks
    func testStandingsOrderByScore() {
        let t = makeTournament(players: ["A", "B", "C"])
        vm().generateSchedule(for: t)
        for m in t.matches where m.player2 != nil { vm().recordResult(for: m, score1: 1, score2: 0) }
        let s = TiebreakCalculator.standings(for: t)
        XCTAssertTrue(zip(s, s.dropFirst()).allSatisfy { $0.score >= $1.score })
    }
    // auth
    final class MockAuth: AuthServiceProtocol {
        var currentUser: AuthUser?; var failWith: String?
        func signUp(name: String, email: String, password: String) async throws -> AuthUser {
            if let failWith { throw AuthServiceError(message: failWith) }
            let u = AuthUser(uid: "u", email: email, name: name); currentUser = u; return u
        }
        func signIn(email: String, password: String) async throws -> AuthUser {
            if let failWith { throw AuthServiceError(message: failWith) }
            let u = AuthUser(uid: "u", email: email, name: email); currentUser = u; return u
        }
        func signOut() throws { currentUser = nil }
        func updateName(_ name: String) async throws -> AuthUser { let u = AuthUser(uid: "u", email: "e", name: name); currentUser = u; return u }
        func deleteAccount() async throws { if let failWith { throw AuthServiceError(message: failWith) }; currentUser = nil }
    }
    func testAuthFlow() async {
        let vm = AuthViewModel(service: MockAuth())
        let ok = await vm.signUp(name: "Lenin", email: "a@b.com", password: "123456")
        XCTAssertTrue(ok); XCTAssertTrue(vm.isLoggedIn); vm.signOut(); XCTAssertFalse(vm.isLoggedIn)
    }
    func testAuthFailure() async {
        let m = MockAuth(); m.failWith = "wrong"
        let vm = AuthViewModel(service: m)
        let ok = await vm.signIn(email: "a@b.com", password: "x")
        XCTAssertFalse(ok); XCTAssertEqual(vm.errorMessage, "wrong")
    }

    func testUpdateNameChangesUser() async {
        let vm = AuthViewModel(service: MockAuth())
        _ = await vm.signUp(name: "Old", email: "a@b.com", password: "123456")
        let ok = await vm.updateName("New")
        XCTAssertTrue(ok)
        XCTAssertEqual(vm.user?.name, "New")
    }
    func testDeleteAccountClearsUser() async {
        let vm = AuthViewModel(service: MockAuth())
        _ = await vm.signUp(name: "A", email: "a@b.com", password: "123456")
        let ok = await vm.deleteAccount()
        XCTAssertTrue(ok)
        XCTAssertFalse(vm.isLoggedIn)
    }
    func testDeleteAccountFailureKeepsUser() async {
        let m = MockAuth()
        let vm = AuthViewModel(service: m)
        _ = await vm.signUp(name: "A", email: "a@b.com", password: "123456")
        m.failWith = "log in again"
        let ok = await vm.deleteAccount()
        XCTAssertFalse(ok)
        XCTAssertTrue(vm.isLoggedIn)
        XCTAssertEqual(vm.errorMessage, "log in again")
    }

    // MARK: swiss
    private func makeSwiss(_ n: Int, rounds: Int = 5) -> Tournament {
        let t = Tournament(name: "Swiss", format: "Swiss", totalRounds: rounds)
        context.insert(t)
        for i in 0..<n { let p = Player(name: "P\(i)", seed: i); p.tournament = t; context.insert(p) }
        return t
    }
    private func playRound(_ t: Tournament, _ round: Int, seed: Int = 1) {
        var state = UInt64(seed * 7919 + round)
        for m in t.matches.filter({ $0.round == round && $0.player2 != nil && !$0.isComplete }) {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            let r = Int((state >> 33) % 3)
            vm().recordResult(for: m, score1: r == 0 ? 1 : (r == 1 ? 0 : 0.5), score2: r == 0 ? 0 : (r == 1 ? 1 : 0.5))
        }
    }
    private func playAll(_ t: Tournament, upTo last: Int, seed: Int = 1) {
        vm().generateSchedule(for: t)
        for r in 1...last { playRound(t, r, seed: seed); if r < last { vm().pairNextRound(for: t) } }
    }

    func testSwissRoundOneTopHalfVersusBottomHalf() {
        let t = makeSwiss(16)
        vm().generateSchedule(for: t)
        let games = t.matches.filter { $0.round == 1 }
        XCTAssertEqual(games.count, 8)
        for m in games {
            let a = m.player1!.seed, b = m.player2!.seed
            XCTAssertEqual(abs(a - b), 8, "seed \(a) vs \(b)")
        }
        XCTAssertEqual(t.latestRound, 1)
        XCTAssertEqual(t.status, .upcoming)
    }
    func testSwissFiveRoundsNoRematchesNoDoubleBooking() {
        for seed in 1...6 {
            let t = makeSwiss(16)
            playAll(t, upTo: 5, seed: seed)
            XCTAssertEqual(t.latestRound, 5)
            var met = Set<Set<UUID>>()
            for m in t.matches where m.player2 != nil {
                let key: Set<UUID> = [m.player1!.id, m.player2!.id]
                XCTAssertFalse(met.contains(key), "rematch with seed \(seed)")
                met.insert(key)
            }
            for r in 1...5 {
                let ids = t.matches.filter { $0.round == r }.flatMap { [$0.player1?.id, $0.player2?.id].compactMap { $0 } }
                XCTAssertEqual(ids.count, 16, "round \(r) has everybody")
                XCTAssertEqual(Set(ids).count, 16)
            }
            XCTAssertEqual(t.status, .finished)
            XCTAssertNil(t.nextSwissRound)
        }
    }
    func testSwissPairsSimilarScoresAfterRoundOne() {
        let t = makeSwiss(16)
        playAll(t, upTo: 2, seed: 3)
        let r2 = t.matches.filter { $0.round == 2 }
        // everybody paired against a player with the same score or one point apart at most
        for m in r2 { XCTAssertLessThanOrEqual(abs(m.player1!.score - m.player2!.score), 1.5) }
    }
    func testSwissOddPlayersOneByePerRoundNobodyTwice() {
        let t = makeSwiss(7)
        playAll(t, upTo: 5, seed: 2)
        var byes = [UUID: Int]()
        for m in t.matches where m.player2 == nil { byes[m.player1!.id, default: 0] += 1 }
        XCTAssertEqual(byes.values.reduce(0, +), 5)
        XCTAssertTrue(byes.values.allSatisfy { $0 == 1 }, "nobody gets two byes")
    }
    func testSwissNextRoundOnlyWhenCurrentIsComplete() {
        let t = makeSwiss(8)
        vm().generateSchedule(for: t)
        XCTAssertNil(t.nextSwissRound)
        let ms = t.matches.filter { $0.round == 1 }
        for m in ms.dropLast() { vm().recordResult(for: m, score1: 1, score2: 0) }
        XCTAssertNil(t.nextSwissRound)
        vm().recordResult(for: ms.last!, score1: 1, score2: 0)
        XCTAssertEqual(t.nextSwissRound, 2)
        XCTAssertEqual(t.status, .live)
        vm().pairNextRound(for: t)
        XCTAssertEqual(t.latestRound, 2)
        XCTAssertNil(t.nextSwissRound)
    }
    func testSwissCannotPairBeyondTotalRounds() {
        let t = makeSwiss(8, rounds: 2)
        playAll(t, upTo: 2)
        XCTAssertNil(t.nextSwissRound)
        vm().pairNextRound(for: t)
        XCTAssertEqual(t.latestRound, 2)
        XCTAssertEqual(t.status, .finished)
    }
    func testSwissLateEntryJoinsNextRoundWithMissedRoundPoints() {
        let t = makeSwiss(8)
        playAll(t, upTo: 2, seed: 4)
        XCTAssertTrue(t.acceptsPlayers)
        XCTAssertEqual(vm().entryRound(for: t), 3)
        XCTAssertTrue(vm().addPlayer(named: "Late", to: t, missedRoundPoints: 0.5))
        let late = t.players.first { $0.name == "Late" }!
        let missed = t.matches.filter { $0.player1?.id == late.id && $0.player2 == nil }
        XCTAssertEqual(missed.map(\.round).sorted(), [1, 2])
        XCTAssertTrue(missed.allSatisfy { $0.score1 == 0.5 })
        XCTAssertEqual(late.score, 1.0)
        vm().pairNextRound(for: t)
        let lateGames = t.matches.filter { $0.round == 3 && ($0.player1?.id == late.id || $0.player2?.id == late.id) }
        XCTAssertEqual(lateGames.count, 1)
        XCTAssertNotNil(lateGames.first?.player2, "he plays a real game in round 3")
    }
    func testSwissLateEntryBeforeAnyGameRepairsRoundOne() {
        let t = makeSwiss(8)
        vm().generateSchedule(for: t)
        XCTAssertTrue(vm().addPlayer(named: "Early", to: t))
        XCTAssertEqual(t.players.count, 9)
        let r1 = t.matches.filter { $0.round == 1 }
        XCTAssertEqual(r1.count, 5, "4 games and 1 bye")
        XCTAssertEqual(t.matches.count, 5)
    }
    func testSwissRejectsPlayersWhenLastRoundIsPaired() {
        let t = makeSwiss(8, rounds: 3)
        vm().generateSchedule(for: t)
        for r in 1...3 { playRound(t, r); if r < 3 { vm().pairNextRound(for: t) } }
        XCTAssertFalse(t.acceptsPlayers)
        XCTAssertFalse(vm().addPlayer(named: "TooLate", to: t))
        let u = makeSwiss(8, rounds: 3)
        vm().generateSchedule(for: u)
        playRound(u, 1); vm().pairNextRound(for: u); playRound(u, 2); vm().pairNextRound(for: u)
        XCTAssertFalse(u.acceptsPlayers, "round 3 is paired")
    }
    func testSwissStandingsUseBuchholzForTies() {
        let t = makeSwiss(8)
        playAll(t, upTo: 3, seed: 5)
        let s = TiebreakCalculator.standings(for: t)
        XCTAssertEqual(s.count, 8)
        XCTAssertTrue(zip(s, s.dropFirst()).allSatisfy { $0.score >= $1.score })
        XCTAssertTrue(s.contains { $0.buchholz > 0 })
    }
    func testDirectEncounterBeatsHigherBuchholz() {
        let t = makeSwiss(5)
        let p = t.players.sorted { $0.seed < $1.seed }
        let (a, b, c, d, e) = (p[0], p[1], p[2], p[3], p[4])
        func game(_ x: Player, _ y: Player, _ s1: Double, _ s2: Double) {
            let m = Match(round: 1, player1: x, player2: y, score1: s1, score2: s2, isComplete: true, board: 1)
            m.tournament = t
            context.insert(m)
        }
        game(a, b, 1, 0); game(a, c, 0, 1); game(a, d, 1, 0)
        game(b, e, 1, 0); game(b, d, 1, 0)
        a.score = 2; b.score = 2; c.score = 1; d.score = 0; e.score = 3
        let s = TiebreakCalculator.standings(for: t)
        let first = s.first { $0.player.id == a.id }!, second = s.first { $0.player.id == b.id }!
        XCTAssertGreaterThan(second.buchholz, first.buchholz, "b has the better buchholz")
        XCTAssertLessThan(s.firstIndex { $0.player.id == a.id }!, s.firstIndex { $0.player.id == b.id }!, "a won the direct game")
    }

    func testRoundRobinOddIsNotLiveJustBecauseOfByes() {
        let t = makeTournament(players: ["A", "B", "C"])
        vm().generateSchedule(for: t)
        XCTAssertEqual(t.status, .upcoming)
    }

    func testBoardsAreNumberedWithLeadersFirstAndByesLast() {
        let t = makeSwiss(15)
        playAll(t, upTo: 3, seed: 9)
        for r in 1...3 {
            let ms = t.matches.filter { $0.round == r }
            let games = ms.filter { $0.player2 != nil }.sorted { $0.board < $1.board }
            XCTAssertEqual(games.map(\.board), Array(1...games.count), "boards 1...n in round \(r)")
            XCTAssertTrue(ms.filter { $0.player2 == nil }.allSatisfy { $0.board == 999 })
        }
        let r3 = t.matches.filter { $0.round == 3 && $0.player2 != nil }.sorted { $0.board < $1.board }
        let tops = r3.map { max($0.player1!.score, $0.player2!.score) }
        XCTAssertGreaterThanOrEqual(tops.first!, tops.last!, "leaders sit at the first boards")
    }
}
