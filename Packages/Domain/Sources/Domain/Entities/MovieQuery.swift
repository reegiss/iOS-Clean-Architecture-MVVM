import Foundation

public struct MovieQuery: Equatable {
    public let query: String
    
    public init(query: String) {
        self.query = query
    }
}
