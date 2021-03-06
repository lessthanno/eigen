import UIKit
import ORStackView

extension UIViewController {
    /// Creates a new tag-based stack scroll view, configures it, and sets it to self.view.
    /// Returns the view for convenience, you don't need the return value usually.
    func setupTaggedStackView() -> ORStackScrollView {
        // Build, configure the stack view.
        let stackScrollView = ORStackScrollView(stackViewClass: ORTagBasedAutoStackView.self)
        stackScrollView.stackView.backgroundColor = .whiteColor()
        stackScrollView.delegate = ARScrollNavigationChief.getChief()

        // Set it as our view and perform any other customization.
        self.view = stackScrollView
        self.view.backgroundColor = .blackColor()

        return stackScrollView
    }
}