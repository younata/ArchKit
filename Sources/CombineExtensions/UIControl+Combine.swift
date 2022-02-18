#if canImport(Combine)
#if canImport(UIKit)
#if !os(watchOS)

import UIKit
import Combine

// Thanks to https://www.avanderlee.com/swift/custom-combine-publisher/ for the inspiration.

/// A publisher for `UIControl.Event`s.
public struct UIControlPublisher<Control: UIControl>: Publisher {
    public typealias Output = Control
    public typealias Failure = Never

    private let control: Control
    private let controlEvents: UIControl.Event

    init(control: Control, events: UIControl.Event) {
        self.control = control
        self.controlEvents = events
    }

    public func receive<S>(subscriber: S) where S : Subscriber, S.Failure == UIControlPublisher.Failure, S.Input == UIControlPublisher.Output {
        let subscription = UIControlSubscription(subscriber: subscriber, control: control, event: controlEvents)
        subscriber.receive(subscription: subscription)
    }
}

private final class UIControlSubscription<SubscriberType: Subscriber, Control: UIControl>: Subscription where SubscriberType.Input == Control {
    private var subscriber: SubscriberType?
    private let control: Control

    init(subscriber: SubscriberType, control: Control, event: UIControl.Event) {
        self.subscriber = subscriber
        self.control = control
        control.addTarget(self, action: #selector(eventHandler), for: event)
    }

    func request(_ demand: Subscribers.Demand) {
    }

    func cancel() {
        subscriber = nil
    }

    @objc private func eventHandler() {
        _ = subscriber?.receive(control)
    }
}

/** A protocol for views that are extended for Combine

 - Note: This exists entirely so that we can extend a superclass of something (e.g. `UIControl`) in a way that allows us to publish events from an instance of a subclass (e.g. a `UIButton`) that contain that specific instance of that subclass. (See the protocol extension for `CombineExtended` where `Self: UIControl` for an example).
 */
public protocol CombineExtended { }
extension UIControl: CombineExtended { }
extension CombineExtended where Self: UIControl {
    /**
     A Combine publisher that publishes whenever the given `UIControl.Event` happens.

     This is used like:
            let myButton = UIButton()
            myButton.publisher(for: .touchUpInside).sink { (button: UIButton) in
                // handle the tap.
            }.store(in: &cancellables)

     - Parameter events: The events to listn for and publish.
     */
    public func publisher(for events: UIControl.Event) -> UIControlPublisher<Self> {
        return UIControlPublisher(control: self, events: events)
    }
}


#endif
#endif
#endif
