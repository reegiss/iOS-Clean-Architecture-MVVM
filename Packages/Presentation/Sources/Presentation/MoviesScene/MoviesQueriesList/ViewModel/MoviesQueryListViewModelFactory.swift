import Foundation
import Domain
import Common

public enum MoviesQueryListViewModelFactory {
    public static func make(
        numberOfQueriesToShow: Int,
        fetchRecentMovieQueriesUseCase: FetchRecentMovieQueriesUseCase,
        didSelect: MoviesQueryListViewModelDidSelectAction? = nil
    ) -> MoviesQueryListViewModel {
        return DefaultMoviesQueryListViewModel(
            numberOfQueriesToShow: numberOfQueriesToShow,
            fetchRecentMovieQueriesUseCase: fetchRecentMovieQueriesUseCase,
            didSelect: didSelect
        )
    }
}
