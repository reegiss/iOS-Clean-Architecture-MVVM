import Foundation
import Domain
import Common

public enum MoviesListViewModelFactory {
    public static func make(
        searchMoviesUseCase: SearchMoviesUseCase,
        actions: MoviesListViewModelActions? = nil
    ) -> MoviesListViewModel {
        return DefaultMoviesListViewModel(
            searchMoviesUseCase: searchMoviesUseCase,
            actions: actions
        )
    }
}
