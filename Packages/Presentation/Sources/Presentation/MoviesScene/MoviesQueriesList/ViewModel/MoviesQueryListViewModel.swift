import Foundation
import Domain
import Common

public typealias MoviesQueryListViewModelDidSelectAction = (MovieQuery) -> Void

public protocol MoviesQueryListViewModelInput {
    func viewWillAppear()
    func didSelect(item: MoviesQueryListItemViewModel)
}

public protocol MoviesQueryListViewModelOutput {
    var items: Observable<[MoviesQueryListItemViewModel]> { get }
}

public protocol MoviesQueryListViewModel: MoviesQueryListViewModelInput, MoviesQueryListViewModelOutput { }

final class DefaultMoviesQueryListViewModel: MoviesQueryListViewModel {

    private let numberOfQueriesToShow: Int
    private let fetchRecentMovieQueriesUseCase: FetchRecentMovieQueriesUseCase
    private let didSelect: MoviesQueryListViewModelDidSelectAction?
    
    // MARK: - OUTPUT
    let items: Observable<[MoviesQueryListItemViewModel]> = Observable([])
    
    init(
        numberOfQueriesToShow: Int,
        fetchRecentMovieQueriesUseCase: FetchRecentMovieQueriesUseCase,
        didSelect: MoviesQueryListViewModelDidSelectAction? = nil
    ) {
        self.numberOfQueriesToShow = numberOfQueriesToShow
        self.fetchRecentMovieQueriesUseCase = fetchRecentMovieQueriesUseCase
        self.didSelect = didSelect
    }
    
    private func updateMoviesQueries() {
        Task {
            do {
                let request = FetchRecentMovieQueriesUseCase.RequestValue(maxCount: numberOfQueriesToShow)
                let queries = try await fetchRecentMovieQueriesUseCase.start()
                await MainActor.run { [weak self] in
                    self?.items.value = queries
                        .map { $0.query }
                        .map(MoviesQueryListItemViewModel.init)
                }
            } catch {
                // Silently fail for queries - not critical to user
                await MainActor.run { [weak self] in
                    self?.items.value = []
                }
            }
        }
    }
}

// MARK: - INPUT. View event methods
extension DefaultMoviesQueryListViewModel {
        
    func viewWillAppear() {
        updateMoviesQueries()
    }
    
    func didSelect(item: MoviesQueryListItemViewModel) {
        didSelect?(MovieQuery(query: item.query))
    }
}
