import XCTest
@testable import ExampleMVVM

class MoviesListViewModelTests: XCTestCase {
    
    private enum SearchMoviesUseCaseError: Error {
        case someError
    }
    
    let moviesPages: [MoviesPage] = {
        let page1 = MoviesPage(page: 1, totalPages: 2, movies: [
            Movie.stub(id: "1", title: "title1", posterPath: "/1", overview: "overview1"),
            Movie.stub(id: "2", title: "title2", posterPath: "/2", overview: "overview2")])
        let page2 = MoviesPage(page: 2, totalPages: 2, movies: [
            Movie.stub(id: "3", title: "title3", posterPath: "/3", overview: "overview3")])
        return [page1, page2]
    }()
    
    class SearchMoviesUseCaseMock: SearchMoviesUseCase {
        var executeCallCount: Int = 0
        var resultToReturn: Result<MoviesPage, Error> = .failure(SearchMoviesUseCaseError.someError)
        
        func execute(requestValue: SearchMoviesUseCaseRequestValue) async throws -> MoviesPage {
            executeCallCount += 1
            switch resultToReturn {
            case .success(let page):
                return page
            case .failure(let error):
                throw error
            }
        }
    }
    
    func test_whenSearchMoviesUseCaseRetrievesEmptyPage_thenViewModelIsEmpty() {
        // given
        let searchMoviesUseCaseMock = SearchMoviesUseCaseMock()
        searchMoviesUseCaseMock.resultToReturn = .success(MoviesPage(page: 1, totalPages: 0, movies: []))
        
        let viewModel = DefaultMoviesListViewModel(
            searchMoviesUseCase: searchMoviesUseCaseMock
        )
        
        let expectation = XCTestExpectation(description: "Search completes")
        
        Task {
            viewModel.didSearch(query: "query")
            try await Task.sleep(nanoseconds: 100_000_000)
            
            XCTAssertEqual(viewModel.currentPage, 1)
            XCTAssertFalse(viewModel.hasMorePages)
            XCTAssertTrue(viewModel.items.value.isEmpty)
            XCTAssertEqual(searchMoviesUseCaseMock.executeCallCount, 1)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func test_whenSearchMoviesUseCaseRetrievesFirstPage_thenViewModelContainsOnlyFirstPage() {
        // given
        let searchMoviesUseCaseMock = SearchMoviesUseCaseMock()
        searchMoviesUseCaseMock.resultToReturn = .success(moviesPages[0])
        
        let viewModel = DefaultMoviesListViewModel(
            searchMoviesUseCase: searchMoviesUseCaseMock
        )
        
        let expectation = XCTestExpectation(description: "Search completes")
        
        Task {
            viewModel.didSearch(query: "query")
            try await Task.sleep(nanoseconds: 100_000_000)
            
            XCTAssertEqual(viewModel.currentPage, 1)
            XCTAssertTrue(viewModel.hasMorePages)
            XCTAssertEqual(viewModel.items.value.count, self.moviesPages[0].movies.count)
            XCTAssertEqual(searchMoviesUseCaseMock.executeCallCount, 1)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
}
