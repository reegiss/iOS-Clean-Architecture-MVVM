import Foundation

/// Used to easily mock main and background queues in tests
public protocol DispatchQueueType {
    func async(execute work: @escaping () -> Void)
}

extension DispatchQueue: DispatchQueueType {
    public func async(execute work: @escaping () -> Void) {
        async(group: nil, execute: work)
    }
}
