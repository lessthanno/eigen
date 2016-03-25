typealias PriceRange = (min: Int, max: Int)

protocol RefinableType: Equatable {
    var numberOfSections: Int { get }
    func numberOfRowsPerSection(section: Int) -> Int
    func titleForRow(row: Int, inSection section: Int) -> String
    
    var priceRange: PriceRange? { get }
    var priceRangePrompt: String? { get }
    
    func refineSettingsWithSelectedRow(row: Int, inSection section: Int) -> Self
    func refineSettingsWithPriceRange(range: PriceRange) -> Self
}

