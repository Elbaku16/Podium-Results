import Foundation

protocol ResultsExportServiceProtocol {
    func makePDF(for tournament: Tournament) throws -> URL
}
