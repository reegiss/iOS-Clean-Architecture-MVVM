import Foundation
import Domain

public struct MovieQueriesListUDS: Codable {
    var list: [MovieQueryUDS]
}

public struct MovieQueryUDS: Codable {
    let query: String
}

extension MovieQueryUDS {
    init(movieQuery: MovieQuery) {
        query = movieQuery.query
    }
}

extension MovieQueryUDS {
    func toDomain() -> MovieQuery {
        return .init(query: query)
    }
}
