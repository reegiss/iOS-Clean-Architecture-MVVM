import Foundation
import Common

public protocol SearchMoviesUseCase {
    func execute(requestValue: SearchMoviesUseCaseRequestValue) async throws -> MoviesPage
}

final class DefaultSearchMoviesUseCase: SearchMoviesUseCase {

    private let moviesRepository: MoviesRepository
    private let moviesQueriesRepository: MoviesQueriesRepository

    init(
        moviesRepository: MoviesRepository,
        moviesQueriesRepository: MoviesQueriesRepository
    ) {
        self.moviesRepository = moviesRepository
        self.moviesQueriesRepository = moviesQueriesRepository
    }

    func execute(requestValue: SearchMoviesUseCaseRequestValue) async throws -> MoviesPage {
        let moviesPage = try await moviesRepository.fetchMoviesList(
            query: requestValue.query,
            page: requestValue.page
        )
        
        try await moviesQueriesRepository.saveRecentQuery(query: requestValue.query)
        
        return moviesPage
    }
}

public struct SearchMoviesUseCaseRequestValue {
    public let query: MovieQuery
    public let page: Int
    
    public init(query: MovieQuery, page: Int) {
        self.query = query
        self.page = page
    }
}

// MARK: - Factory
public enum SearchMoviesUseCaseFactory {
    public static func make(
        moviesRepository: MoviesRepository,
        moviesQueriesRepository: MoviesQueriesRepository
    ) -> SearchMoviesUseCase {
        return DefaultSearchMoviesUseCase(
            moviesRepository: moviesRepository,
            moviesQueriesRepository: moviesQueriesRepository
        )
    }
}
