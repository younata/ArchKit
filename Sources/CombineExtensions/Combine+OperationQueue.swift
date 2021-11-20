#if canImport(Combine)

import Combine
import Foundation

extension OperationQueue {
    public func publisherOperation<Output, Failure: Error>(_ operation: @escaping () -> Result<Output, Failure>) -> Future<Output, Failure> {
        Future<Output, Failure> { resolver in
            self.addOperation {
                resolver(operation())
            }
        }
    }
}

#endif
