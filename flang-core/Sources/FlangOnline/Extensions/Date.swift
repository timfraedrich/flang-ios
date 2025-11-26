import Foundation

extension Date {
    /// Initializes the date given a unix timestamp in milliseconds.
    init(unixTimestamp: Int) {
        self.init(timeIntervalSince1970: .init(unixTimestamp) / 1000)
    }
    
    /// Converts the date to a unix timestamp in milliseconds
    var unixTimestamp: Int {
        Int(timeIntervalSince1970 * 1000)
    }
}
