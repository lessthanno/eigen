import Quick
import Nimble
import Nimble_Snapshots
import Interstellar
import UIKit

@testable
import Artsy

class LiveBiddingViewControllerTests: QuickSpec {
    override func spec() {
        it("looks good on iphone 6") {

            let subject = UIStoryboard.Scene.LiveAuctionsBidding.bidViewController()
            let salesPerson = Fake_AuctionsSalesPerson()

            subject.loadViewProgrammatically()
            subject.auctionLotViewModel = salesPerson.lotViewModelForIndex(1)

            expect(subject).to( haveValidSnapshot() )
        }
        it("looks good on ipad") {
            ARTestContext.useDevice(.Pad) {
                let subject = UIStoryboard.Scene.LiveAuctionsBidding.bidViewController()
                let salesPerson = Fake_AuctionsSalesPerson()

                subject.loadViewProgrammatically()
                subject.auctionLotViewModel = salesPerson.lotViewModelForIndex(1)

                expect(subject).to( haveValidSnapshot() )
            }
        }
    }
}
