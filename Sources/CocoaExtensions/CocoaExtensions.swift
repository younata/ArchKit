#if canImport(Cocoa) && !canImport(UIKit)

import Cocoa

extension NSEdgeInsets {
    /**
     Creates a NSEdgeInsets inset an equal amount

     - Parameter all: The amount of points all sides should be inset by.
     */
    public init(all: CGFloat) {
        self.init(top: all, left: all, bottom: all, right: all)
    }

    public static var zero: NSEdgeInsets { NSEdgeInsets(all: 0) }
}

extension Array where Element == NSView {
    /**
     Lays out the list of views vertically from top to bottom.

     - Note: This sets `translatesAutoresizingMaskIntoConstraints` on all views in the array to `false` in the event they weren't already.

     - Parameter spacing: The spacing, in points, to use between each view in the array.
     - Parameter insetSpacing: The spacing, in points, to inset the `top` and `bottom` views by. Defaults to no spacing.
     - Parameter useSafeArea: Whether to pin the top and bottom views to the safe area insets or not.
     */
    @discardableResult
    public func layoutVertically(spacing: CGFloat, insetSpacing: (top: CGFloat, bottom: CGFloat) = (0, 0), useSafeArea: Bool = false) -> Self {
        guard isEmpty == false else {
            NSLog("Error: Trying to layout an empty list of views")
            return self
        }
        guard let superview = first?.superview,
              allSatisfy( { $0.superview == superview }) else {
            NSLog("Error: Not all views in the list share the same superview")
            return self
        }
        let lastIndex = self.count - 1

        for (index, view) in enumerated() {
            if index == 0 {
                view.pinEdgeToSuperview(edge: .top, offset: insetSpacing.top, useSafeAreaInsets: useSafeArea)
            } else {
                view.pin(edge: .top, to: .bottom, of: self[index - 1], offset: spacing)
            }
            if index == lastIndex {
                view.pinEdgeToSuperview(edge: .bottom, offset: insetSpacing.bottom, useSafeAreaInsets: useSafeArea)
            }
        }

        return self
    }

    /**
     Lays out the list of views horizontally from the leading edge to the trailing edge.

     - Note: For most regions, leading to trailing means left to right.
     - Note: This sets `translatesAutoresizingMaskIntoConstraints` on all views in the array to `false` in the event they weren't already.

     - Parameter spacing: The spacing, in points, to use between each view in the array.
     - Parameter insetSpacing: The spacing, in points, to inset the `leading` and `trailing` views by. Defaults to no spacing.
     - Parameter useSafeArea: Whether to pin the leading and trailing views to the safe area insets or not.
     */
    @discardableResult
    public func layoutHorizontally(spacing: CGFloat, insetSpacing: (leading: CGFloat, trailing: CGFloat) = (0, 0), useSafeArea: Bool = false) -> Self {
        guard isEmpty == false else {
            NSLog("Error: Trying to layout an empty list of views")
            return self
        }
        guard let superview = first?.superview,
              allSatisfy( { $0.superview == superview }) else {
            NSLog("Error: Not all views in the list share the same superview")
            return self
        }
        let lastIndex = self.count - 1

        for (index, view) in enumerated() {
            if index == 0 {
                view.pinEdgeToSuperview(edge: .leading, offset: insetSpacing.leading, useSafeAreaInsets: useSafeArea)
            } else {
                view.pin(edge: .leading, to: .trailing, of: self[index - 1], offset: spacing)
            }
            if index == lastIndex {
                view.pinEdgeToSuperview(edge: .trailing, offset: insetSpacing.trailing, useSafeAreaInsets: useSafeArea)
            }
        }

        return self
    }

    private var lastIndex: Int { self.count - 1 }
}

extension NSView {
    /**
     A holder for the layout priorities of each edge a view can have.
     */
    public struct LayoutPriorities {
        /**
         Generates a LayoutPriorities struct with the given properties
         */
        public init(top: NSLayoutConstraint.Priority, leading: NSLayoutConstraint.Priority, bottom: NSLayoutConstraint.Priority, trailing: NSLayoutConstraint.Priority) {
            self.top = top
            self.leading = leading
            self.bottom = bottom
            self.trailing = trailing
        }

        /// The layout priority for the top of the view.
        public let top: NSLayoutConstraint.Priority
        /// The layout priority for the leading edge of the view.
        public let leading: NSLayoutConstraint.Priority
        /// The layout priority for the bottom of the view.
        public let bottom: NSLayoutConstraint.Priority
        /// The layout priority for the trailing edge of the view.
        public let trailing: NSLayoutConstraint.Priority

        /**
         The `LayoutPriorities` struct where all edges are required.
         */
        public static let required: LayoutPriorities = {
            return LayoutPriorities(top: .required, leading: .required, bottom: .required, trailing: .required)
        }()
    }

    /**
     A holder for the possible edges to use for each view layout.

     - Note: This can be used as either a single edge (`let edge: Edge = .leading`) or an array of edges (`let edges: Edge = [.leading, .trailing]`).
     */
    public struct Edge: OptionSet {
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public let rawValue: Int

        /// A representation of the leading edge.
        public static let leading = Edge(rawValue: 1 << 0)
        /// A represntation of the trailing edge.
        public static let trailing = Edge(rawValue: 1 << 1)
        /// A representation of the top edge.
        public static let top = Edge(rawValue: 1 << 2)
        /// A representation of the bottom edge.
        public static let bottom = Edge(rawValue: 1 << 3)

        /// Whether this represents a single edge (true) or not (false)
        fileprivate var representsSingleEdge: Bool {
            switch self {
            case .leading, .trailing, .top, .bottom: return true
            default: return false
            }
        }
        /**
         Converts the singular edge to the equivalent edge in `NSLayoutConstraint.Attribute`

         - Warning: If you acces the `attribute` property when this represents multiple edges (e.g. `[.leading, .trailing].attribute`) or an unsupported edge (e.g. `Edge(rawValue: 1<<10).attribute`), then this WILL cause a runtime crash.
         */
        fileprivate var attribute: NSLayoutConstraint.Attribute {
            switch self {
            case .leading: return .leading
            case .trailing: return .trailing
            case .top: return .top
            case .bottom: return .bottom
            default: fatalError("Asked for attribute for \(self.rawValue) which is not mappable to any attribute")
            }
        }
    }

    /**
     The possible dimensions to constrain views along.
     */
    public enum Dimension {
        /// The horizontal dimension (along the X-axis)
        case horizontal
        /// The vertical dimension (along the y-axis)
        case vertical

        /// Converts the receiver to the appropriate NSLayoutConstrait.Attribute
        fileprivate var layoutAttribute: NSLayoutConstraint.Attribute {
            switch self {
            case .horizontal: return .width
            case .vertical: return .height
            }
        }
    }

    /**
     Removes all subviews from the receiver.
     */
    public func removeAllSubviews() {
        for view in self.subviews {
            view.removeFromSuperview()
        }
    }

    /**
     Sets the receiver's `contentCompressionResistancePriority` for the given `axis`.

     - Parameter priority: The priority to set the content compression resistance for this axis to.
     - Parameter axis: The axis to set the content compression resistance of.

     - Returns: The receiver. This is done so that you can chain multiple expressions together, like so:

            let view = NSView().withContentCompressionResistance(.required, for: .horizontal)
     */
    @discardableResult
    public func withContentCompressionResistance(_ priority: NSLayoutConstraint.Priority, for axis: NSLayoutConstraint.Orientation) -> Self {
        self.setContentCompressionResistancePriority(priority, for: axis)
        return self
    }

    /**
     Sets the receiver's `contentHuggingPriority` for the given `axis`.

     - Parameter priority: The priority to set the content hugging for this axis to.
     - Parameter axis: The axis to set the content hugging of.

     - Returns: The receiver. This is done so that you can chain multiple expressions together, like so:

            let view = NSView().withContentHugging(.required, for: .horizontal)
     */
    @discardableResult
    public func withContentHugging(_ priority: NSLayoutConstraint.Priority, for axis: NSLayoutConstraint.Orientation) -> Self {
        self.setContentHuggingPriority(priority, for: axis)
        return self
    }

    /**
     Centers the view in the view's superview.

     - Note: This logs using `NSLog` and otherwise does nothing if the view does not have a superview.
     - Note: This sets `translatesAutoresizingMaskIntoConstraints` on the receiver to `false` in the event it wasn't already.

     - Returns: The receiver. This is done so that you can chain multiple expressions together, like so:

            myView.centerInSuperView().set(dimension: .vertical, to: 10)
     */
    @discardableResult
    public func centerInSuperview() -> Self {
        guard let superview = self.superview else {
            NSLog("Warning: Attempted to center \(self) in its superview when it is not in a view hierarchy.")
            return self
        }

        self.translatesAutoresizingMaskIntoConstraints = false

        self.centerYAnchor.constraint(equalTo: superview.centerYAnchor).isActive = true
        self.centerXAnchor.constraint(equalTo: superview.centerXAnchor).isActive = true
        return self
    }

    /**
     Centers the horizontally view in the view's superview.

     - Note: This logs using `NSLog` and otherwise does nothing if the view does not have a superview.
     - Note: This sets `translatesAutoresizingMaskIntoConstraints` on the receiver to `false` in the event it wasn't already.

     - Returns: The receiver. This is done so that you can chain multiple expressions together, like so:

            myView.centerHorizontally().pinEdgeToSuperview(edge: .top)
     */
    @discardableResult
    public func centerHorizontally() -> Self {
        guard let superview = self.superview else {
            NSLog("Warning: Attempted to center \(self) horizontally in its superview when it is not in a view hierarchy.")
            return self
        }

        self.translatesAutoresizingMaskIntoConstraints = false

        self.centerXAnchor.constraint(equalTo: superview.centerXAnchor).isActive = true
        return self
    }

    /**
     Pins all edges of the receiver to it's superview's edges, minus those excepted, and with the given insets and layout priorities.

     - Note: This logs using `NSLog` and otherwise does nothing if the view does not have a superview.
     - Note: This sets `translatesAutoresizingMaskIntoConstraints` on the receiver to `false` in the event it wasn't already.

     - Parameter insets: The insets to apply to each edge the receiver is pinned to. Defaults to no insets (fully fills up the superview).
     - Parameter priorities: The `UILayoutPriorities` to apply for each individual edge the receiver is pinned to. Defaults to all edges are required.
     - Parameter excludedEdge: The `Edge`s to exclude when pinning. Can be a single edge or multiple.
     - Parameter useSafeAreaInsets: Whether to use the safe area insets when filling up the superview or not. Defaults to `false`.
     - Returns: The receiver. This is done so that you can chain multiple expressions together, like so:

            myView.fillUpSuperview().withContentHugging(.required, for: .vertical)
     */
    @discardableResult
    public func fillUpSuperview(insets: NSEdgeInsets = .zero, priorities: LayoutPriorities = .required, except excludedEdge: Edge = [], useSafeAreaInsets: Bool = false) -> Self {
        guard let superview = self.superview else {
            NSLog("Warning: Attempted to fill up \(self) in its superview when it is not in a view hierarchy.")
            return self
        }
        self.translatesAutoresizingMaskIntoConstraints = false

        if excludedEdge.contains(.leading) == false {
            let targetAnchor = useSafeAreaInsets ? superview.safeAreaLayoutGuide.leadingAnchor : superview.leadingAnchor
            let leading = self.leadingAnchor.constraint(equalTo: targetAnchor, constant: insets.left)
            leading.priority = priorities.leading
            leading.isActive = true
        }

        if excludedEdge.contains(.trailing) == false {
            let targetAnchor = useSafeAreaInsets ? superview.safeAreaLayoutGuide.trailingAnchor : superview.trailingAnchor
            let trailing = self.trailingAnchor.constraint(equalTo: targetAnchor, constant: -insets.right)
            trailing.priority = priorities.trailing
            trailing.isActive = true
        }

        if excludedEdge.contains(.top) == false {
            let targetAnchor = useSafeAreaInsets ? superview.safeAreaLayoutGuide.topAnchor : superview.topAnchor
            let top = self.topAnchor.constraint(equalTo: targetAnchor, constant: insets.top)
            top.priority = priorities.top
            top.isActive = true
        }

        if excludedEdge.contains(.bottom) == false {
            let targetAnchor = useSafeAreaInsets ? superview.safeAreaLayoutGuide.bottomAnchor : superview.bottomAnchor
            let bottom = self.bottomAnchor.constraint(equalTo: targetAnchor, constant: -insets.bottom)
            bottom.priority = priorities.bottom
            bottom.isActive = true
        }
        return self
    }

    /**
     Pins the given edge of the receiver to the specified edge of a sibling view.

     - Note: This logs using `NSLog` and otherwise does nothing if the receiver and siblingView do not have the same superview, or if either the `edge` or `otherEdge` arguments represent multiple or unrecognized edges.
     - Note: This sets `translatesAutoresizingMaskIntoConstraints` on both the receiver and `siblingView`  to `false` in the event they weren't already.

     - Parameter edge: The singular edge of the receiver to use for pinning. E.G. `myView.pin(edge: .top, to: .bottom, of: siblingView)` would pin the top edge of `myView` to the `bottom` edge of `siblingView`.
     - Parameter otherEdge: The singular edge of the `view` to use for pinning. E.G. `myView.pin(edge: .top, to: .bottom, of: siblingView)` would pin the top edge of `myView` to the `bottom` edge of `siblingView`.
     - Parameter siblingView: The other view to pin to. Must share the same `superview` as the receiver.
     - Parameter offset: The amount of spacing, in points, to use in the constraint. Defaults to `0`.
     - Parameter priority: The layout priority to use when creating this constraint. Defaults to `.required`.
     - Returns: The receiver. This is done so that you can chain multiple expressions together, like so:

            myView.pin(edge: .top, to: .top, of: siblingView)
                .pin(edge: .bottom, to: .bottom, of: siblingView)
     */
    @discardableResult
    public func pin(edge: Edge, to otherEdge: Edge, of siblingView: NSView, offset: CGFloat = 0, priority: NSLayoutConstraint.Priority = .required) -> Self {
        guard self.superview == siblingView.superview, self.superview != nil else {
            NSLog("Warning: Can't pin \(self) to \(siblingView), because they don't have a common superview.")
            return self
        }
        guard edge.representsSingleEdge && otherEdge.representsSingleEdge else {
            NSLog("Warning: Can't pin \(self) to \(siblingView), because we do not have single edges (or have unrecognized edges) to pin to (edge: \(edge), otherEdge: \(otherEdge))")
            return self
        }
        self.translatesAutoresizingMaskIntoConstraints = false
        siblingView.translatesAutoresizingMaskIntoConstraints = false

        let constraint = NSLayoutConstraint(item: self, attribute: edge.attribute, relatedBy: .equal, toItem: siblingView,
                                            attribute: otherEdge.attribute, multiplier: 1.0, constant: offset)
        constraint.priority = priority
        self.superview?.addConstraint(constraint)
        return self
    }

    /**
     Pins the given edge of the receiver to the same edge on its superview.

     - Note: This logs using `NSLog` and otherwise does nothing if the receiver does not have a superview, or if either the `edge` argument represent multiple or unrecognized edges.
     - Note: This sets `translatesAutoresizingMaskIntoConstraints` on the receiver  to `false` in the event it wasn't already.

     - Parameter edge: The singular edge of the receiver to use for pinning. E.G. `myView.pin(edge: .top, to: .bottom, of: siblingView)` would pin the top edge of `myView` to the `bottom` edge of `siblingView`.
     - Parameter offset: The amount of spacing, in points, to use in the constraint. Defaults to `0`.
     - Parameter priority: The layout priority to use when creating this constraint. Defaults to `.required`
     - Parameter useSafeAreaInsets: Whether to create this constraint pinning the receiver to its superview's edge, or to the edge in the safe area layout guide. Defaults to `false`.
     - Returns: The receiver. This is done so that you can chain multiple expressions together, like so:

            myView.pinEdgeToSuperview(edge: .top)
                .pinEdgeToSuperview(edge: .bottom)

     */
    @discardableResult
    public func pinEdgeToSuperview(edge: Edge, offset: CGFloat = 0, priority: NSLayoutConstraint.Priority = .required, useSafeAreaInsets: Bool = false) -> Self {
        guard let superview = self.superview else {
            NSLog("Warning: Can't pin edge \(edge.rawValue) of \(self) to superview edge because \(self) doesn't have a superview")
            return self
        }
        guard edge.representsSingleEdge else {
            NSLog("Warning: Can't pin edge \(edge.rawValue) of \(self) to the superview edge because \(edge.rawValue) is either not a single edge, or is an unrecognized edge.")
            return self
        }
        translatesAutoresizingMaskIntoConstraints = false

        switch edge {
        case .leading:
            let targetAnchor = useSafeAreaInsets ? superview.safeAreaLayoutGuide.leadingAnchor : superview.leadingAnchor
            let leading = self.leadingAnchor.constraint(equalTo: targetAnchor, constant: offset)
            leading.priority = priority
            leading.isActive = true
        case .trailing:
            let targetAnchor = useSafeAreaInsets ? superview.safeAreaLayoutGuide.trailingAnchor : superview.trailingAnchor
            let trailing = self.trailingAnchor.constraint(equalTo: targetAnchor, constant: -offset)
            trailing.priority = priority
            trailing.isActive = true
        case .top:
            let targetAnchor = useSafeAreaInsets ? superview.safeAreaLayoutGuide.topAnchor : superview.topAnchor
            let top = self.topAnchor.constraint(equalTo: targetAnchor, constant: offset)
            top.priority = priority
            top.isActive = true
        case .bottom:
            let targetAnchor = useSafeAreaInsets ? superview.safeAreaLayoutGuide.bottomAnchor : superview.bottomAnchor
            let bottom = self.bottomAnchor.constraint(equalTo: targetAnchor, constant: -offset)
            bottom.priority = priority
            bottom.isActive = true
        default:
            NSLog("Error: unknown edge \(edge) specified")
            return self
        }
        return self
    }

    /**
     Matches the given dimension of the receiver to the other dimension in the `otherView`.

     - Note: Unlike the `pin(edge:to:of:offset:priority:)` method, this method only requires that the receiver and `otherView` be in the same view hierarchy. If they do not, then this method logs using `NSLog` and otherwise does nothing.
     - Note: This sets `translatesAutoresizingMaskIntoConstraints` on both the receiver and `otherView`  to `false` in the event they weren't already.

     - Parameter dimension: The dimension of the receiver to use. E.G. `myView.match(dimension: .vertical, to: .horizontal, of: otherView)` would constrain the `width` of `myView` to the `height` of `otherView`.
     - Parameter otherDimension: The dimension on `otherView` to match to. E.G. `myView.match(dimension: .vertical, to: .horizontal, of: otherView)` would constrain the `width` of `myView` to the `height` of `otherView`.
     - Parameter otherView: The other view to pin to. Must be in the same view hierarchy as the receiver.
     - Parameter offset: The amount of additional space, in points, that the `dimension` of receiver must be greater than the `otherDimension` of `otherView`. Defaults to `0`.
     - Parameter multiplier: The multiplier applied to the length of `otherDimension` when setting `dimension`. E.G. `myView.match(dimension: .horizontal, to: .horizontal, of: otherView, multiplier: 0.5)` would constrain the `width` of `myView` to be half the `width` of `otherView`. Defaults to `1`.
     - Parameter priority: The layout priority to use when creating this constraint. Defaults to `.required`.
     - Returns: The receiver. This is done so that you can chain multiple expressions together, like so:

            myView.match(dimension: .horizontal, to: .horizontal, of: otherView)
                .match(dimension: .vertical, to: .vertical, of: otherView)

     */
    @discardableResult
    public func match(dimension: Dimension, to otherDimension: Dimension, of otherView: NSView, offset: CGFloat = 0, multiplier: CGFloat = 1, priority: NSLayoutConstraint.Priority = .required) -> Self {
        guard let sharedSuperview = self.sharedSuperview(with: otherView) else {
            NSLog("Warning: Can't match dimensions of \(self) and \(otherView) because they are not in the same view hierarchy.")
            return self
        }
        self.translatesAutoresizingMaskIntoConstraints = false
        otherView.translatesAutoresizingMaskIntoConstraints = false

        let constraint = NSLayoutConstraint(item: self, attribute: dimension.layoutAttribute, relatedBy: .equal, toItem: otherView, attribute: otherDimension.layoutAttribute, multiplier: multiplier, constant: offset)
        constraint.priority = priority
        sharedSuperview.addConstraint(constraint)
        return self
    }

    /**
     Constrains the given dimension of the receiver to the specified value.

     - Note: This logs using `NSLog` and otherwise does nothing if the receiver does not have a superview.
     - Note: This sets `translatesAutoresizingMaskIntoConstraints` on the receiver to `false` in the event it wasn't already.

     - Parameter dimension: The dimension of the receiver to constrain.
     - Parameter offset: The amount to constrain the receiver to.
     - Parameter priority: The priority to use when setting this constraint. Defaults to `.required`.

     - Returns: The receiver. This is done so that you can chain multiple expressions together, like so:

            myView.set(dimension: .horizontal, to: 100)
                .set(dimension: .vertical, to: 100)
     */
    @discardableResult
    public func set(dimension: Dimension, to offset: CGFloat, priority: NSLayoutConstraint.Priority = .required) -> Self {
        self.translatesAutoresizingMaskIntoConstraints = false
        let constraint = NSLayoutConstraint(item: self, attribute: dimension.layoutAttribute, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: offset)
        constraint.priority = priority
        self.addConstraint(constraint)
        return self
    }

    private func sharedSuperview(with otherView: NSView) -> NSView? {
        if self == otherView {
            return self
        }
        if self.isChild(of: otherView) {
            return otherView
        }
        if otherView.isChild(of: self) {
            return self
        }

        let superviews = Set(self.parents())
        var other = otherView
        while superviews.contains(other) == false {
            guard let otherSuper = other.superview else {
                return nil
            }
            other = otherSuper
        }
        return other
    }

    private func isChild(of view: NSView) -> Bool {
        if self == view { return true }
        return self.superview?.isChild(of: view) ?? false
    }

    private func parents() -> [NSView] {
        if let superview = self.superview {
            return [superview] + superview.parents()
        }
        return []
    }
}

#endif
