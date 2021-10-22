#if canImport(UIKit)

import UIKit

extension UILabel {
    @discardableResult
    func withBodyFont() -> Self {
        self.withFontStyle(.body)
    }

    @discardableResult
    func withFontStyle(_ fontStyle: UIFont.TextStyle) -> Self {
        (self as UILabel).font = UIFont.preferredFont(forTextStyle: fontStyle)
        return self
    }

    @discardableResult
    func withText(_ text: String) -> Self {
        (self as UILabel).text = text
        return self
    }
}

extension UITextField {
    @discardableResult
    func withBodyFont() -> Self {
        self.withFontStyle(.body)
    }

    @discardableResult
    func withFontStyle(_ fontStyle: UIFont.TextStyle) -> Self {
        (self as UITextField).font = UIFont.preferredFont(forTextStyle: fontStyle)
        return self
    }

    @discardableResult
    func withText(_ text: String) -> Self {
        (self as UITextField).text = text
        return self
    }
}

extension UIButton {
    @discardableResult
    func withBodyFont() -> Self {
        self.withFontStyle(.body)
    }

    @discardableResult
    func withFontStyle(_ fontStyle: UIFont.TextStyle) -> Self {
        self.titleLabel?.font = UIFont.preferredFont(forTextStyle: fontStyle)
        return self
    }

    @discardableResult
    func withTitle(_ title: String, for state: UIControl.State) -> Self {
        self.setTitle(title, for: state)
        return self
    }

    @discardableResult
    func withTitleColor(_ titleColor: UIColor, for state: UIControl.State) -> Self {
        self.setTitleColor(titleColor, for: state)
        return self
    }

    @discardableResult
    func withTitleNumberOfLines(_ lines: Int) -> Self {
        self.titleLabel?.numberOfLines = lines
        self.titleLabel?.lineBreakMode = .byWordWrapping
        return self
    }

    @discardableResult
    func withImage(_ image: UIImage?, for state: UIControl.State) -> Self {
        self.setImage(image, for: state)
        return self
    }
}


#endif
