// Generated using SwiftGen, by O.Halligon — https://github.com/AliSoftware/SwiftGen

import Foundation
import UIKit

extension UIImage {
  enum Asset : String {
    case ChatIcon = "chat_icon"
    case CloseIcon = "close_icon"
    case InfoIcon = "info_icon"
    case LiveAuctionBidHammer = "live_auction_bid_hammer"
    case LiveAuctionBidWarningOrange = "live_auction_bid_warning_orange"
    case LiveAuctionBidWarningYellow = "live_auction_bid_warning_yellow"
    case LotBidderHammerWhite = "lot_bidder_hammer_white"
    case LotBiddersInfo = "lot_bidders_info"
    case LotLotInfo = "lot_lot_info"
    case LotTimeInfo = "lot_time_info"
    case LotWatchersInfo = "lot_watchers_info"
    case LotsIcon = "lots_icon"

    var image: UIImage {
      return UIImage(asset: self)
    }
  }

  convenience init!(asset: Asset) {
    self.init(named: asset.rawValue)
  }
}
