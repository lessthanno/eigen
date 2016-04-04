import Quick
import Nimble
import Nimble_Snapshots
import UIKit
import ISO8601DateFormatter
import OHHTTPStubs

@testable
import Artsy

class AuctionInformationViewControllerSpec: QuickSpec {
    override func spec() {
        let start = ISO8601DateFormatter().dateFromString("2016-02-18T10:00:00+00:00")!
        let end = ISO8601DateFormatter().dateFromString("2025-02-18T23:59:00+00:00")!
        let description = "On Thursday, November 12, Swiss Institute will host their Annual Benefit Dinner & Auction–the most important fundraising event of the year–with proceeds going directly towards supporting their innovative exhibitions and programs. Since 1986, Swiss Institute has been dedicated to promoting forward-thinking and experimental art."
        let sale = try! Sale(dictionary: ["saleID": "the-tada-sale", "name": "Sotheby’s Boundless Contemporary", "saleDescription": description, "startDate": start, "endDate": end ], error: Void())
        let saleViewModel = SaleViewModel(sale: sale, saleArtworks: [])

        let markdown = "# Other Requests\n## Can you tell me the worth of my artwork?\n\nArtsy does not provide appraisal or authentication services for individual sellers. We recommend reaching out to professional dealers, galleries, and auction houses for assistance.\n\nFor any further questions, please contact [support@artsy.net](mailto:support@artsy.net)."

        var navigationController: ARSerifNavigationViewController!
        var informationController: AuctionInformationViewController!
        
        beforeEach {
            informationController = AuctionInformationViewController(saleViewModel: saleViewModel)
            navigationController = ARSerifNavigationViewController(rootViewController: informationController)

            for entry in informationController.FAQEntries {
                OHHTTPStubs.stubJSONResponseAtPath("/api/v1/page/\(entry.slug)", withResponse:["published":true, "content": markdown])
            }
        }
        
        ["iPhone": ARDeviceType.Phone6.rawValue, "iPad": ARDeviceType.Pad.rawValue].forEach { (deviceName, deviceType) in
            it("has a root view that shows information about the auction and looks good on \(deviceName)") {
                ARTestContext.useDevice(ARDeviceType(rawValue: deviceType)!) {
                    expect(navigationController).to( haveValidSnapshot() )
                }
            }
        }
        
        it("has a FAQ view that answers questions about the auction") {
            let FAQController = informationController.showFAQ(false)
            expect(navigationController).to( haveValidSnapshot(named: "FAQ Initial Entry") )

            for (index, view) in FAQController.entryViews.enumerate() {
                view.didTap()
                let entry = FAQController.entries[index]
                expect(navigationController).to( haveValidSnapshot(named: "FAQ Entry: \(entry.name)"))
            }
        }
    }
}
