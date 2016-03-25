struct AuctionRefineSettings {

    let ordering: AuctionOrderingSwitchValue
    var priceRange: PriceRange?
    var saleViewModel: SaleViewModel?
}

extension AuctionRefineSettings {
    func settingsWithOrdering(ordering: AuctionOrderingSwitchValue) -> AuctionRefineSettings {
        return AuctionRefineSettings(ordering: ordering, priceRange:priceRange, saleViewModel:saleViewModel)
    }

    func settingsWithRange(range: PriceRange) -> AuctionRefineSettings {
        return AuctionRefineSettings(ordering: self.ordering, priceRange:priceRange, saleViewModel:saleViewModel)
    }
}

extension AuctionRefineSettings: RefinableType {
    
    var priceRangePrompt: String? {
        return nil
    }
    
    var numberOfSections: Int {
        return 1
    }
    
    func numberOfRowsPerSection(section: Int) -> Int {
        return 3
    }
    
    func titleForRow(row: Int, inSection section: Int) -> String {
        return "title"
    }
    
    func refineSettingsWithPriceRange(range: PriceRange) -> AuctionRefineSettings {
        return self
    }
    
    func refineSettingsWithSelectedRow(row: Int, inSection section: Int) -> AuctionRefineSettings {
        return self
    }
}

extension AuctionRefineSettings: Equatable {}

func ==(lhs: AuctionRefineSettings, rhs: AuctionRefineSettings) -> Bool {
    guard lhs.ordering == rhs.ordering else { return false }
    
    if let lhsRange = lhs.priceRange, rhsRange = rhs.priceRange {
        guard lhsRange.min == rhsRange.min else { return false }
        guard lhsRange.max == rhsRange.max else { return false }
    }
    return true
}
