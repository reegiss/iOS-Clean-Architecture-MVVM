import Foundation
import Domain

final class DefaultMoviesQueriesRepository {
    
    private var moviesQueriesPersistentStorage: MoviesQueriesStorage
    
    init(moviesQueriesPersistentStorage: MoviesQueriesStorage) {
        self.moviesQueriesPersistentStorage = moviesQueriesPersistentStorage
    }
}

extension DefaultMoviesQueriesRepository: MoviesQueriesRepository {
    
    func fetchRecentsQueries(maxCount: Int) async throws -> [MovieQuery] {
        return try await moviesQueriesPersistentStorage.fetchRecentsQueries(maxCount: maxCount)
    }
    
    func saveRecentQuery(query: MovieQuery) async throws -> MovieQuery {
        return try await moviesQueriesPersistentStorage.saveRecentQuery(query: query)
    }
}

// MARK: - Factory
public enum MoviesQueriesRepositoryFactory {
    public static func make(
        moviesQueriesPersistentStorage: MoviesQueriesStorage
    ) -> MoviesQueriesRepository {
        return DefaultMoviesQueriesRepository(
            moviesQueriesPersistentStorage: moviesQueriesPersistentStorage
        )
    }
}
