import Artsy_UIButtons
import Artsy_UILabels
import Artsy_UIFonts
import ORStackView
import Then
import MARKRangeSlider
import ARAnalytics

private let CellIdentifier = "Cell"

extension RefineViewController {
    func setupViews() {
        let cancelButton = self.cancelButton()
        view.addSubview(cancelButton)
        cancelButton.alignTopEdgeWithView(view, predicate: "10")
        cancelButton.alignTrailingEdgeWithView(view, predicate: "-10")

        let titleLabel = ARSerifLabel().then {
            $0.font = UIFont.serifFontWithSize(20)
            $0.text = "Refine"
        }
        view.addSubview(titleLabel)
        titleLabel.alignTopEdgeWithView(view, predicate: "20")
        titleLabel.alignLeadingEdgeWithView(view, predicate: "20")

        let stackView = self.stackView()
        view.addSubview(stackView)
        stackView.alignBottomEdgeWithView(view, predicate: "-20")
        stackView.alignLeading("0", trailing: "0", toView: view)
    }

    func updatePriceLabels() {
        minLabel?.text = currentSettings.priceRange?.min.metricSuffixify()
        maxLabel?.text = currentSettings.priceRange?.max.metricSuffixify()
    }

    func updateButtonEnabledStates() {
        let settingsDifferFromDefault = currentSettings != defaultSettings
        let settingsDifferFromInitial = currentSettings != initialSettings

        applyButton?.enabled = settingsDifferFromInitial
        resetButton?.enabled = settingsDifferFromDefault
    }
}

/// User Interaction
 extension RefineViewController {



}

/// UISetup
private extension RefineViewController {

    func cancelButton() -> UIButton {
        let cancelButton = UIButton.circularButton(.Cancel)
        cancelButton.addTarget(self, action: #selector(RefineViewController.userDidCancel), forControlEvents: .TouchUpInside)
        return cancelButton
    }

    func subtitleLabel(text: String) -> UILabel {
        let label = ARSansSerifLabel()
        label.font = UIFont.sansSerifFontWithSize(12)
        label.text = text
        return label
    }

    func stackView() -> ORStackView {
        let stackView = ORStackView()

        stackView.addSubview(subtitleLabel("Sort"), withTopMargin: "20", sideMargin: "40")

        stackView.addSubview(ARSeparatorView(), withTopMargin: "10", sideMargin: "0")

        let tableViewHandler = RefineViewControllerTableViewHandler.init()
        
        let tableView = UITableView().then {
            $0.registerClass(AuctionRefineTableViewCell.self, forCellReuseIdentifier: CellIdentifier)
            $0.scrollEnabled = false
            $0.separatorColor = .artsyGrayRegular()
            $0.separatorInset = UIEdgeInsetsZero
            $0.dataSource = tableViewHandler
            $0.delegate = tableViewHandler
            
            /// note to self - change this to accomodate multiple sections
            let tableViewHeight = 44 * currentSettings.numberOfRowsPerSection(0) - 1 // -1 to cut off the bottom-most separator that we'll manually add below.
            $0.constrainHeight("\(tableViewHeight)")
        }
        stackView.addSubview(tableView, withTopMargin: "0", sideMargin: "40")

        stackView.addSubview(ARSeparatorView(), withTopMargin: "0", sideMargin: "0")

        // Price section
        if let initialRange = initialSettings.priceRange, maxRange = defaultSettings.priceRange {
            stackView.addSubview(subtitleLabel("Price"), withTopMargin: "20", sideMargin: "40")

            let priceExplainLabel = ARSerifLabel().then {
                $0.font = UIFont.serifItalicFontWithSize(15)
                $0.text = "Based on the low estimates of the works"
            }
            stackView.addSubview(priceExplainLabel, withTopMargin: "10", sideMargin: "40")

            let labelContainer = UIView().then {
                $0.constrainHeight("20")
                $0.translatesAutoresizingMaskIntoConstraints = false
            }
            stackView.addSubview(labelContainer, withTopMargin: "10", sideMargin: "40")

            let slider = MARKRangeSlider().then {
                $0.rangeImage = UIImage(named: "Range")
                $0.trackImage = UIImage(named: "Track")
                $0.rightThumbImage = UIImage(named: "Thumb")
                $0.leftThumbImage = $0.rightThumbImage
                $0.addTarget(self, action: #selector(RefineViewController.sliderValueDidChange(_:)), forControlEvents: .ValueChanged)

                $0.setMinValue(CGFloat(maxRange.min), maxValue: CGFloat(maxRange.max))
                $0.setLeftValue(CGFloat(initialRange.min), rightValue: CGFloat(initialRange.max))

                // Make sure they don't touch by keeping them minimum 10% apart
                $0.minimumDistance = CGFloat(maxRange.max - maxRange.min) / 10.0
            }
            stackView.addSubview(slider, withTopMargin: "10", sideMargin: "40")

            // Max/min labels
            let minLabel = ARItalicsSerifLabel().then {
                $0.font = UIFont.serifFontWithSize(15)
                return
            }
            labelContainer.addSubview(minLabel)

            minLabel.alignCenterYWithView(labelContainer, predicate: "0") // Center vertically in container.
            minLabel.alignCenterXWithView(slider.leftThumbView, predicate: "0").forEach(setConstraintPriority(.StayCenteredOverThumb))
            minLabel.alignAttribute(.Leading, toAttribute: .Leading, ofView: labelContainer, predicate: ">= 0").forEach(setConstraintPriority(.StayWithinFrame))

            let maxLabel = ARItalicsSerifLabel().then {
                $0.font = UIFont.serifFontWithSize(15)
                return
            }
            labelContainer.addSubview(maxLabel)

            maxLabel.alignCenterYWithView(labelContainer, predicate: "0") // Center vertically in container.
            maxLabel.alignCenterXWithView(slider.rightThumbView, predicate: "0").forEach(setConstraintPriority(.StayCenteredOverThumb))
            maxLabel.alignAttribute(.Trailing, toAttribute: .Trailing, ofView: labelContainer, predicate: "<= 0").forEach(setConstraintPriority(.StayWithinFrame))

            // Make sure they don't touch! Shouldn't be necessary since they'll be 10% appart, but this is "just in case" make sure the labels never overlap.
            minLabel.constrainTrailingSpaceToView(maxLabel, predicate: "<= -10").forEach(setConstraintPriority(.DoNotOverlap))

            self.minLabel = minLabel
            self.maxLabel = maxLabel
            self.slider = slider
            
            updatePriceLabels()
        }

        let applyButton = ARBlackFlatButton().then {
            $0.enabled = false
            $0.setTitle("Apply", forState: .Normal)
            $0.addTarget(self, action: #selector(RefineViewController.userDidPressApply), forControlEvents: .TouchUpInside)
        }

        let resetButton = ARWhiteFlatButton().then {
            $0.enabled = false
            $0.setTitle("Reset", forState: .Normal)
            $0.setBorderColor(.artsyGrayRegular(), forState: .Normal)
            $0.setBorderColor(UIColor.artsyGrayRegular().colorWithAlphaComponent(0.5), forState: .Disabled)
            $0.layer.borderWidth = 1
            $0.addTarget(self, action: #selector(RefineViewController.userDidPressReset), forControlEvents: .TouchUpInside)
        }

        let buttonContainer = UIView()
        buttonContainer.addSubview(resetButton)
        buttonContainer.addSubview(applyButton)

        UIView.alignTopAndBottomEdgesOfViews([resetButton, applyButton, buttonContainer])
        resetButton.alignLeadingEdgeWithView(buttonContainer, predicate: "0")
        resetButton.constrainTrailingSpaceToView(applyButton, predicate: "-20")
        applyButton.alignTrailingEdgeWithView(buttonContainer, predicate: "0")
        applyButton.constrainWidthToView(resetButton, predicate: "0")

        stackView.addSubview(buttonContainer, withTopMargin: "20", sideMargin: "40")

        self.applyButton = applyButton
        self.resetButton = resetButton
        self.sortTableView = tableView

        updateButtonEnabledStates()

        return stackView
    }
}

enum SliderPriorities: UILayoutPriority {
    case StayWithinFrame = 475
    case DoNotOverlap = 450
    case StayCenteredOverThumb = 425
}

extension RefineViewController {


    // Sets priority of the constraint, using AnyObject! because of FLKAutoLayout
    func setConstraintPriority(priority: SliderPriorities) -> (AnyObject! -> Void) {
        return { constraint in
            (constraint as? NSLayoutConstraint)?.priority = priority.rawValue
        }
    }
}

class RefineViewControllerTableViewHandler: NSObject, UITableViewDataSource, UITableViewDelegate  {
    
    // closures from currentSettings
//    init() {
//        
//    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return currentSettings.numberOfRowsPerSection(section)
        return 2
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath)

//        cell.textLabel?.text = currentSettings.titleForRow(indexPath.row, inSection: indexPath.section)
        
        return cell
    }

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        cell.textLabel?.font = UIFont.serifFontWithSize(16)
//        cell.checked = currentSettings.shouldCheckRowAtIndexPath(indexPath)
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        // Un-check formerly selected cell.
//        if let oldCheckedCellIndex = currentSettings.indexPathOfSelectedOrdering() {
//            let cell = tableView.cellForRowAtIndexPath(oldCheckedCellIndex)
//            cell?.checked = false
        
            // Change setting.
//            currentSettings = currentSettings.settingsWithSelectedIndexPath(indexPath)
//        }

        // Check newly selected cell.
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.checked = true
    }
}

class AuctionRefineTableViewCell: UITableViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame.origin.x = 0
    }
}

private extension UITableViewCell {
    var checked: Bool {
        set(value) {
            if value {
                accessoryView = UIImageView(image: UIImage(named: "AuctionRefineCheck"))
            } else {
                accessoryView = nil
            }
        }
        get {
            return accessoryView != nil
        }
    }
}
