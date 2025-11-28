import Foundation

final class AppDIContainer {
    
    lazy var appConfiguration = AppConfiguration()
    
    // MARK: - Network
    lazy var apiDataTransferService: DataTransferService = {
        guard let apiBaseURL = URL(string: appConfiguration.apiBaseURL) else {
            fatalError("AppConfiguration.apiBaseURL is invalid: \(appConfiguration.apiBaseURL)")
        }
        let config = ApiDataNetworkConfig(
            baseURL: apiBaseURL,
            queryParameters: [
                "api_key": appConfiguration.apiKey,
                "language": NSLocale.preferredLanguages.first ?? "en"
            ]
        )
        
        let apiDataNetwork = DefaultNetworkService(config: config)
        return DefaultDataTransferService(with: apiDataNetwork)
    }()
    lazy var imageDataTransferService: DataTransferService = {
        guard let imagesBaseURL = URL(string: appConfiguration.imagesBaseURL) else {
            fatalError("AppConfiguration.imagesBaseURL is invalid: \(appConfiguration.imagesBaseURL)")
        }
        let config = ApiDataNetworkConfig(
            baseURL: imagesBaseURL
        )
        let imagesDataNetwork = DefaultNetworkService(config: config)
        return DefaultDataTransferService(with: imagesDataNetwork)
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
