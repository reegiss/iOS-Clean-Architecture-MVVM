import Foundation

final class AppConfiguration {
    lazy var apiKey: String = {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "ApiKey") as? String,
              !apiKey.isEmpty, !apiKey.hasPrefix("$") else {
            return "test_api_key" // Default for tests
        }
        return apiKey
    }()
    lazy var apiBaseURL: String = {
        guard let apiBaseURL = Bundle.main.object(forInfoDictionaryKey: "ApiBaseURL") as? String,
              !apiBaseURL.isEmpty, !apiBaseURL.hasPrefix("$") else {
            return "https://api.themoviedb.org/3" // Default for tests
        }
        return apiBaseURL
    }()
    lazy var imagesBaseURL: String = {
        guard let imageBaseURL = Bundle.main.object(forInfoDictionaryKey: "ImageBaseURL") as? String,
              !imageBaseURL.isEmpty, !imageBaseURL.hasPrefix("$") else {
            return "https://image.tmdb.org/t/p" // Default for tests
        }
        return imageBaseURL
    }()
}
