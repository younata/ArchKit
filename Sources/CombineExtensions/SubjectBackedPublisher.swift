#if canImport(Combine)
import Combine

/** A property wrapper to simplify generic Subject-backed AnyPublishers.

 This exists so that instead of writing the following:
 ```swift
 class MyThing {
    enum Action {
        case someAction
    }

    private var actionSubject: PassthroughSubject<Action, Never>()
    var actions: AnyPublisher<Action, Never> { actionSubject.eraseToAnyPublisher() }

    func doTheThing() {
        self.$actions.send(.someAction)
    }
 }
 ```

 You can wrap the `actions` property, like so:

 ```swift
 class MyThing {
    enum Action {
        case someAction
    }

    @SubjectBacked(PassthroughSubject())
    var actions: AnyPublisher<Action, Never>

    func doTheThing() {
        self.$actions.send(.someAction)
    }
 }
 ```

 See also ``PassthroughSubjectBacked`` for when you will be using a `PassthroughSubject` and ``CurrentValueSubjectBacked`` for when you will be using a `CurrentValueSubject`.
 */
@propertyWrapper public struct SubjectBacked<Output, Failure, S: Subject> where Failure == S.Failure, Output == S.Output {
    private let subject: S

    public var projectedValue: S { subject }

    public var wrappedValue: AnyPublisher<Output, Failure> {
        AnyPublisher(subject)
    }

    public init(_ subject: S) {
        self.subject = subject
    }
}

/** A property wrapper to simplify PassthroughSubject-backed AnyPublishers.

 This exists so that instead of writing the following:
 ```swift
 class MyThing {
    enum Action {
        case someAction
    }

    private var actionSubject: PassthroughSubject<Action, Never>()
    var actions: AnyPublisher<Action, Never> { actionSubject.eraseToAnyPublisher() }

    func doTheThing() {
        self.$actions.send(.someAction)
    }
 }
 ```

 You can wrap the `actions` property, like so:

 ```swift
 class MyThing {
    enum Action {
        case someAction
    }

    @PassthroughSubjectBacked()
    var actions: AnyPublisher<Action, Never>

    func doTheThing() {
        self.$actions.send(.someAction)
    }
 }
 ```

 See also ``SubjectBacked`` for when you want any generic `Subject` and ``CurrentValueSubjectBacked`` for when you will be using a `CurrentValueSubject`.
 */
@propertyWrapper public struct PassthroughSubjectBacked<Output, Failure: Error> {
    public let projectedValue = PassthroughSubject<Output, Failure>()

    public var wrappedValue: AnyPublisher<Output, Failure> { projectedValue.eraseToAnyPublisher() }

    public init() {}
}

/** A property wrapper to simplify CurrentValueSubject-backed AnyPublishers.

 This exists so that instead of writing the following:
 ```swift
 class MyThing {
    enum Action {
        case someAction
        case initial
    }

    private var actionSubject: CurrentValueSubject<Action, Never>(.initial)
    var actions: AnyPublisher<Action, Never> { actionSubject.eraseToAnyPublisher() }

    func doTheThing() {
        self.$actions.send(.someAction)
    }
 }
 ```

 You can wrap the `actions` property, like so:

 ```swift
 class MyThing {
    enum Action {
        case someAction
    }

    @CurrentValueSubjectBacked(initialValue: .initial)
    var actions: AnyPublisher<Action, Never>

    func doTheThing() {
        self.$actions.send(.someAction)
    }
 }
 ```

 See also ``PassthroughSubjectBacked`` for when you will be using a `PassthroughSubject` and ``SubjectBacked`` for when you wish to use any `Subject`.
 */
@propertyWrapper public struct CurrentValueSubjectBacked<Output, Failure: Error> {
    public let projectedValue: CurrentValueSubject<Output, Failure>

    public var wrappedValue: AnyPublisher<Output, Failure> { projectedValue.eraseToAnyPublisher() }

    public init(_ initialValue: Output) {
        projectedValue = CurrentValueSubject<Output, Failure>(initialValue)
    }
}
#endif
