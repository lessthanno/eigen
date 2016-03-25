import UIKit


//extension ARTopMenuViewController {
extension ARTopMenuViewController: RefinableArtworkCollectionDelegate {

    func runSwiftDeveloperExtras() {        
        let settings = AuctionRefineSettings(ordering: .ArtistAlphabetical, priceRange:(min: 500_00, max:100_000_00), saleViewModel: nil)
        let vc = RefineArtworksViewController.init(defaultSettings: settings, initialSettings: settings)
        vc.modalPresentationStyle = .FormSheet
        vc.delegate = self
        self.presentViewController(vc, animated: true, completion: nil)
    }

    func userDidCancel(controller: RefineArtworksViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func userDidApply(settings: AuctionRefineSettings, controller: RefineArtworksViewController) {
        
    }
}