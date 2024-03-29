import XCTest
import ArchKit

#if canImport(UIKit)
#if !os(watchOS)
import UIKit

@MainActor
final class BaseUICoordinatorTests: XCTestCase {
    @MainActor
    func testStartAndStop() async {
        let subject = BaseUICoordinator(rootViewController: UIViewController())

        XCTAssertFalse(subject.isActive)

        await subject.start()

        XCTAssertTrue(subject.isActive)

        await subject.stop()

        XCTAssertFalse(subject.isActive)
    }

    @MainActor
    func testAddAndRemoveChildren() async {
        let parent = BaseUICoordinator(rootViewController: UIViewController())
        let child = BaseUICoordinator(rootViewController: UIViewController())

        parent.addChild(child)

        XCTAssertTrue(parent.children.contains(where: { $0 === child }))
        XCTAssertEqual(parent.children.count, 1)

        XCTAssertFalse(parent.isActive, "Adding a child to a parent should not activate the parent")
        XCTAssertFalse(child.isActive, "The child should not be activated by adding it to the parent")

        await child.start()

        parent.removeChild(child)

        XCTAssertFalse(parent.isActive, "removing a child from a parent should not start the parent")
        XCTAssertTrue(child.isActive, "The child should not be stopped by removing it to the parent")

        XCTAssertTrue(parent.children.isEmpty, "The parent should no longer contain any children")
    }

    @MainActor
    func testpushAndStart_stopAndPop() async {
        let parent = BaseUICoordinator(rootViewController: UIViewController())
        let child = BaseUICoordinator(rootViewController: UIViewController())

        await parent.pushAndStart(child: child)

        XCTAssertTrue(child.isActive, "The child should be started")
        XCTAssertFalse(parent.isActive, "Adding a child to a parent should not start the parent")

        XCTAssertTrue(parent.children.contains(where: { $0 === child }))
        XCTAssertEqual(parent.children.count, 1)

        await parent.stopAndPop(child: child)

        XCTAssertFalse(parent.isActive, "The parent should not be started (or stopped)")
        XCTAssertFalse(child.isActive, "The child should be stopped.")

        XCTAssertTrue(parent.children.isEmpty, "The parent should no longer contain any children")
    }
}

// NavigationCoordinator requires a window to test things in, which I don't know how to set up in a Swift Package Test.

#endif
#endif
