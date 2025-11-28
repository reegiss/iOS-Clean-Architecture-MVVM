import Foundation

public struct MoviesRequestDTO: Encodable {
    let query: String
    let page: Int
}
