import UIKit

struct ResultsPDFService: ResultsExportServiceProtocol {
    private let page = CGRect(x: 0, y: 0, width: 612, height: 792)
    private let margin: CGFloat = 48
    private let copper = UIColor(red: 0.74, green: 0.47, blue: 0.23, alpha: 1)
    private let ink = UIColor(white: 0.12, alpha: 1)
    private let gray = UIColor(white: 0.45, alpha: 1)
    private let line = UIColor(white: 0.85, alpha: 1)

    func makePDF(for tournament: Tournament) throws -> URL {
        let standings = TiebreakCalculator.standings(for: tournament)
        let rounds = Array(Set(tournament.matches.map(\.round))).sorted()
        let width = page.width - margin * 2

        let info = [kCGPDFContextTitle as String: "\(tournament.name) - Results",
                    kCGPDFContextCreator as String: AppInfo.name]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = info
        let renderer = UIGraphicsPDFRenderer(bounds: page, format: format)

        let data = renderer.pdfData { context in
            var y: CGFloat = 0
            var pageNumber = 0

            func startPage() {
                context.beginPage()
                pageNumber += 1
                y = margin
                text("Generated with \(AppInfo.name)", font: .systemFont(ofSize: 8), color: gray, x: margin, y: page.height - 34, width: width / 2)
                text("Page \(pageNumber)", font: .systemFont(ofSize: 8), color: gray, x: margin + width / 2, y: page.height - 34, width: width / 2, align: .right)
            }

            func ensure(_ height: CGFloat) {
                if y + height > page.height - 60 { startPage() }
            }

            func rule() {
                line.setStroke()
                let path = UIBezierPath()
                path.move(to: CGPoint(x: margin, y: y))
                path.addLine(to: CGPoint(x: margin + width, y: y))
                path.lineWidth = 0.5
                path.stroke()
            }

            startPage()
            text(AppInfo.name.uppercased(), font: .systemFont(ofSize: 9, weight: .bold), color: copper, x: margin, y: y, width: width, kern: 2)
            y += 20
            text(tournament.name, font: .systemFont(ofSize: 26, weight: .bold), color: ink, x: margin, y: y, width: width)
            y += 36

            var details = [tournament.format]
            if tournament.isSwiss { details[0] += " (\(tournament.totalRounds) rounds)" }
            details.append(tournament.date.formatted(date: .long, time: .omitted))
            if !tournament.location.isEmpty { details.append(tournament.location) }
            details.append("\(tournament.players.count) players")
            text(details.joined(separator: "  \u{00B7}  "), font: .systemFont(ofSize: 11), color: gray, x: margin, y: y, width: width)
            y += 20
            if !tournament.arbiter.isEmpty || !tournament.timeControl.isEmpty {
                var more: [String] = []
                if !tournament.timeControl.isEmpty { more.append("Time control: \(tournament.timeControl)") }
                if !tournament.arbiter.isEmpty { more.append("Arbiter: \(tournament.arbiter)") }
                text(more.joined(separator: "  \u{00B7}  "), font: .systemFont(ofSize: 11), color: gray, x: margin, y: y, width: width)
                y += 20
            }
            y += 10

            text("Standings", font: .systemFont(ofSize: 15, weight: .bold), color: ink, x: margin, y: y, width: width)
            y += 26

            let tiebreakTitle = tournament.isSwiss ? "BUCHHOLZ / SB / WINS" : "SB / KOYA / WINS"
            func standingsHeader() {
                text("#", font: header, color: gray, x: margin, y: y, width: 24)
                text("PLAYER", font: header, color: gray, x: margin + 28, y: y, width: 200)
                text("PTS", font: header, color: gray, x: margin + 236, y: y, width: 44, align: .right)
                text(tiebreakTitle, font: header, color: gray, x: margin + 296, y: y, width: width - 296, align: .right)
                y += 16
                rule()
                y += 6
            }
            standingsHeader()

            for (index, standing) in standings.enumerated() {
                if y + 24 > page.height - 60 { startPage(); standingsHeader() }
                text("\(index + 1)", font: body, color: gray, x: margin, y: y, width: 24)
                text(standing.player.name, font: .systemFont(ofSize: 11, weight: .semibold), color: ink, x: margin + 28, y: y, width: 200)
                text(standing.score.scoreText, font: .systemFont(ofSize: 11, weight: .bold), color: ink, x: margin + 236, y: y, width: 44, align: .right)
                let tiebreaks = tournament.isSwiss
                    ? "\(standing.buchholz.scoreText) / \(standing.sonnebornBerger.scoreText) / \(standing.wins)"
                    : "\(standing.sonnebornBerger.scoreText) / \(standing.koya.scoreText) / \(standing.wins)"
                text(tiebreaks, font: body, color: gray, x: margin + 296, y: y, width: width - 296, align: .right)
                y += 20
                rule()
                y += 4
            }

            func roundHeight(_ round: Int) -> CGFloat {
                CGFloat(tournament.matches.filter { $0.round == round }.count) * 18 + 54
            }

            if let first = rounds.first {
                y += 18
                ensure(26 + roundHeight(first))
                text("Pairings and results", font: .systemFont(ofSize: 15, weight: .bold), color: ink, x: margin, y: y, width: width)
                y += 26
            }

            for round in rounds {
                let games = tournament.matches.filter { $0.round == round }.sorted {
                    if $0.board != $1.board { return $0.board < $1.board }
                    return ($0.player1?.name ?? "") < ($1.player1?.name ?? "")
                }
                ensure(roundHeight(round))
                text("Round \(round)", font: .systemFont(ofSize: 12, weight: .bold), color: copper, x: margin, y: y, width: width)
                y += 20
                text("BOARD", font: header, color: gray, x: margin, y: y, width: 44)
                text("WHITE", font: header, color: gray, x: margin + 52, y: y, width: 190)
                text("BLACK", font: header, color: gray, x: margin + 252, y: y, width: 190)
                text("RESULT", font: header, color: gray, x: margin + width - 60, y: y, width: 60, align: .right)
                y += 14
                rule()
                y += 5

                var board = 0
                for match in games {
                    ensure(22)
                    let white = match.player1?.name ?? ""
                    if let black = match.player2?.name {
                        board += 1
                        let result = match.isComplete ? "\(match.score1.scoreText)-\(match.score2.scoreText)" : "-"
                        text("\(board)", font: body, color: gray, x: margin, y: y, width: 44)
                        text(white, font: body, color: ink, x: margin + 52, y: y, width: 190)
                        text(black, font: body, color: ink, x: margin + 252, y: y, width: 190)
                        text(result, font: .systemFont(ofSize: 11, weight: .semibold), color: ink, x: margin + width - 60, y: y, width: 60, align: .right)
                    } else {
                        let missed = match.score1 < 1
                        text("", font: body, color: gray, x: margin, y: y, width: 44)
                        text(white, font: body, color: ink, x: margin + 52, y: y, width: 190)
                        text(missed ? "missed round" : "bye", font: .italicSystemFont(ofSize: 11), color: gray, x: margin + 252, y: y, width: 190)
                        text(match.score1.scoreText, font: .systemFont(ofSize: 11, weight: .semibold), color: ink, x: margin + width - 60, y: y, width: 60, align: .right)
                    }
                    y += 18
                }
                y += 14
            }
        }

        let safeName = tournament.name.replacingOccurrences(of: "/", with: "-")
        let url = FileManager.default.temporaryDirectory.appending(path: "\(safeName) - Results.pdf")
        try data.write(to: url, options: .atomic)
        return url
    }

    private var header: UIFont { .systemFont(ofSize: 8, weight: .semibold) }
    private var body: UIFont { .systemFont(ofSize: 11) }

    private func text(_ string: String, font: UIFont, color: UIColor, x: CGFloat, y: CGFloat, width: CGFloat,
                      align: NSTextAlignment = .left, kern: CGFloat = 0) {
        let style = NSMutableParagraphStyle()
        style.alignment = align
        style.lineBreakMode = .byTruncatingTail
        var attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color, .paragraphStyle: style]
        if kern > 0 { attributes[.kern] = kern }
        NSString(string: string).draw(in: CGRect(x: x, y: y, width: width, height: font.lineHeight + 2), withAttributes: attributes)
    }
}
