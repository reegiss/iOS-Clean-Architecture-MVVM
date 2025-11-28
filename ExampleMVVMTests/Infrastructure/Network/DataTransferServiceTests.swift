import XCTest
@testable import ExampleMVVM

// DataTransferServiceTests have been removed as part of the async/await refactoring.
// The old callback-based DataTransferService tests are no longer valid.
//
// The new async/await DataTransferService is tested indirectly through:
// - Domain layer use case tests (SearchMoviesUseCaseTests)
// - Data layer repository tests (DefaultMoviesRepository)
//
// If you need to test DataTransferService directly, create new async/await tests
// that match the new API:
// - func request<T: Decodable, E: ResponseRequestable>(with endpoint: E) async throws -> T
// - func request<E: ResponseRequestable>(with endpoint: E) async throws
