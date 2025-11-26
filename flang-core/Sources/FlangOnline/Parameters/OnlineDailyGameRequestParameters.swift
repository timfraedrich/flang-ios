import Foundation

struct OnlineDailyGameRequestParameters: Encodable {
    let isRated: Bool
    let time: Int
    let range: Int?
}
