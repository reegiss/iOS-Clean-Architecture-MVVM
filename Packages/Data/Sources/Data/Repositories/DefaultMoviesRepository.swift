// **Note**: DTOs structs are mapped into Domains here, and Repository protocols does not contain DTOs

import Foundation
import Common
import Domain
import Networking

public final class DefaultMoviesRepository {

    private let dataTransferService: DataTransferService
    private let cache: MoviesResponseStorage

    init(
        dataTransferService: DataTransferService,
        cache: MoviesResponseStorage
    ) {
        self.dataTransferService = dataTransferService
        self.cache = cache
    }
}

extension DefaultMoviesRepository: MoviesRepository {
    
    public func fetchMoviesList(
        query: MovieQuery,
        page: Int
    ) async throws -> MoviesPage {
        let requestDTO = MoviesRequestDTO(query: query.query, page: page)
        
        // Try to get cached response first
        let cachedResponse = await getFromCache(for: requestDTO)
        if let cachedResponse = cachedResponse {
            return cachedResponse.toDomain()
        }
        
        // Fetch from network
        let endpoint = APIEndpoints.getMovies(with: requestDTO)
        let responseDTO: MoviesResponseDTO = try await dataTransferService.request(with: endpoint)
        
        // Cache the response
        await saveToCache(response: responseDTO, for: requestDTO)
        
        return responseDTO.toDomain()
    }
    
    // MARK: - Private
    private func getFromCache(for request: MoviesRequestDTO) async -> MoviesResponseDTO? {
        return await withCheckedContinuation { continuation in
            cache.getResponse(for: request) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure:
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    private func saveToCache(response: MoviesResponseDTO, for request: MoviesRequestDTO) async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            // storage.save is synchronous in current implementations, so resume immediately
            cache.save(response: response, for: request)
            continuation.resume()
        }
    }
}

// MARK: - Factory
public enum MoviesRepositoryFactory {
    public static func make(
        dataTransferService: DataTransferService,
        cache: MoviesResponseStorage
    ) -> MoviesRepository {
        return DefaultMoviesRepository(
            dataTransferService: dataTransferService,
            cache: cache
        )
    }
}
