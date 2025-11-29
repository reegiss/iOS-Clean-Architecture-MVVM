import Foundation
@testable import ExampleMVVM
import Domain

class MoviesQueriesRepositoryMock: MoviesQueriesRepository {
    var queries: [MovieQuery] = []
    var error: Error?
    
    func fetchRecentsQueries(maxCount: Int) async throws -> [MovieQuery] {
        if let error = error {
            throw error
        }
        return Array(queries.prefix(maxCount))
    }
    
    func saveRecentQuery(query: MovieQuery) async throws -> MovieQuery {
        if let error = error {
            throw error
        }
        return query
    }
}
