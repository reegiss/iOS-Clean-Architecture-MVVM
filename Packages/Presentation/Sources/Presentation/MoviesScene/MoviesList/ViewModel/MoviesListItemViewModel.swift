// **Note**: This item view model is to display data and does not contain any domain model to prevent views accessing it

import Foundation
import Domain

public struct MoviesListItemViewModel: Equatable {
    public let title: String
    public let overview: String
    public let releaseDate: String
    public let posterImagePath: String?
}

extension MoviesListItemViewModel {

    public init(movie: Movie) {
        self.title = movie.title ?? ""
        self.posterImagePath = movie.posterPath
        self.overview = movie.overview ?? ""
        if let releaseDate = movie.releaseDate {
            self.releaseDate = "Release Date: \(dateFormatter.string(from: releaseDate))"
        } else {
            self.releaseDate = "To be announced"
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.locale = Locale(identifier: "en_US")
    return formatter
}()
