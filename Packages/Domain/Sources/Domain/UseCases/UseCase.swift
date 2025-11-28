import Foundation
import Common

public protocol UseCase {
    @discardableResult
    func start() -> Cancellable?
}
