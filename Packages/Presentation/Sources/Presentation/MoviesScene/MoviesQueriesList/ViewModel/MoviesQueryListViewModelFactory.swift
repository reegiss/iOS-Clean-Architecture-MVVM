import Foundation
import Domain
import Common

public enum MoviesQueryListViewModelFactory {
    public static func make(
        numberOfQueriesToShow: Int,
        fetchRecentMovieQueriesUseCaseFactory: @escaping FetchRecentMovieQueriesUseCaseFactory,
        didSelect: MoviesQueryListViewModelDidSelectAction? = nil
    ) -> MoviesQueryListViewModel {
        return DefaultMoviesQueryListViewModel(
            numberOfQueriesToShow: numberOfQueriesToShow,
            fetchRecentMovieQueriesUseCaseFactory: fetchRecentMovieQueriesUseCaseFactory,
            didSelect: didSelect
        )
    }
}
