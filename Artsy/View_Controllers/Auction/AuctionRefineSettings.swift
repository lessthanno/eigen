struct AuctionRefineSettings {

    let ordering: AuctionOrderingSwitchValue
    var priceRange: PriceRange?
    var saleViewModel: SaleViewModel
}

extension AuctionRefineSettings {
    func settingsWithOrdering(ordering: AuctionOrderingSwitchValue) -> AuctionRefineSettings {
        return AuctionRefineSettings(ordering: ordering, priceRange:priceRange, saleViewModel:saleViewModel)
    }

    func settingsWithRange(range: PriceRange) -> AuctionRefineSettings {
        return AuctionRefineSettings(ordering: self.ordering, priceRange:range, saleViewModel:saleViewModel)
    }
    
    func saleID() -> NSString {
        return saleViewModel.saleID
    }
}

extension AuctionRefineSettings: RefinableType {
    
    var priceRangePrompt: String? {
        return nil
    }
    
    var numberOfSections: Int {
        return 1
    }
    
    func settingsWithSelectedIndexPath(indexPath: NSIndexPath) -> AuctionRefineSettings {
        return settingsWithOrdering(AuctionOrderingSwitchValue.fromIntWithViewModel(indexPath.row, saleViewModel: saleViewModel))
    }
    
    func indexPathOfSelectedOrdering() -> NSIndexPath? {
        if let i = AuctionOrderingSwitchValue.allSwitchValuesWithViewModel(saleViewModel).indexOf(ordering) {
            return NSIndexPath.init(forItem: i, inSection: 0)
        } else {
            return nil
        }
    }
    
    func multipleSelectionAllowedInSection(section: Int) -> Bool {
        return true
    }

    func switchValueAtIndexPath(indexPath: NSIndexPath) -> AuctionOrderingSwitchValue {
        return AuctionOrderingSwitchValue.allSwitchValuesWithViewModel(saleViewModel)[indexPath.row]
    }
    
    func shouldCheckRowAtIndexPath(indexPath: NSIndexPath) -> Bool {
        return ordering == switchValueAtIndexPath(indexPath)
    }
    
    func numberOfRowsPerSection(section: Int) -> Int {
        return AuctionOrderingSwitchValue.allSwitchValuesWithViewModel(saleViewModel).count
    }
    
    func titleForRow(row: Int, inSection section: Int) -> String {
        return AuctionOrderingSwitchValue.allSwitchValuesWithViewModel(saleViewModel)[row].rawValue
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
