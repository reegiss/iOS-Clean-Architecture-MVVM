import Foundation
import Common

public protocol MoviesRepository {
    func fetchMoviesList(
        query: MovieQuery,
        page: Int
    ) async throws -> MoviesPage
}
