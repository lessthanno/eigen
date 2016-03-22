import UIKit
import Interstellar

class BiddingNumberPadView : UIView {
    let number = Signal<Int>()
    let leftButton  = Signal<UIButton>()
    let rightButton = Signal<UIButton>()

    @IBAction private func numberTapped(sender: UIButton) {
        number.update(sender.tag)
    }

    @IBAction private func leftTapped(sender: UIButton) {
        leftButton.update(sender)
    }

    @IBAction private func rightTapped(sender: UIButton) {
        rightButton.update(sender)
    }
}

class LiveBiddingViewController: UIViewController {
    @IBOutlet private weak var lotNumberLabel: UILabel!
    @IBOutlet private weak var lotArtistLabel: UILabel!
    @IBOutlet private weak var lotNameLabel: UILabel!
    @IBOutlet private weak var lotPreviewImage: UIImageView!

    @IBOutlet private weak var currentBidLabel: UILabel!

    @IBOutlet private weak var numberPad: BiddingNumberPadView!
    @IBOutlet private weak var bidButton: ActionButton!

    var auctionLotViewModel: LiveAuctionLotViewModel? {
        didSet {
            guard let lot = auctionLotViewModel else { return }
            lotNumberLabel.text = "LOT \(lot.lotIndex ?? 0)"
            lotArtistLabel.text = lot.lotArtist
            lotNameLabel.text = lot.lotName
            lotPreviewImage.ar_setImageWithURL(lot.urlForThumbnail)

            // TODO: Add a next upcoming lot func on the VM?
            currentBidLabel.text = "Enter $\(lot.currentLotValue) or more"
            bidButton.enabled = false
        }
    }

    @IBAction func bidTapped(sender: AnyObject) {

    }

    @IBAction func privacyPolicyTapped(sender: AnyObject) {

    }

    @IBAction func conditionsOfSaleTapped(sender: AnyObject) {

    }
}

