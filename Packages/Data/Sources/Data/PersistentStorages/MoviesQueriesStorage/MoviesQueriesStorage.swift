import Foundation
import Domain

public protocol MoviesQueriesStorage {
    func fetchRecentsQueries(maxCount: Int) async throws -> [MovieQuery]
    func saveRecentQuery(query: MovieQuery) async throws -> MovieQuery
}
