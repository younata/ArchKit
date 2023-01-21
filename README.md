# ArchKit

A shared package for all the infrastructure required to support the Architecture styles I use in my own apps.

Very shortly, this architecture is centered around Combines, and passing events between types using Combine publishers.

From a top-down perspective we have:

1. `Coordinator` - these types manage user-level Actions, and can send those types of events up to parent coordinators. Coordinators typically map 1-1 to a ViewController, which can either be a container controller, or one actually showing views.
2. `UIViewController` - Either container controllers or otherwise. These interact directly with `View` objects (either SwiftUI or UIKit) to translate events from the User to things shown on the view. View Controllers here serve to keep Coordinators from having to care about/interact directly with Views.
3. View types are only concerned with showing UI to users, and reacting to them.

This also contains a number of other subpackages and helpers, because I don't care to split them off into their own repository:

- ArchKit
  - [`UICoordinator.swift`](Sources/ArchKit/UICoordinator.swift) is the big one, already detailed above. This is meant to be used with UIKit/UIViewController.
  - [`NSCoordinator.swift`](Sources/ArchKit/NSCoordinator.swift) like UICoordinator, but for Cocoa/NSViewController.
  - [`Withable.swift`](Sources/ArchKit/Withable.swift) is a protocol for setting properties via their keypaths, which is really useful for using the builder pattern with objective-c types.
- Combine Extensions
  - [`CombineExtensions.swift`](Sources/CombineExtensions/CombineExtensions.swift) contains a number of extensions on Combine that make life a bit easier.
    - `Future.success` creates an already-finished `Future` with the given output.
    - `Future.failure` creates an already-finished `Future` with the given error.
    - `-firstOutputAsFuture()` on `Publisher` returns a `Future` that completes once either it receives a value, or if it receives an error. Whichever comes first.
    - `-send(to:finishSubject:)` on `Publisher` forwards events from the receiver onto the given `Subject`. It returns an `AnyCancellable`.
    - `mergeManyAndKeepOrder` takes an array of `Future`s with the same `Output` and `Failure` types and returns a single `Future` that's finished with an array of `Output` from those futures, in the same order those futures were given in.
  - [`UIControl+Combine.swift`](Sources/CombineExtensions/UIControl+Combine.swift) extends `UIControl` such that it can create a publisher for when the given `UIControl.Event`s happen.
- UIKit Extensions
  - [`UIKitExtensions.swift`](Sources/UIKitExtensions/UIKitExtensions.swift) contains a number of helpers and extensions to make view layout in UIKit more declarative and easier to deal with.
  - [`UIKit+Withable.swift`](Sources/UIKitExtensions/UIKit+Withable.swift) contains a number of helpers for using the builder pattern with some classses.
