import Foundation

/// Public factory that exposes high-level networking dependencies.
/// Keeps concrete implementations internal to the Networking module.
public enum NetworkingFactory {
    /// Creates a `DataTransferService` wired with a `NetworkService` configured for `baseURL`.
    /// - Parameters:
    ///   - baseURL: remote base URL
    ///   - headers: extra headers to apply to the network config
    ///   - queryParameters: extra query parameters to apply to the network config
    /// - Returns: a `DataTransferService` (protocol) ready to be injected
    public static func makeDataTransferService(
        baseURL: URL,
        headers: [String: String] = [:],
        queryParameters: [String: String] = [:]
    ) -> DataTransferService {
        let config = NetworkConfigFactory.make(
            baseURL: baseURL,
            headers: headers,
            queryParameters: queryParameters
        )

        let networkService = NetworkServiceFactory.make(config: config)
        return DataTransferServiceFactory.make(networkService: networkService)
    }

    /// Convenience constructor for `NetworkService` if a caller needs it directly.
    public static func makeNetworkService(
        baseURL: URL,
        headers: [String: String] = [:],
        queryParameters: [String: String] = [:]
    ) -> NetworkService {
        let config = NetworkConfigFactory.make(
            baseURL: baseURL,
            headers: headers,
            queryParameters: queryParameters
        )
        return NetworkServiceFactory.make(config: config)
    }
}
