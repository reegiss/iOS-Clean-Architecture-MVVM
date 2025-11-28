import Foundation

public protocol MoviesQueriesRepository {
    func fetchRecentsQueries(maxCount: Int) async throws -> [MovieQuery]
    func saveRecentQuery(query: MovieQuery) async throws -> MovieQuery
}
