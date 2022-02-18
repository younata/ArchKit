#if canImport(UIKit)
#if !os(watchOS)

import UIKit

extension UILabel {
    @discardableResult
    public func withBodyFont() -> Self {
        self.withFontStyle(.body)
    }

    @discardableResult
    public func withFontStyle(_ fontStyle: UIFont.TextStyle) -> Self {
        (self as UILabel).font = UIFont.preferredFont(forTextStyle: fontStyle)
        return self
    }

    @discardableResult
    public func withText(_ text: String) -> Self {
        (self as UILabel).text = text
        return self
    }
}

extension UITextField {
    @discardableResult
    public func withBodyFont() -> Self {
        self.withFontStyle(.body)
    }

    @discardableResult
    public func withFontStyle(_ fontStyle: UIFont.TextStyle) -> Self {
        (self as UITextField).font = UIFont.preferredFont(forTextStyle: fontStyle)
        return self
    }

    @discardableResult
    public func withText(_ text: String) -> Self {
        (self as UITextField).text = text
        return self
    }
}

extension UIButton {
    @discardableResult
    public func withBodyFont() -> Self {
        self.withFontStyle(.body)
    }

    @discardableResult
    public func withFontStyle(_ fontStyle: UIFont.TextStyle) -> Self {
        self.titleLabel?.font = UIFont.preferredFont(forTextStyle: fontStyle)
        return self
    }

    @discardableResult
    public func withTitle(_ title: String, for state: UIControl.State) -> Self {
        self.setTitle(title, for: state)
        return self
    }

    @discardableResult
    public func withTitleColor(_ titleColor: UIColor, for state: UIControl.State) -> Self {
        self.setTitleColor(titleColor, for: state)
        return self
    }

    @discardableResult
    public func withTitleNumberOfLines(_ lines: Int) -> Self {
        self.titleLabel?.numberOfLines = lines
        self.titleLabel?.lineBreakMode = .byWordWrapping
        return self
    }

    @discardableResult
    public func withImage(_ image: UIImage?, for state: UIControl.State) -> Self {
        self.setImage(image, for: state)
        return self
    }
}


#endif
#endif
