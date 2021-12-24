import XCTest
import ArchKit

#if canImport(Combine)
import Combine

final class GenericSubjectBackedPublisherTests: XCTestCase {
    private struct Dummy {
        @SubjectBacked(PassthroughSubject())
        var values: AnyPublisher<DummyValue, DummyError>
    }

    func testSendValue() {
        let subjectHolder = Dummy()

        var events: [CombineEvent<DummyValue, DummyError>] = []

        let cancellable: AnyCancellable? = subjectHolder.values.sink(
            receiveCompletion: { events.append(.completion($0)) },
            receiveValue: { events.append(.value($0)) }
        )

        XCTAssertTrue(events.isEmpty)

        subjectHolder.$values.send(.one)
        XCTAssertEqual(events, [.value(.one)])

        subjectHolder.$values.send(.two)
        XCTAssertEqual(events, [.value(.one), .value(.two)])

        _ = cancellable
    }

    func testSendError() {
        let subjectHolder = Dummy()

        var events: [CombineEvent<DummyValue, DummyError>] = []

        let cancellable: AnyCancellable? = subjectHolder.values.sink(
            receiveCompletion: { events.append(.completion($0)) },
            receiveValue: { events.append(.value($0)) }
        )

        XCTAssertTrue(events.isEmpty)

        subjectHolder.$values.send(completion: .failure(.someError))

        XCTAssertEqual(events, [.completion(.failure(.someError))])

        _ = cancellable
    }

    func testSendCompletion() {
        let subjectHolder = Dummy()

        var events: [CombineEvent<DummyValue, DummyError>] = []

        let cancellable: AnyCancellable? = subjectHolder.values.sink(
            receiveCompletion: { events.append(.completion($0)) },
            receiveValue: { events.append(.value($0)) }
        )

        XCTAssertTrue(events.isEmpty)

        subjectHolder.$values.send(completion: .finished)

        XCTAssertEqual(events, [.completion(.finished)])

        _ = cancellable
    }
}

final class PassthroughSubjectBackedPublisherTests: XCTestCase {
    private struct Dummy {
        @PassthroughSubjectBacked
        var values: AnyPublisher<DummyValue, DummyError>
    }

    func testSendValue() {
        let subjectHolder = Dummy()

        var events: [CombineEvent<DummyValue, DummyError>] = []

        let cancellable: AnyCancellable? = subjectHolder.values.sink(
            receiveCompletion: { events.append(.completion($0)) },
            receiveValue: { events.append(.value($0)) }
        )

        XCTAssertTrue(events.isEmpty)

        subjectHolder.$values.send(.one)
        XCTAssertEqual(events, [.value(.one)])

        subjectHolder.$values.send(.two)
        XCTAssertEqual(events, [.value(.one), .value(.two)])

        _ = cancellable
    }

    func testSendError() {
        let subjectHolder = Dummy()

        var events: [CombineEvent<DummyValue, DummyError>] = []

        let cancellable: AnyCancellable? = subjectHolder.values.sink(
            receiveCompletion: { events.append(.completion($0)) },
            receiveValue: { events.append(.value($0)) }
        )

        XCTAssertTrue(events.isEmpty)

        subjectHolder.$values.send(completion: .failure(.someError))

        XCTAssertEqual(events, [.completion(.failure(.someError))])

        _ = cancellable
    }

    func testSendCompletion() {
        let subjectHolder = Dummy()

        var events: [CombineEvent<DummyValue, DummyError>] = []

        let cancellable: AnyCancellable? = subjectHolder.values.sink(
            receiveCompletion: { events.append(.completion($0)) },
            receiveValue: { events.append(.value($0)) }
        )

        XCTAssertTrue(events.isEmpty)

        subjectHolder.$values.send(completion: .finished)

        XCTAssertEqual(events, [.completion(.finished)])

        _ = cancellable
    }
}

final class CurrentValueSubjectBackedPublisherTests: XCTestCase {
    private struct Dummy {
        @CurrentValueSubjectBacked(.one)
        var values: AnyPublisher<DummyValue, DummyError>
    }

    func testSendValue() {
        let subjectHolder = Dummy()

        var events: [CombineEvent<DummyValue, DummyError>] = []

        let cancellable: AnyCancellable? = subjectHolder.values.sink(
            receiveCompletion: { events.append(.completion($0)) },
            receiveValue: { events.append(.value($0)) }
        )

        XCTAssertEqual(events, [.value(.one)])

        subjectHolder.$values.send(.two)
        XCTAssertEqual(events, [.value(.one), .value(.two)])

        _ = cancellable
    }

    func testSendError() {
        let subjectHolder = Dummy()

        var events: [CombineEvent<DummyValue, DummyError>] = []

        let cancellable: AnyCancellable? = subjectHolder.values.sink(
            receiveCompletion: { events.append(.completion($0)) },
            receiveValue: { events.append(.value($0)) }
        )

        subjectHolder.$values.send(completion: .failure(.someError))

        XCTAssertEqual(events, [.value(.one), .completion(.failure(.someError))])

        _ = cancellable
    }

    func testSendCompletion() {
        let subjectHolder = Dummy()

        var events: [CombineEvent<DummyValue, DummyError>] = []

        let cancellable: AnyCancellable? = subjectHolder.values.sink(
            receiveCompletion: { events.append(.completion($0)) },
            receiveValue: { events.append(.value($0)) }
        )

        subjectHolder.$values.send(completion: .finished)

        XCTAssertEqual(events, [.value(.one), .completion(.finished)])

        _ = cancellable
    }
}

private enum DummyValue {
    case one
    case two
}

private enum DummyError: Error {
    case someError
}

private enum CombineEvent<Output, Failure: Error> {
    case value(Output)
    case completion(Subscribers.Completion<Failure>)
}

extension CombineEvent: Equatable where Output: Equatable, Failure: Equatable {}

#endif
