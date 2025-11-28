import Foundation

public struct Movie: Equatable, Identifiable {
    public typealias Identifier = String
    
    public enum Genre {
        case adventure
        case scienceFiction
    }
    
    public let id: Identifier
    public let title: String?
    public let genre: Genre?
    public let posterPath: String?
    public let overview: String?
    public let releaseDate: Date?
    
    public init(id: Identifier, title: String?, genre: Genre?, posterPath: String?, overview: String?, releaseDate: Date?) {
        self.id = id
        self.title = title
        self.genre = genre
        self.posterPath = posterPath
        self.overview = overview
        self.releaseDate = releaseDate
    }
}

public struct MoviesPage: Equatable {
    public let page: Int
    public let totalPages: Int
    public let movies: [Movie]
    
    public init(page: Int, totalPages: Int, movies: [Movie]) {
        self.page = page
        self.totalPages = totalPages
        self.movies = movies
    }
}
