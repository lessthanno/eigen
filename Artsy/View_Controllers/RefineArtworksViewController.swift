import UIKit
import MARKRangeSlider

protocol RefineArtworksViewControllerDelegate: class {
    func userDidCancel(controller: RefineArtworksViewController)
    func userDidApply(settings: AuctionRefineSettings, controller: RefineArtworksViewController);
}

class RefineArtworksViewController: UIViewController {
    weak var delegate: RefineArtworksViewControllerDelegate?
    var artworkCollectionViewModel: SaleViewModel!
    var minLabel: UILabel?
    var maxLabel: UILabel?
    var slider: MARKRangeSlider?
    var applyButton: UIButton?
    var resetButton: UIButton?
    var sortTableView: UITableView?
    
    // defaultSettings also implies min/max price ranges
    var defaultSettings: AuctionRefineSettings
    var initialSettings: AuctionRefineSettings
    var currentSettings: AuctionRefineSettings {
        didSet {
            updateButtonEnabledStates()
            updatePriceLabels()
        }
    }
    
    var changeStatusBar = false
    
    init(defaultSettings: AuctionRefineSettings, initialSettings: AuctionRefineSettings) {
        self.defaultSettings = defaultSettings
        self.initialSettings = initialSettings
        self.currentSettings = initialSettings
        
        super.init(nibName: nil, bundle: nil)
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
}