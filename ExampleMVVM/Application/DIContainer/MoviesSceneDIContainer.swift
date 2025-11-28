import UIKit
import SwiftUI
import Common
import Domain
import Networking
import Data
import Presentation

final class MoviesSceneDIContainer: MoviesSearchFlowCoordinatorDependencies {
    
    struct Dependencies {
        let apiDataTransferService: DataTransferService
        let imageDataTransferService: DataTransferService
    }
    
    private let dependencies: Dependencies
    private lazy var dataFactory = DataFactory(dataTransferService: dependencies.apiDataTransferService)

    init(dependencies: Dependencies) {
        self.dependencies = dependencies        
    }
    
    // MARK: - Use Cases
    func makeSearchMoviesUseCase() -> SearchMoviesUseCase {
        return SearchMoviesUseCaseFactory.make(
            moviesRepository: makeMoviesRepository(),
            moviesQueriesRepository: makeMoviesQueriesRepository()
        )
    }
    
    func makeFetchRecentMovieQueriesUseCase(
        requestValue: (maxCount: Int),
        completion: @escaping (Result<[MovieQuery], Error>) -> Void
    ) -> UseCase {
        return FetchRecentMovieQueriesUseCaseFactory.make(
            requestValue: requestValue,
            completion: completion,
            moviesQueriesRepository: makeMoviesQueriesRepository()
        )
    }
    
    // MARK: - Repositories
    func makeMoviesRepository() -> MoviesRepository {
        return dataFactory.makeMoviesRepository()
    }
    func makeMoviesQueriesRepository() -> MoviesQueriesRepository {
        return dataFactory.makeMoviesQueriesRepository(maxStorageLimit: 10)
    }
    func makePosterImagesRepository() -> PosterImagesRepository {
        return PosterImagesRepositoryFactory.make(
            dataTransferService: dependencies.imageDataTransferService
        )
    }
    
    // MARK: - Movies List
    func makeMoviesListViewController(actions: MoviesListViewModelActions) -> MoviesListViewController {
        MoviesListViewController.create(
            with: makeMoviesListViewModel(actions: actions),
            posterImagesRepository: makePosterImagesRepository()
        )
    }
    
    func makeMoviesListViewModel(actions: MoviesListViewModelActions) -> MoviesListViewModel {
        return MoviesListViewModelFactory.make(
            searchMoviesUseCase: makeSearchMoviesUseCase(),
            actions: actions
        )
    }
    
    // MARK: - Movie Details
    func makeMoviesDetailsViewController(movie: Movie) -> UIViewController {
        MovieDetailsViewController.create(
            with: makeMoviesDetailsViewModel(movie: movie)
        )
    }
    
    func makeMoviesDetailsViewModel(movie: Movie) -> MovieDetailsViewModel {
        return MovieDetailsViewModelFactory.make(
            movie: movie,
            posterImagesRepository: makePosterImagesRepository()
        )
    }
    
    // MARK: - Movies Queries Suggestions List
    func makeMoviesQueriesSuggestionsListViewController(didSelect: @escaping MoviesQueryListViewModelDidSelectAction) -> UIViewController {
        if #available(iOS 13.0, *) { // SwiftUI
            let view = MoviesQueryListView(
                viewModelWrapper: makeMoviesQueryListViewModelWrapper(didSelect: didSelect)
            )
            return UIHostingController(rootView: view)
        } else { // UIKit
            return MoviesQueriesTableViewController.create(
                with: makeMoviesQueryListViewModel(didSelect: didSelect)
            )
        }
    }
    
    func makeMoviesQueryListViewModel(didSelect: @escaping MoviesQueryListViewModelDidSelectAction) -> MoviesQueryListViewModel {
        return MoviesQueryListViewModelFactory.make(
            numberOfQueriesToShow: 10,
            fetchRecentMovieQueriesUseCaseFactory: makeFetchRecentMovieQueriesUseCase,
            didSelect: didSelect
        )
    }

    @available(iOS 13.0, *)
    func makeMoviesQueryListViewModelWrapper(
        didSelect: @escaping MoviesQueryListViewModelDidSelectAction
    ) -> MoviesQueryListViewModelWrapper {
        MoviesQueryListViewModelWrapper(
            viewModel: makeMoviesQueryListViewModel(didSelect: didSelect)
        )
    }

    // MARK: - Flow Coordinators
    func makeMoviesSearchFlowCoordinator(navigationController: UINavigationController) -> MoviesSearchFlowCoordinator {
        MoviesSearchFlowCoordinator(
            navigationController: navigationController,
            dependencies: self
        )
    }
}
