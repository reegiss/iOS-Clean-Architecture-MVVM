import Foundation
import Domain
import Networking

/// Public factory that composes Data module dependencies and exposes repository factories.
/// Concrete implementations (Default* classes) remain internal to the Data module.
public struct DataFactory {
    private let dataTransferService: DataTransferService

    public init(dataTransferService: DataTransferService) {
        self.dataTransferService = dataTransferService
    }

    /// Creates a `MoviesRepository` wired with the default response cache.
    /// The returned value is the protocol `MoviesRepository` so the app never needs to know
    /// the concrete implementation type.
    public func makeMoviesRepository() -> MoviesRepository {
        // choose default storage implementation inside the Data module
        let cache = CoreDataMoviesResponseStorage(coreDataStorage: CoreDataStorage.shared)
        return MoviesRepositoryFactory.make(
            dataTransferService: dataTransferService,
            cache: cache
        )
    }

    /// Creates a `MoviesQueriesRepository` (recent queries storage)
    public func makeMoviesQueriesRepository(maxStorageLimit: Int = 10) -> MoviesQueriesRepository {
        let storage = CoreDataMoviesQueriesStorage(maxStorageLimit: maxStorageLimit, coreDataStorage: CoreDataStorage.shared)
        return MoviesQueriesRepositoryFactory.make(moviesQueriesPersistentStorage: storage)
    }
}
