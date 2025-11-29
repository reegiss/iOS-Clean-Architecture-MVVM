@testable import ExampleMVVM
import XCTest
@testable import Domain
@testable import Presentation

class MoviesQueriesListViewModelTests: XCTestCase {
    
    private enum FetchRecentQueriedUseCase: Error {
        case someError
    }
    
    var movieQueries = [MovieQuery(query: "query1"),
                        MovieQuery(query: "query2"),
                        MovieQuery(query: "query3"),
                        MovieQuery(query: "query4"),
                        MovieQuery(query: "query5")]

    // We don't subclass the final use-case. Instead create a real use case
    // with a mock MoviesQueriesRepository and control the behaviour via the
    // repository mock's stored properties.
    
    func test_whenFetchRecentMovieQueriesUseCaseReturnsQueries_thenShowTheseQueries() {
        // given
        let moviesQueriesRepository = MoviesQueriesRepositoryMock()
        moviesQueriesRepository.queries = movieQueries
        let useCase = FetchRecentMovieQueriesUseCaseFactory.make(
            requestValue: .init(maxCount: 3),
            moviesQueriesRepository: moviesQueriesRepository
        )
        
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
        // The real use case is final; verify behavior by checking the
        // repository interaction (the repository returned the queries) via
        // the view model's items instead of inspecting internal counters.
    }
    
    func test_whenFetchRecentMovieQueriesUseCaseReturnsError_thenDontShowAnyQuery() {
        // given
        let moviesQueriesRepository = MoviesQueriesRepositoryMock()
        moviesQueriesRepository.error = FetchRecentQueriedUseCase.someError
        let useCase = FetchRecentMovieQueriesUseCaseFactory.make(
            requestValue: .init(maxCount: 3),
            moviesQueriesRepository: moviesQueriesRepository
        )
        
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
        // Confirm the view model shows no items. The repository mock was set
        // to return an error so the view model must remain empty.
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
        moviesQueriesRepository.queries = [selectedQueryItem]
        let useCase = FetchRecentMovieQueriesUseCaseFactory.make(
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
