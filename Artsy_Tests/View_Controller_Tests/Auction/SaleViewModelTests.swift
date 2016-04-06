import Quick
import Nimble
@testable
import Artsy

class SaleViewModelTests: QuickSpec {
    override func spec() {
        let sale = try! Sale(dictionary: ["name": "The 🎉 Sale"], error: Void())
        let saleArtworks = [
            testSaleArtworkEstimateAt(500),
            testSaleArtworkEstimateAt(1500)
        ]

        it("returns correct banner image") {
            let url = "http://example.com"
            sale.setValue(["wide": url] as NSDictionary, forKey: "imageURLs")

            let subject = SaleViewModel(sale: sale, saleArtworks: saleArtworks)

            expect(subject.backgroundImageURL?.absoluteString) == url
        }

        it("returns correct avatar image") {
            let url = "http://example.com"
            sale.profile = try! Profile(dictionary:  ["iconURLs": ["square": url]], error: Void())

            let subject = SaleViewModel(sale: sale, saleArtworks: saleArtworks)

            expect(subject.profileImageURL?.absoluteString) == url
        }

        describe("pruning items when refining") {
            var subject: SaleViewModel!

            beforeEach {
                subject = SaleViewModel(sale: sale, saleArtworks: saleArtworks)
            }

            it("includes high and low inclusive") {
                let refinedArtworks = subject.refinedSaleArtworks(AuctionRefineSettings(ordering: .LotNumber, priceRange: (min: 500, max: 1500), saleViewModel: subject))

                expect(refinedArtworks.count) == 2
            }

            it("excludes low low estimates") {
                let refinedArtworks = subject.refinedSaleArtworks(AuctionRefineSettings(ordering: .LotNumber, priceRange: (min: 1000, max: 1500), saleViewModel: subject))

                expect(refinedArtworks.count) == 1
            }

            it("excludes high low estimates") {
                let refinedArtworks = subject.refinedSaleArtworks(AuctionRefineSettings(ordering: .LotNumber, priceRange: (min: 500, max: 1000), saleViewModel: subject))

                expect(refinedArtworks.count) == 1
            }
        }

        it("calculates a lowEstimate range") {
            let subject = SaleViewModel(sale: sale, saleArtworks: saleArtworks)

            let range = subject.lowEstimateRange

            expect(range.min) == 500
            expect(range.max) == 1500
        }

        it("calculates a lowEstimate range when a lowEstimate is nil") {
            let nilInfestedSaleArtworks = saleArtworks + [testSaleArtworkEstimateAt(nil)]
            let subject = SaleViewModel(sale: sale, saleArtworks: nilInfestedSaleArtworks)

            expect(subject.lowEstimateRange).notTo( raiseException() )
        }

        it("calculates a lowEstimate range when all lowEstimates are nil") {
            let subject = SaleViewModel(sale: sale, saleArtworks: [testSaleArtworkEstimateAt(nil)])

            expect(subject.lowEstimateRange).notTo( raiseException() )
        }

        it("deals with auctions that have not started ") {
            let sale = testSaleWithDates(NSDate.distantFuture(), end: NSDate.distantFuture())
            let subject = SaleViewModel(sale: sale, saleArtworks: [])

            expect(subject.saleAvailability) == SaleAvailabilityState.NotYetOpen
        }

        it("deals with auctions that have finished ") {
            let sale = testSaleWithDates(NSDate.distantPast(), end: NSDate.distantPast())
            let subject = SaleViewModel(sale: sale, saleArtworks: [])

            expect(subject.saleAvailability) == SaleAvailabilityState.Closed
        }

        it("deals with auctions that are active ") {
            let sale = testSaleWithDates(NSDate.distantPast(), end: NSDate.distantFuture())
            let subject = SaleViewModel(sale: sale, saleArtworks: [])

            expect(subject.saleAvailability) == SaleAvailabilityState.Active
        }

    }
}

func testSaleWithDates(start: NSDate, end: NSDate) -> Sale {
    return try! Sale(dictionary: ["name": "The 🎉 Sale", "startDate": start, "endDate": end], error: Void())
}

func testSaleArtworkEstimateAt(lowEstimate: Int?) -> SaleArtwork {
    return try! SaleArtwork(dictionary: [
        "saleArtworkID" : "sale-artwrrrrrk",
        "lowEstimateCents" : lowEstimate ?? NSNull(),
        "artwork" : [:]
        ], error: Void())
}