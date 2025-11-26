import FlangOnline
import Foundation

enum PreviewInstances {
    
    static let userInfo = UserInfo(username: "ezragt", title: "GM", isBot: false, rating: 2000)
    
    static let playerInfo = PlayerInfo(username: "jannis", rating: 2000, ratingDifference: -42, time: 69 * 1000, isBot: false, title: "")
    static let gmPlayerInfo = PlayerInfo(username: "tim", rating: 2000, ratingDifference: -42, time: 42 * 1000, isBot: false, title: "GM")
    static let botPlayerInfo = PlayerInfo(username: "TerminalBot", rating: 2100, ratingDifference: 69, time: 69 * 1000, isBot: true)
    
    static let playerProfile = PlayerProfile(
        username: "TerminalTitan",
        title: nil,
        isBot: false,
        isOnline: true,
        registrationDate: .now.addingTimeInterval(.init(-2 * 24 * 60 * 60)),
        completedGames: 42,
        history: [
            .init(type: .blitz, rating: 1300, date: .now.addingTimeInterval(.init(-2 * 24 * 60 * 60))),
            .init(type: .blitz, rating: 1450, date: .now.addingTimeInterval(.init(-1 * 24 * 60 * 60))),
            .init(type: .blitz, rating: 1500, date: .now)
        ],
        ratings: [
            .init(type: .blitz, value: 1500)
        ]
    )
    
    static let fmn = "b2 b7a6 Hd3 b2 a1 c2 b2 kb7 c1 he6 f2e3 fb5 g2g3 f7f6 Kg2 h5 g4 kb6 Kg3 h7 h4 pg7 Pg5 hg5 Ug5 h6 Pg3 g5"
    
    static let liveGameConfiguration = OnlineGameConfiguration(infiniteTime: false, time: 2 * 60 * 1000, timeIncrement: 1000, isRated: true)
    static let dailyGameConfiguration = OnlineGameConfiguration(infiniteTime: false, time: 24 * 60 * 60 * 1000, timeIncrement: 0, isRated: true)
    
    static let finishedOnlineGameInfo = OnlineGameInfo(
        gameId: 2,
        white: gmPlayerInfo,
        black: playerInfo,
        fmn: fmn,
        moves: 28,
        running: false,
        configuration: liveGameConfiguration,
        lastAction: .now,
        won: 1,
        spectatorCount: 42
    )
    static let runningOnlineGameInfo = OnlineGameInfo(
        gameId: 1,
        white: playerInfo,
        black: botPlayerInfo,
        fmn: fmn,
        moves: 24,
        running: true,
        configuration: liveGameConfiguration,
        lastAction: .now,
        won: 1,
        spectatorCount: 42
    )
    
    static let liveGameRequest = OnlineLiveGameRequest(id: 1, configuration: liveGameConfiguration, requester: userInfo)
    static let dailyGameRequest = OnlineDailyGameRequest(id: 1, configuration: dailyGameConfiguration, requester: userInfo, dateCreated: .now)
}
