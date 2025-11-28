import Foundation

public class MoviesQueryListItemViewModel {
    public let query: String

    public init(query: String) {
        self.query = query
    }
}

extension MoviesQueryListItemViewModel: Equatable {
    public static func == (lhs: MoviesQueryListItemViewModel, rhs: MoviesQueryListItemViewModel) -> Bool {
        return lhs.query == rhs.query
    }
}
