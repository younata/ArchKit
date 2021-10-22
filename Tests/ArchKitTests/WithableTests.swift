import XCTest
import ArchKit
import Foundation

final class WithableTests: XCTestCase {
    func testWith() {
        let subject = MyObject()

        let received = subject.with(\.myValue, as: "whatever")

        XCTAssertEqual(received.myValue, "whatever")
        XCTAssertIdentical(subject, received)
    }

    func testSet() {
        XCTAssertEqual(MyObject().with(\.myValue, as: "whatever").myValue, "whatever")
    }
}

@objc final class MyObject: NSObject {
    var myValue: String = ""
}
