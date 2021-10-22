import XCTest
import ArchKit

#if canImport(UIKit)
import UIKit

final class BaseCoordinatorTests: XCTestCase {
    func testStartAndStop() {
        let subject = BaseCoordinator(rootViewController: UIViewController())

        XCTAssertFalse(subject.isActive)

        subject.start()

        XCTAssertTrue(subject.isActive)

        subject.stop()

        XCTAssertFalse(subject.isActive)
    }

    func testAddAndRemoveChildren() {
        let parent = BaseCoordinator(rootViewController: UIViewController())
        let child = BaseCoordinator(rootViewController: UIViewController())

        parent.addChild(child)

        XCTAssertTrue(parent.children.contains(where: { $0 === child }))
        XCTAssertEqual(parent.children.count, 1)

        XCTAssertFalse(parent.isActive, "Adding a child to a parent should not activate the parent")
        XCTAssertFalse(child.isActive, "The child should not be activated by adding it to the parent")

        child.start()

        parent.removeChild(child)

        XCTAssertFalse(parent.isActive, "removing a child from a parent should not start the parent")
        XCTAssertTrue(child.isActive, "The child should not be stopped by removing it to the parent")

        XCTAssertTrue(parent.children.isEmpty, "The parent should no longer contain any children")
    }

    func testpushAndStart_stopAndPop() {
        let parent = BaseCoordinator(rootViewController: UIViewController())
        let child = BaseCoordinator(rootViewController: UIViewController())

        parent.pushAndStart(child: child)

        XCTAssertTrue(child.isActive, "The child should be started")
        XCTAssertFalse(parent.isActive, "Adding a child to a parent should not start the parent")

        XCTAssertTrue(parent.children.contains(where: { $0 === child }))
        XCTAssertEqual(parent.children.count, 1)

        parent.stopAndPop(child: child)

        XCTAssertFalse(parent.isActive, "The parent should not be started (or stopped)")
        XCTAssertFalse(child.isActive, "The child should be stopped.")

        XCTAssertTrue(parent.children.isEmpty, "The parent should no longer contain any children")
    }
}

// NavigationCoordinator requires a window to test things in, which I don't know how to set up in a Swift Package Test.

#endif
