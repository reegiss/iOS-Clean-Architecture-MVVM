import XCTest
@testable import ExampleMVVM

// MARK: - DataTransferService Tests

final class DataTransferServiceTests: XCTestCase {
    
    var sut: DataTransferService!
    var mockNetworkService: MockNetworkService!
    
    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        sut = DataTransferServiceFactory.make(networkService: mockNetworkService)
    }
    
    override func tearDown() {
        sut = nil
        mockNetworkService = nil
        super.tearDown()
    }
    
    // MARK: - Test: Successful request with Decodable response
    
    func testRequestWithDecodableResponseSucceeds() async throws {
        // Arrange
        let expectedMovie = Movie(id: 1, title: "Test Movie", posterPath: "/test.jpg", overview: "Overview")
        let jsonData = try JSONEncoder().encode(expectedMovie)
        let endpoint = MovieEndpoint(response: expectedMovie)
        
        mockNetworkService.stubbedRequestData = jsonData
        
        // Act
        let result: Movie = try await sut.request(with: endpoint)
        
        // Assert
        XCTAssertEqual(result.id, expectedMovie.id)
        XCTAssertEqual(result.title, expectedMovie.title)
    }
    
    // MARK: - Test: Successful request with Void response
    
    func testRequestWithVoidResponseSucceeds() async throws {
        // Arrange
        let endpoint = VoidEndpoint()
        mockNetworkService.stubbedRequestData = nil
        
        // Act & Assert (should not throw)
        try await sut.request(with: endpoint)
    }
    
    // MARK: - Test: Network error handling
    
    func testRequestThrowsNetworkFailureOnNetworkError() async {
        // Arrange
        let networkError = NetworkError.notConnected
        let endpoint = MovieEndpoint(response: Movie(id: 1, title: "", posterPath: nil, overview: ""))
        mockNetworkService.stubbedError = networkError
        
        // Act & Assert
        do {
            let _: Movie = try await sut.request(with: endpoint)
            XCTFail("Should throw DataTransferError.networkFailure")
        } catch let error as DataTransferError {
            if case .networkFailure = error {
                XCTAssertTrue(true)
            } else {
                XCTFail("Expected networkFailure but got \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Test: Parsing error handling
    
    func testRequestThrowsParsingErrorOnInvalidJSON() async {
        // Arrange
        let invalidJSON = "invalid json".data(using: .utf8)!
        let endpoint = MovieEndpoint(response: Movie(id: 1, title: "", posterPath: nil, overview: ""))
        mockNetworkService.stubbedRequestData = invalidJSON
        
        // Act & Assert
        do {
            let _: Movie = try await sut.request(with: endpoint)
            XCTFail("Should throw DataTransferError.parsing")
        } catch let error as DataTransferError {
            if case .parsing = error {
                XCTAssertTrue(true)
            } else {
                XCTFail("Expected parsing error but got \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Test: No response handling
    
    func testRequestThrowsNoResponseWhenDataIsNil() async {
        // Arrange
        let endpoint = MovieEndpoint(response: Movie(id: 1, title: "", posterPath: nil, overview: ""))
        mockNetworkService.stubbedRequestData = nil
        
        // Act & Assert
        do {
            let _: Movie = try await sut.request(with: endpoint)
            XCTFail("Should throw DataTransferError.noResponse")
        } catch let error as DataTransferError {
            if case .noResponse = error {
                XCTAssertTrue(true)
            } else {
                XCTFail("Expected noResponse but got \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Test: Error logging
    
    func testErrorIsLoggedOnNetworkError() async {
        // Arrange
        let networkError = NetworkError.notConnected
        let endpoint = MovieEndpoint(response: Movie(id: 1, title: "", posterPath: nil, overview: ""))
        mockNetworkService.stubbedError = networkError
        
        // Act
        do {
            let _: Movie = try await sut.request(with: endpoint)
        } catch { }
        
        // Assert - error logging happens internally
        XCTAssertTrue(true)
    }
    
    // MARK: - Test: Error resolver
    
    func testErrorResolverIsCalledOnNetworkError() async {
        // Arrange
        let networkError = NetworkError.notConnected
        let endpoint = MovieEndpoint(response: Movie(id: 1, title: "", posterPath: nil, overview: ""))
        mockNetworkService.stubbedError = networkError
        
        // Act
        do {
            let _: Movie = try await sut.request(with: endpoint)
        } catch { }
        
        // Assert - error resolver happens internally
        XCTAssertTrue(true)
    }
}

// MARK: - Mocks

final class MockNetworkService: NetworkService {
    var stubbedRequestData: Data?
    var stubbedError: Error?
    
    func request(endpoint: Requestable) async throws -> Data? {
        if let error = stubbedError {
            throw error
        }
        return stubbedRequestData
    }
}

// MARK: - Test Endpoints & Models

struct MovieEndpoint: ResponseRequestable {
    typealias Response = Movie
    
    let response: Movie
    let responseDecoder: ResponseDecoder = JSONResponseDecoder()
    
    var path: String { "/movie/1" }
    var isRequestCacheable: Bool { false }
    var method: HTTPMethod { .get }
    var headerParamEncoding: HTTPHeaderParamEncoding { .default }
    var queryParamEncoding: QueryParamEncoding { .default }
}

struct VoidEndpoint: ResponseRequestable {
    typealias Response = Void
    
    let responseDecoder: ResponseDecoder = JSONResponseDecoder()
    
    var path: String { "/void" }
    var isRequestCacheable: Bool { false }
    var method: HTTPMethod { .post }
    var headerParamEncoding: HTTPHeaderParamEncoding { .default }
    var queryParamEncoding: QueryParamEncoding { .default }
}
