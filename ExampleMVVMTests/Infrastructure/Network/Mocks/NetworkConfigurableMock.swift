import Foundation

class NetworkConfigurableMock: NetworkConfigurable {
    var baseURL: URL = {
        guard let url = URL(string: "https://mock.test.com") else {
            fatalError("Invalid mock base URL")
        }
        return url
    }()
    var headers: [String: String] = [:]
    var queryParameters: [String: String] = [:]
}
