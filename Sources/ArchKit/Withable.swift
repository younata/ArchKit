/**
 Protocol with extension to allow retreiving and setting attributes by keypath in a Builder pattern.

 Should be used like:

        let myObject = AnObject().with(\.someProperty, as: someValue).set(\.otherProperty, to: otherValue)

 - Warning: I've found that this tends to cause runtime crashes if you try to use `.with` on non-objc types. Have not put in the time to figure out why, though.
*/
public protocol Withable {}

extension Withable {
    /**
     Allows setting a writable property by keypath.

     - Parameter keyPath: The keypath to set
     - Parameter value: The desired value
     - Returns: The receiver. To be used in a Builder pattern.
     */
    @discardableResult
    public func with<T>(_ keyPath: WritableKeyPath<Self, T>, as value: T) -> Self {
        var obj = self
        obj[keyPath: keyPath] = value
        return obj
    }

    /**
     Allows setting a writable property by keypath on a referance type.

     - Parameter keyPath: The keypath to set
     - Parameter value: The desired value
     - Returns: The receiver. To be used in a Builder pattern.
     */
    @discardableResult
    public func set<T>(_ keyPath: ReferenceWritableKeyPath<Self, T>, to value: T) -> Self {
        self[keyPath: keyPath] = value
        return self
    }
}

#if canImport(Foundation)

import Foundation

extension NSObject: Withable {}

#endif
