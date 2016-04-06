import UIKit
import MARKRangeSlider

protocol RefineViewControllerDelegate: class {
    associatedtype R: RefinableType
    
    func userDidCancel(controller: RefineViewController<R>)
    func userDidApply(settings: R, controller: RefineViewController<R>)
}

// TODO: Move into a navigation

class RefineViewController<R: RefinableType>: UIViewController {
    var minLabel: UILabel?
    var maxLabel: UILabel?
    var slider: MARKRangeSlider?
    var applyButton: UIButton?
    var resetButton: UIButton?
    var sortTableView: UITableView?
    var tableViewHandler: RefineViewControllerTableViewHandler?
    var userDidCancelClosure: (RefineViewController -> Void)?
    var userDidApplyClosure: (R -> Void)?

    // defaultSettings also implies min/max price ranges
    var defaultSettings: R
    var initialSettings: R
    var currentSettings: R {
        didSet {
            updateButtonEnabledStates()
            updatePriceLabels()
        }
    }

    var changeStatusBar = false

    init(defaultSettings: R, initialSettings: R, userDidCancelClosure: (RefineViewController -> Void)?, userDidApplyClosure: (R -> Void)?) {
        self.defaultSettings = defaultSettings
        self.initialSettings = initialSettings
        self.currentSettings = initialSettings
        self.userDidCancelClosure = userDidCancelClosure
        self.userDidApplyClosure = userDidApplyClosure

        super.init(nibName: nil, bundle: nil)
    }
    
    func sliderValueDidChange(slider: MARKRangeSlider) {
        let range = (min: Int(slider.leftValue), max: Int(slider.rightValue))
        currentSettings = currentSettings.refineSettingsWithPriceRange(range)
    }
    
    func userDidPressApply() {
        userDidApplyClosure?(currentSettings)
    }
    
    func userDidCancel() {
        userDidCancelClosure?(self)
    }
    
    func userDidPressReset() {
        // Reset all UI back to its default settings, including a hard reload on the table view.
        currentSettings = defaultSettings
        sortTableView?.reloadData()
        
        if let range = self.defaultSettings.priceRange {
            slider?.setLeftValue(CGFloat(range.min), rightValue: CGFloat(range.max))
        }
        updatePriceLabels()
        updateButtonEnabledStates()
    }
    
    // Required by Swift compiler, sadly.
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .whiteColor()
        
        setupViews()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // Removes our rounded corners
        presentationController?.presentedView()?.layer.cornerRadius = 0

        if changeStatusBar {
            UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: animated ? .Slide : .None)
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        if changeStatusBar {
            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: animated ? .Slide : .None)
        }
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return traitDependentSupportedInterfaceOrientations
    }

    override func shouldAutorotate() -> Bool {
        return traitDependentAutorotateSupport
    }
}
