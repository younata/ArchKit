import XCTest

#if canImport(Combine)
import Combine
import Dispatch
import CombineExtensions

final class firstOutputAsFutureTests: XCTestCase {
    func testSendingValues() {
        let subject = PassthroughSubject<Int, DummyError>()

        var events: [CombineEvent<Int, DummyError>] = []

        let cancellable: AnyCancellable? = subject.firstOutputAsFuture()
            .sink { completion in
                events.append(.completion(completion))
            } receiveValue: { value in
                events.append(.value(value))
            }
        defer { _ = cancellable }

        XCTAssertTrue(events.isEmpty)

        subject.send(1)

        XCTAssertEqual(events.count, 2)

        XCTAssertEqual(events.first, .value(1))
        XCTAssertEqual(events.last, .completion(.finished))

        // Doesn't send more events after the first
        subject.send(2)
        XCTAssertEqual(events.count, 2)
    }

    func testErroring() {
        let subject = PassthroughSubject<Int, DummyError>()

        var events: [CombineEvent<Int, DummyError>] = []

        let cancellable: AnyCancellable? = subject.firstOutputAsFuture()
            .sink { completion in
                events.append(.completion(completion))
            } receiveValue: { value in
                events.append(.value(value))
            }
        defer { _ = cancellable }

        XCTAssertTrue(events.isEmpty)

        subject.send(completion: .failure(.someError))

        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first, .completion(.failure(.someError)))
    }

    func testAsynchronousWeirdness() {
        let subject = PassthroughSubject<Int, DummyError>()

        var events: [CombineEvent<Int, DummyError>] = []

        let cancellable: AnyCancellable? = subject.firstOutputAsFuture()
            .sink { completion in
                events.append(.completion(completion))
            } receiveValue: { value in
                events.append(.value(value))
            }
        defer { _ = cancellable }

        XCTAssertTrue(events.isEmpty)

        let queue = DispatchQueue(label: "com.younata.archkit.tests.firstOutputAsFutureTests.testAsynchronous")

        let expectation = self.expectation(description: "Asynchronous")
        queue.async {
            subject.send(1)
            DispatchQueue.main.async {
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 0.1, handler: nil)

        XCTAssertEqual(events.count, 2)

        XCTAssertEqual(events.first, .value(1))
        XCTAssertEqual(events.last, .completion(.finished))
    }
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
