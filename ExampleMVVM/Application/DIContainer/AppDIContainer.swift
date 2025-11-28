import Foundation
import Common
import Domain
import Networking
import Data
import Presentation

final class AppDIContainer {
    
    lazy var appConfiguration = AppConfiguration()
    
    // MARK: - Network
    // Use NetworkingFactory to expose only protocol types to the App composition root.
    lazy var apiDataTransferService: DataTransferService = {
        guard let apiBaseURL = URL(string: appConfiguration.apiBaseURL) else {
            fatalError("AppConfiguration.apiBaseURL is invalid: \(appConfiguration.apiBaseURL)")
        }

        return NetworkingFactory.makeDataTransferService(
            baseURL: apiBaseURL,
            queryParameters: [
                "api_key": appConfiguration.apiKey,
                "language": NSLocale.preferredLanguages.first ?? "en"
            ]
        )
    }()

    lazy var imageDataTransferService: DataTransferService = {
        guard let imagesBaseURL = URL(string: appConfiguration.imagesBaseURL) else {
            fatalError("AppConfiguration.imagesBaseURL is invalid: \(appConfiguration.imagesBaseURL)")
        }

        return NetworkingFactory.makeDataTransferService(baseURL: imagesBaseURL)
    }()
    
    // MARK: - DIContainers of scenes
    func makeMoviesSceneDIContainer() -> MoviesSceneDIContainer {
        let dependencies = MoviesSceneDIContainer.Dependencies(
            apiDataTransferService: apiDataTransferService,
            imageDataTransferService: imageDataTransferService
        )
        return MoviesSceneDIContainer(dependencies: dependencies)
    }
}
