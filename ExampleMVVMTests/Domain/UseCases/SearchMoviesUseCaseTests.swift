import XCTest
@testable import ExampleMVVM

class SearchMoviesUseCaseTests: XCTestCase {
    
    static let moviesPages: [MoviesPage] = {
        let page1 = MoviesPage(page: 1, totalPages: 2, movies: [
            Movie.stub(id: "1", title: "title1", posterPath: "/1", overview: "overview1"),
            Movie.stub(id: "2", title: "title2", posterPath: "/2", overview: "overview2")])
        let page2 = MoviesPage(page: 2, totalPages: 2, movies: [
            Movie.stub(id: "3", title: "title3", posterPath: "/3", overview: "overview3")])
        return [page1, page2]
    }()
    
    enum MoviesRepositorySuccessTestError: Error {
        case failedFetching
    }
    
    class MoviesQueriesRepositoryMock: MoviesQueriesRepository {
        var recentQueries: [MovieQuery] = []
        var fetchCompletionCallsCount = 0
        
        func fetchRecentsQueries(maxCount: Int) async throws -> [MovieQuery] {
            fetchCompletionCallsCount += 1
            return recentQueries
        }
        
        func saveRecentQuery(query: MovieQuery) async throws -> MovieQuery {
            recentQueries.append(query)
            return query
        }
    }
    
    class MoviesRepositoryMock: MoviesRepository {
        var result: Result<MoviesPage, Error>
        var fetchCompletionCallsCount = 0

        init(result: Result<MoviesPage, Error>) {
            self.result = result
        }

        func fetchMoviesList(query: MovieQuery, page: Int) async throws -> MoviesPage {
            fetchCompletionCallsCount += 1
            switch result {
            case .success(let page):
                return page
            case .failure(let error):
                throw error
            }
        }
    }
    
    func testSearchMoviesUseCase_whenSuccessfullyFetchesMoviesForQuery_thenQueryIsSavedInRecentQueries() async {
        // given
        let moviesQueriesRepository = MoviesQueriesRepositoryMock()
        let moviesRepository = MoviesRepositoryMock(
            result: .success(SearchMoviesUseCaseTests.moviesPages[0])
        )
        let useCase = DefaultSearchMoviesUseCase(
            moviesRepository: moviesRepository,
            moviesQueriesRepository: moviesQueriesRepository
        )

        // when
        let requestValue = SearchMoviesUseCaseRequestValue(
            query: MovieQuery(query: "title1"),
            page: 0
        )
        
        do {
            _ = try await useCase.execute(requestValue: requestValue)
            
            // then
            let recents = try await moviesQueriesRepository.fetchRecentsQueries(maxCount: 1)
            XCTAssertTrue(recents.contains(MovieQuery(query: "title1")))
            XCTAssertEqual(moviesQueriesRepository.fetchCompletionCallsCount, 1)
            XCTAssertEqual(moviesRepository.fetchCompletionCallsCount, 1)
        } catch {
            XCTFail("Should not fail: \(error)")
        }
    }
    
    func testSearchMoviesUseCase_whenFailedFetchingMoviesForQuery_thenQueryIsNotSavedInRecentQueries() async {
        // given
        let moviesQueriesRepository = MoviesQueriesRepositoryMock()
        let useCase = DefaultSearchMoviesUseCase(
            moviesRepository: MoviesRepositoryMock(result: .failure(MoviesRepositorySuccessTestError.failedFetching)),
            moviesQueriesRepository: moviesQueriesRepository
        )
        
        // when
        let requestValue = SearchMoviesUseCaseRequestValue(
            query: MovieQuery(query: "title1"),
            page: 0
        )
        
        do {
            _ = try await useCase.execute(requestValue: requestValue)
            XCTFail("Should have thrown an error")
        } catch {
            // Expected error
            let recents = try await moviesQueriesRepository.fetchRecentsQueries(maxCount: 1)
            XCTAssertTrue(recents.isEmpty)
            XCTAssertEqual(moviesQueriesRepository.fetchCompletionCallsCount, 1)
        }
    }
}
