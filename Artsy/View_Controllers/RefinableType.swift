typealias PriceRange = (min: Int, max: Int)

protocol RefinableType: Equatable {

    // table view
    var numberOfSections: Int { get }
    func numberOfRowsInSection(section: Int) -> Int
    func titleForRowAtIndexPath(indexPath: NSIndexPath) -> String

    // selection
    func allowMultipleSelectionInSection(section: Int) -> Bool
    func shouldCheckRowAtIndexPath(indexPath: NSIndexPath) -> Bool
    func selectedRowsInSection(section: Int) -> [NSIndexPath]

    // price slider
    var priceRange: PriceRange? { get }
    var priceRangePrompt: String? { get }

    // new settings
    func refineSettingsWithSelectedIndexPath(indexPath: NSIndexPath) -> Self
    func refineSettingsWithPriceRange(range: PriceRange) -> Self
}

