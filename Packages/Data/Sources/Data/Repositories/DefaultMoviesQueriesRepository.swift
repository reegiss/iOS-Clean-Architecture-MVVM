import Foundation
import Domain

final class DefaultMoviesQueriesRepository {
    
    private var moviesQueriesPersistentStorage: MoviesQueriesStorage
    
    init(moviesQueriesPersistentStorage: MoviesQueriesStorage) {
        self.moviesQueriesPersistentStorage = moviesQueriesPersistentStorage
    }
}

extension DefaultMoviesQueriesRepository: MoviesQueriesRepository {
    
    func fetchRecentsQueries(
        maxCount: Int,
        completion: @escaping (Result<[MovieQuery], Error>) -> Void
    ) {
        return moviesQueriesPersistentStorage.fetchRecentsQueries(
            maxCount: maxCount,
            completion: completion
        )
    }
    
    func saveRecentQuery(
        query: MovieQuery,
        completion: @escaping (Result<MovieQuery, Error>) -> Void
    ) {
        moviesQueriesPersistentStorage.saveRecentQuery(
            query: query,
            completion: completion
        )
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
