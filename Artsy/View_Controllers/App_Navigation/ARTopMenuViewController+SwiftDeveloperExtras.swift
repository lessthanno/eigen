import UIKit


extension ARTopMenuViewController {

    func runSwiftDeveloperExtras() {        
        self.pushViewController(ARSwitchBoard.sharedInstance().loadAuctionWithID("art-in-general-benefit-auction"))
    }
}