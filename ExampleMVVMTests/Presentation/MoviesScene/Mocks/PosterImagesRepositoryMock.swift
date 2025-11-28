import Foundation
import XCTest
@testable import ExampleMVVM

class PosterImagesRepositoryMock: PosterImagesRepository {
    var completionCalls = 0
    var error: Error?
    var image = Data()
    var validateInput: ((String, Int) -> Void)?
    
    func fetchImage(with imagePath: String, width: Int) async throws -> Data {
        validateInput?(imagePath, width)
        completionCalls += 1
        if let error = error {
            throw error
        }
        return image
    }
}
}
