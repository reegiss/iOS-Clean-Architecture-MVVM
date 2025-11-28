import Foundation
import Common

// This is another option to create Use Case using more generic way
public final class FetchRecentMovieQueriesUseCase: UseCase {

    public struct RequestValue {
        public let maxCount: Int
        public init(maxCount: Int) { self.maxCount = maxCount }
    }
    public typealias ResultValue = Result<[MovieQuery], Error>

    private let requestValue: RequestValue
    private let completion: (ResultValue) -> Void
    private let moviesQueriesRepository: MoviesQueriesRepository

    init(
        requestValue: RequestValue,
        completion: @escaping (ResultValue) -> Void,
        moviesQueriesRepository: MoviesQueriesRepository
    ) {
        self.requestValue = requestValue
        self.completion = completion
        self.moviesQueriesRepository = moviesQueriesRepository
    }
    
    public func start() -> Cancellable? {
        moviesQueriesRepository.fetchRecentsQueries(
            maxCount: requestValue.maxCount,
            completion: completion
        )
        return nil
    }
}

// MARK: - Factory
public enum FetchRecentMovieQueriesUseCaseFactory {
    public static func make(
        requestValue: FetchRecentMovieQueriesUseCase.RequestValue,
        completion: @escaping (Result<[MovieQuery], Error>) -> Void,
        moviesQueriesRepository: MoviesQueriesRepository
    ) -> UseCase {
        return FetchRecentMovieQueriesUseCase(
            requestValue: .init(maxCount: requestValue.maxCount),
            completion: completion,
            moviesQueriesRepository: moviesQueriesRepository
        )
    }
}
