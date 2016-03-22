import UIKit
import QuartzCore
import Artsy_UIButtons

let ButtonHeight: CGFloat = 50

class Button: ARFlatButton {

    override func setup() {
        super.setup()
        setTitleShadowColor(.clearColor(), forState: .Normal)
        setTitleShadowColor(.clearColor(), forState: .Highlighted)
        setTitleShadowColor(.clearColor(), forState: .Disabled)
        shouldDimWhenDisabled = false;
    }
}

class ActionButton: Button {

    override func intrinsicContentSize() -> CGSize {
        return CGSizeMake(UIViewNoIntrinsicMetric, ButtonHeight)
    }

    override func setup() {
        super.setup()

        setBorderColor(.blackColor(), forState: .Normal, animated: false)
        setBorderColor(.artsyPurpleRegular(), forState: .Highlighted, animated: false)
        setBorderColor(.artsyGrayMedium(), forState: .Disabled, animated: false)

        setBackgroundColor(.blackColor(), forState: .Normal, animated: false)
        setBackgroundColor(.artsyPurpleRegular(), forState: .Highlighted, animated: false)
        setBackgroundColor(.whiteColor(), forState: .Disabled, animated: false)

        setTitleColor(.whiteColor(), forState:.Normal)
        setTitleColor(.whiteColor(), forState:.Highlighted)
        setTitleColor(.artsyGrayBold(), forState:.Disabled)
    }
}

class SecondaryActionButton: Button {

    override func intrinsicContentSize() -> CGSize {
        return CGSizeMake(UIViewNoIntrinsicMetric, ButtonHeight)
    }

    override func setup() {
        super.setup()

        setBorderColor(.artsyGrayMedium(), forState: .Normal, animated: false)
        setBorderColor(.artsyPurpleRegular(), forState: .Highlighted, animated: false)
        setBorderColor(.artsyGrayLight(), forState: .Disabled, animated: false)

        setBackgroundColor(.whiteColor(), forState: .Normal, animated: false)
        setBackgroundColor(.artsyPurpleRegular(), forState: .Highlighted, animated: false)
        setBackgroundColor(.whiteColor(), forState: .Disabled, animated: false)

        setTitleColor(.blackColor(), forState:.Normal)
        setTitleColor(.whiteColor(), forState:.Highlighted)
        setTitleColor(.artsyGrayBold(), forState:.Disabled)
    }
}


class KeypadButton: Button {

    override func setup() {
        super.setup()
        shouldAnimateStateChange = false;
        layer.borderWidth = 0
        setBackgroundColor(.blackColor(), forState: .Highlighted, animated: false)
        setBackgroundColor(.whiteColor(), forState: .Normal, animated: false)
    }
}

class LargeKeypadButton: KeypadButton {
    override func setup() {
        super.setup()
        self.titleLabel!.font = UIFont.sansSerifFontWithSize(20)
    }
}

class MenuButton: ARMenuButton {
    override func setup() {
        super.setup()
        if let titleLabel = titleLabel {
            titleLabel.font = titleLabel.font.fontWithSize(12)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let titleLabel = titleLabel { self.bringSubviewToFront(titleLabel) }
        if let imageView = imageView { self.bringSubviewToFront(imageView) }
    }

    override func intrinsicContentSize() -> CGSize {
        return CGSize(width: 45, height: 45)
    }
}
