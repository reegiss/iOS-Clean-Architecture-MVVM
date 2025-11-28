import Foundation
import Common

public final class FetchRecentMovieQueriesUseCase {

    public struct RequestValue {
        public let maxCount: Int
        public init(maxCount: Int) { self.maxCount = maxCount }
    }

    private let requestValue: RequestValue
    private let moviesQueriesRepository: MoviesQueriesRepository

    init(
        requestValue: RequestValue,
        moviesQueriesRepository: MoviesQueriesRepository
    ) {
        self.requestValue = requestValue
        self.moviesQueriesRepository = moviesQueriesRepository
    }
    
    public func start() async throws -> [MovieQuery] {
        return try await moviesQueriesRepository.fetchRecentsQueries(maxCount: requestValue.maxCount)
    }
}

// MARK: - Factory
public enum FetchRecentMovieQueriesUseCaseFactory {
    public static func make(
        requestValue: FetchRecentMovieQueriesUseCase.RequestValue,
        moviesQueriesRepository: MoviesQueriesRepository
    ) -> FetchRecentMovieQueriesUseCase {
        return FetchRecentMovieQueriesUseCase(
            requestValue: requestValue,
            moviesQueriesRepository: moviesQueriesRepository
        )
    }
}
