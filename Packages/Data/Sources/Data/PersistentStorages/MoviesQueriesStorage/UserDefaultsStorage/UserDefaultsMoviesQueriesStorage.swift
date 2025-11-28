import Foundation
import Domain
import Common

public final class UserDefaultsMoviesQueriesStorage {
    private let maxStorageLimit: Int
    private let recentsMoviesQueriesKey = "recentsMoviesQueries"
    private var userDefaults: UserDefaults
    private let backgroundQueue: DispatchQueueType
    
    init(
        maxStorageLimit: Int,
        userDefaults: UserDefaults = UserDefaults.standard,
        backgroundQueue: DispatchQueueType = DispatchQueue.global(qos: .userInitiated)
    ) {
        self.maxStorageLimit = maxStorageLimit
        self.userDefaults = userDefaults
        self.backgroundQueue = backgroundQueue
    }

    private func fetchMoviesQueries() -> [MovieQuery] {
        if let queriesData = userDefaults.object(forKey: recentsMoviesQueriesKey) as? Data {
            if let movieQueryList = try? JSONDecoder().decode(MovieQueriesListUDS.self, from: queriesData) {
                return movieQueryList.list.map { $0.toDomain() }
            }
        }
        return []
    }

    private func persist(moviesQueries: [MovieQuery]) {
        let encoder = JSONEncoder()
        let movieQueryUDSs = moviesQueries.map(MovieQueryUDS.init)
        if let encoded = try? encoder.encode(MovieQueriesListUDS(list: movieQueryUDSs)) {
            userDefaults.set(encoded, forKey: recentsMoviesQueriesKey)
        }
    }
}

extension UserDefaultsMoviesQueriesStorage: MoviesQueriesStorage {

    public func fetchRecentsQueries(maxCount: Int) async throws -> [MovieQuery] {
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self = self else {
                continuation.resume(throwing: NSError(domain: "UserDefaultsMoviesQueriesStorage", code: -1))
                return
            }
            
            backgroundQueue.async { [weak self] in
                guard let self = self else { return }
                var queries = self.fetchMoviesQueries()
                queries = queries.count < self.maxStorageLimit ? queries : Array(queries[0..<maxCount])
                continuation.resume(returning: queries)
            }
        }
    }

    public func saveRecentQuery(query: MovieQuery) async throws -> MovieQuery {
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self = self else {
                continuation.resume(throwing: NSError(domain: "UserDefaultsMoviesQueriesStorage", code: -1))
                return
            }
            
            backgroundQueue.async { [weak self] in
                guard let self = self else { return }
                var queries = self.fetchMoviesQueries()
                self.cleanUpQueries(for: query, in: &queries)
                queries.insert(query, at: 0)
                self.persist(moviesQueries: queries)
                continuation.resume(returning: query)
            }
        }
    }
}


// MARK: - Private
extension UserDefaultsMoviesQueriesStorage {

    private func cleanUpQueries(for query: MovieQuery, in queries: inout [MovieQuery]) {
        removeDuplicates(for: query, in: &queries)
        removeQueries(limit: maxStorageLimit - 1, in: &queries)
    }

    private func removeDuplicates(for query: MovieQuery, in queries: inout [MovieQuery]) {
        queries = queries.filter { $0 != query }
    }

    private func removeQueries(limit: Int, in queries: inout [MovieQuery]) {
        queries = queries.count <= limit ? queries : Array(queries[0..<limit])
    }
}
