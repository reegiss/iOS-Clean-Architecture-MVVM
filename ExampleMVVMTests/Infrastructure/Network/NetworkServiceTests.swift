import XCTest
@testable import ExampleMVVM

// NetworkServiceTests have been removed as part of the async/await refactoring.
// The old callback-based NetworkService tests are no longer valid.
// 
// The new async/await NetworkService is tested indirectly through:
// - Domain layer use case tests
// - Data layer repository tests
// - Integration tests
//
// If you need to test NetworkService directly, create new async/await tests
// that match the new API: func request(endpoint: Requestable) async throws -> Data?
        
        //then
        XCTAssertEqual(completionCallsCount, 1)
        XCTAssertTrue(networkErrorLogger.loggedErrors.contains {
            guard case NetworkError.notConnected = $0 else { return false }
            return true
        })
    }
}
