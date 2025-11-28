import Foundation
import Common

public protocol PosterImagesRepository {
    func fetchImage(with imagePath: String, width: Int) async throws -> Data
}
