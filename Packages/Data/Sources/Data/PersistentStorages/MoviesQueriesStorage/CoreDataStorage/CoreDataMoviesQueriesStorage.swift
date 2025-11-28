import Foundation
import CoreData
import Domain

public final class CoreDataMoviesQueriesStorage {

    private let maxStorageLimit: Int
    private let coreDataStorage: CoreDataStorage

    public init(
        maxStorageLimit: Int,
        coreDataStorage: CoreDataStorage
    ) {
        self.maxStorageLimit = maxStorageLimit
        self.coreDataStorage = coreDataStorage
    }
}

extension CoreDataMoviesQueriesStorage: MoviesQueriesStorage {
    
    public func fetchRecentsQueries(maxCount: Int) async throws -> [MovieQuery] {
        return try await withCheckedThrowingContinuation { continuation in
            coreDataStorage.performBackgroundTask { context in
                do {
                    let request: NSFetchRequest = MovieQueryEntity.fetchRequest()
                    request.sortDescriptors = [NSSortDescriptor(key: #keyPath(MovieQueryEntity.createdAt),
                                                                ascending: false)]
                    request.fetchLimit = maxCount
                    let result = try context.fetch(request).map { $0.toDomain() }
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: CoreDataStorageError.readError(error))
                }
            }
        }
    }
    
    public func saveRecentQuery(query: MovieQuery) async throws -> MovieQuery {
        return try await withCheckedThrowingContinuation { continuation in
            coreDataStorage.performBackgroundTask { [weak self] context in
                guard let self = self else {
                    continuation.resume(throwing: CoreDataStorageError.saveError(NSError(domain: "CoreDataStorage", code: -1)))
                    return
                }
                do {
                    try self.cleanUpQueries(for: query, inContext: context)
                    let entity = MovieQueryEntity(movieQuery: query, insertInto: context)
                    try context.save()
                    continuation.resume(returning: entity.toDomain())
                } catch {
                    continuation.resume(throwing: CoreDataStorageError.saveError(error))
                }
            }
        }
    }
}

// MARK: - Private
extension CoreDataMoviesQueriesStorage {

    private func cleanUpQueries(
        for query: MovieQuery,
        inContext context: NSManagedObjectContext
    ) throws {
        let request: NSFetchRequest = MovieQueryEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(MovieQueryEntity.createdAt),
                                                    ascending: false)]
        var result = try context.fetch(request)

        removeDuplicates(for: query, in: &result, inContext: context)
        removeQueries(limit: maxStorageLimit - 1, in: result, inContext: context)
    }

    private func removeDuplicates(
        for query: MovieQuery,
        in queries: inout [MovieQueryEntity],
        inContext context: NSManagedObjectContext
    ) {
        queries
            .filter { $0.query == query.query }
            .forEach { context.delete($0) }
        queries.removeAll { $0.query == query.query }
    }

    private func removeQueries(
        limit: Int,
        in queries: [MovieQueryEntity],
        inContext context: NSManagedObjectContext
    ) {
        guard queries.count > limit else { return }

        queries.suffix(queries.count - limit)
            .forEach { context.delete($0) }
    }
}
