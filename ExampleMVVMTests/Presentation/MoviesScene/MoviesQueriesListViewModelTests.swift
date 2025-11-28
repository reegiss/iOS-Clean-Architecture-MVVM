@testable import ExampleMVVM
import XCTest

class MoviesQueriesListViewModelTests: XCTestCase {
    
    private enum FetchRecentQueriedUseCase: Error {
        case someError
    }
    
    var movieQueries = [MovieQuery(query: "query1"),
                        MovieQuery(query: "query2"),
                        MovieQuery(query: "query3"),
                        MovieQuery(query: "query4"),
                        MovieQuery(query: "query5")]

    class FetchRecentMovieQueriesUseCaseMock: FetchRecentMovieQueriesUseCase {
        var startCalledCount: Int = 0
        var error: Error?
        var movieQueries: [MovieQuery] = []

        init(requestValue: RequestValue, moviesQueriesRepository: MoviesQueriesRepository) {
            super.init(requestValue: requestValue, moviesQueriesRepository: moviesQueriesRepository)
        }

        override func start() async throws -> [MovieQuery] {
            startCalledCount += 1
            if let error = error {
                throw error
            }
            return movieQueries
        }
    }
    
    func test_whenFetchRecentMovieQueriesUseCaseReturnsQueries_thenShowTheseQueries() {
        // given
        let moviesQueriesRepository = MoviesQueriesRepositoryMock()
        let useCase = FetchRecentMovieQueriesUseCaseMock(
            requestValue: .init(maxCount: 3),
            moviesQueriesRepository: moviesQueriesRepository
        )
        useCase.movieQueries = movieQueries
        
        let viewModel = DefaultMoviesQueryListViewModel(
            numberOfQueriesToShow: 3,
            fetchRecentMovieQueriesUseCase: useCase
        )

        // when
        let expectation = XCTestExpectation(description: "Fetch queries")
        Task {
            viewModel.viewWillAppear()
            try await Task.sleep(nanoseconds: 100_000_000) // Give async time to complete
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        // then
        XCTAssertEqual(viewModel.items.value.map { $0.query }, movieQueries.map { $0.query })
        XCTAssertEqual(useCase.startCalledCount, 1)
    }
    
    func test_whenFetchRecentMovieQueriesUseCaseReturnsError_thenDontShowAnyQuery() {
        // given
        let moviesQueriesRepository = MoviesQueriesRepositoryMock()
        let useCase = FetchRecentMovieQueriesUseCaseMock(
            requestValue: .init(maxCount: 3),
            moviesQueriesRepository: moviesQueriesRepository
        )
        useCase.error = FetchRecentQueriedUseCase.someError
        
        let viewModel = DefaultMoviesQueryListViewModel(
            numberOfQueriesToShow: 3,
            fetchRecentMovieQueriesUseCase: useCase
        )
        
        // when
        let expectation = XCTestExpectation(description: "Fetch queries")
        Task {
            viewModel.viewWillAppear()
            try await Task.sleep(nanoseconds: 100_000_000)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        // then
        XCTAssertTrue(viewModel.items.value.isEmpty)
        XCTAssertEqual(useCase.startCalledCount, 1)
    }
    
    func test_whenDidSelectQueryEventIsReceived_thenCallDidSelectAction() {
        // given
        let selectedQueryItem = MovieQuery(query: "query1")
        var actionMovieQuery: MovieQuery?
        var delegateNotifiedCount = 0
        let didSelect: MoviesQueryListViewModelDidSelectAction = { movieQuery in
            actionMovieQuery = movieQuery
            delegateNotifiedCount += 1
        }
        
        let moviesQueriesRepository = MoviesQueriesRepositoryMock()
        let useCase = FetchRecentMovieQueriesUseCaseMock(
            requestValue: .init(maxCount: 3),
            moviesQueriesRepository: moviesQueriesRepository
        )
        
        let viewModel = DefaultMoviesQueryListViewModel(
            numberOfQueriesToShow: 3,
            fetchRecentMovieQueriesUseCase: useCase,
            didSelect: didSelect
        )
        
        // when
        viewModel.didSelect(item: MoviesQueryListItemViewModel(query: selectedQueryItem.query))
        
        // then
        XCTAssertEqual(actionMovieQuery, selectedQueryItem)
        XCTAssertEqual(delegateNotifiedCount, 1)
    }
}
