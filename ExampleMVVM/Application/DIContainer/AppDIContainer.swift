import Foundation
import Common
import Domain
import Networking
import Data
import Presentation

final class AppDIContainer {
    
    lazy var appConfiguration = AppConfiguration()
    
    // MARK: - Network
    lazy var apiDataTransferService: DataTransferService = {
        guard let apiBaseURL = URL(string: appConfiguration.apiBaseURL) else {
            fatalError("AppConfiguration.apiBaseURL is invalid: \(appConfiguration.apiBaseURL)")
        }
        let config = NetworkConfigFactory.make(
            baseURL: apiBaseURL,
            queryParameters: [
                "api_key": appConfiguration.apiKey,
                "language": NSLocale.preferredLanguages.first ?? "en"
            ]
        )
        
        let apiDataNetwork = NetworkServiceFactory.make(config: config)
        return DataTransferServiceFactory.make(networkService: apiDataNetwork)
    }()
    lazy var imageDataTransferService: DataTransferService = {
        guard let imagesBaseURL = URL(string: appConfiguration.imagesBaseURL) else {
            fatalError("AppConfiguration.imagesBaseURL is invalid: \(appConfiguration.imagesBaseURL)")
        }
        let config = NetworkConfigFactory.make(
            baseURL: imagesBaseURL
        )
        let imagesDataNetwork = NetworkServiceFactory.make(config: config)
        return DataTransferServiceFactory.make(networkService: imagesDataNetwork)
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
