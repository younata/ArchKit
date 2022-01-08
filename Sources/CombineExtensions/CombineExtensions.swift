#if canImport(Combine)

import Combine
import Dispatch

extension Future {
    /// Helper function to create an already-finished `Future` with the given value.
    public static func success(_ output: Output) -> Future<Output, Failure> {
        return Future { promise in
            promise(.success(output))
        }
    }

    /// Helper function to create an already-finished `Future` with the given error.
    public static func failure(_ output: Failure) -> Future<Output, Failure> {
        return Future { promise in
            promise(.failure(output))
        }
    }
}

extension Publisher {
    /**
     Creates a Future from the first output only of the receiver.

     Useful for operating on a `Future` when you still want the output of that stream to be a `Future`.

     - Warning: If the receiver completes without outputting a value, then the returned `Future` will never be completed.
     - Returns: A `Future` that will be completed either when the first value from this publisher is published, or when it fails with an error.
     */
    public func firstOutputAsFuture() -> Future<Output, Failure> {
        return Future<Output, Failure> { resolver in
            let queue = DispatchQueue(label: "firstOutputAsFuture", attributes: .concurrent)
            var inProgress: Bool = true
            var cancellable: AnyCancellable?
            cancellable = self.sink(
                receiveCompletion: { completion in
                    queue.sync {
                        guard inProgress else { return }
                        if case let .failure(error) = completion {
                            resolver(.failure(error))
                        } else {
                            // Don't ever resolve this future, I guess.
                        }
                        _ = cancellable
                    }
                },
                receiveValue: { value in
                    queue.sync {
                        guard inProgress else { return }
                        resolver(.success(value))

                        inProgress = false
                    }
                }
            )
        }
    }

    /**
     Forwards events from the receiver to the given `Subject`. Optionally will also finish the subject when the receiver finishes.

     This is mostly used for setting up a type that emits events with a `Subject` as an intermediary publisher, where you want the event publisher to be subscribable from an earlier timepoint than the receiver will be available to send events. For example, something like the following:

            class MyCoordinator: BaseCoordinator {
                private let eventSubject = PassthroughSubject<Event, Never>()
                let events: AnyPublisher<Event, Never> { eventSubject.eraseToAnyPublisher() }

                let subcomponent:

                func start() {
                    super.start()
                    subcomponent.publisher.map { value -> Event in
                        // ...
                    }.send(to: eventSubject)
                }
            }

     - Parameter subject: The `Subject` to send events to.
     - Parameter finishSubject: If `true`, when the receiver receives a completion event, then this will also forward that. Defaults to false, which is likely what you want in the earlier example if you have multiple subcomponents publishing events that are sent to the same `Subject`.
     */
    public func send<S: Subject>(to subject: S, finishSubject: Bool = false) -> AnyCancellable where S.Output == Self.Output, S.Failure == Self.Failure {
        return sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                if finishSubject {
                    subject.send(completion: .finished)
                }
            case .failure(let error):
                subject.send(completion: .failure(error))
            }
        }, receiveValue: { value in
            subject.send(value)
        })
    }
}

/** Merges the array of `Future`s into a single `Future` of an array of `Output`, keeping the original order they were in (as opposed to the order they finish in)

 - Note: If any one future fails, then the entire future will fail.
 - Parameter futures: The array of futures to wait for.
 - Returns: A `Future` of an array of `Output`, in the order the original futures array was in.
 */
public func mergeManyAndKeepOrder<Output, Failure: Error>(_ futures: [Future<Output, Failure>]) -> Future<[Output], Failure> {
    let publishers: [AnyPublisher<(item: Output, index: Int), Failure>] = futures
                                    .enumerated()
                                    .map { (index: Int, publisher: Future<Output, Failure>) -> AnyPublisher<(item: Output, index: Int), Failure> in
                                        return publisher.map { item in (item, index) }.eraseToAnyPublisher()
                                    }

    return Publishers.MergeMany(publishers)
        .collect()
        .map { (values: [(item: Output, index: Int)]) -> [Output] in
            return values.sorted { lhs, rhs in
                return lhs.index < rhs.index
            }.map { $0.item }
        }
        .firstOutputAsFuture()
}

#endif
