import Foundation
import Common
import Domain
import Networking

final class DefaultPosterImagesRepository {
    
    private let dataTransferService: DataTransferService

    init(dataTransferService: DataTransferService) {
        self.dataTransferService = dataTransferService
    }
}

extension DefaultPosterImagesRepository: PosterImagesRepository {
    
    func fetchImage(with imagePath: String, width: Int) async throws -> Data {
        let endpoint = APIEndpoints.getMoviePoster(path: imagePath, width: width)
        return try await dataTransferService.request(with: endpoint)
    }
}

// MARK: - Factory
public enum PosterImagesRepositoryFactory {
    public static func make(
        dataTransferService: DataTransferService
    ) -> PosterImagesRepository {
        return DefaultPosterImagesRepository(
            dataTransferService: dataTransferService
        )
    }
}
