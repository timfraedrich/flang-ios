import Foundation

public struct OnlineGameInfo: Codable, Sendable {
    public let gameId: Int
    public let white: PlayerInfo
    public let black: PlayerInfo
    public let fmn: String
    public let moves: Int
    public let running: Bool
    public let configuration: OnlineGameConfiguration
    public let lastAction: Date
    /// Indicates the reason for winning.
    ///
    /// A value of `0` means the win is either undetermined or there was a draw if `running == false`. If the value is greater than 0 white
    /// wins, otherwise if it is smaller than 0 black wins. The absolute value determines winning reason as follows:
    /// - 1 Flang (king capture)
    /// - 2 Flang (base)
    /// - 4 resigned
    /// - 8 timeout
    public let won: Int
    public let spectatorCount: Int
    
    public init(
        gameId: Int,
        white: PlayerInfo,
        black: PlayerInfo,
        fmn: String,
        moves: Int,
        running: Bool,
        configuration: OnlineGameConfiguration,
        lastAction: Date,
        won: Int,
        spectatorCount: Int
    ) {
        self.gameId = gameId
        self.white = white
        self.black = black
        self.fmn = fmn
        self.moves = moves
        self.running = running
        self.configuration = configuration
        self.lastAction = lastAction
        self.won = won
        self.spectatorCount = spectatorCount
    }
    
    private enum CodingKeys: CodingKey {
        case gameId
        case white
        case black
        case fmn
        case moves
        case running
        case configuration
        case lastAction
        case won
        case spectatorCount
    }
    
    public init(from decoder: any Decoder) throws {
        let container: KeyedDecodingContainer<OnlineGameInfo.CodingKeys> = try decoder.container(keyedBy: OnlineGameInfo.CodingKeys.self)
        gameId = try container.decode(Int.self, forKey: OnlineGameInfo.CodingKeys.gameId)
        white = try container.decode(PlayerInfo.self, forKey: OnlineGameInfo.CodingKeys.white)
        black = try container.decode(PlayerInfo.self, forKey: OnlineGameInfo.CodingKeys.black)
        fmn = try container.decode(String.self, forKey: OnlineGameInfo.CodingKeys.fmn)
        moves = try container.decode(Int.self, forKey: OnlineGameInfo.CodingKeys.moves)
        running = try container.decode(Bool.self, forKey: OnlineGameInfo.CodingKeys.running)
        configuration = try container.decode(OnlineGameConfiguration.self, forKey: OnlineGameInfo.CodingKeys.configuration)
        let lastActionTimestamp = try container.decode(Int.self, forKey: OnlineGameInfo.CodingKeys.lastAction)
        lastAction = .init(unixTimestamp: lastActionTimestamp)
        won = try container.decode(Int.self, forKey: OnlineGameInfo.CodingKeys.won)
        spectatorCount = try container.decode(Int.self, forKey: OnlineGameInfo.CodingKeys.spectatorCount)
        
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container: KeyedEncodingContainer<OnlineGameInfo.CodingKeys> = encoder.container(keyedBy: OnlineGameInfo.CodingKeys.self)
        try container.encode(gameId, forKey: OnlineGameInfo.CodingKeys.gameId)
        try container.encode(white, forKey: OnlineGameInfo.CodingKeys.white)
        try container.encode(black, forKey: OnlineGameInfo.CodingKeys.black)
        try container.encode(fmn, forKey: OnlineGameInfo.CodingKeys.fmn)
        try container.encode(moves, forKey: OnlineGameInfo.CodingKeys.moves)
        try container.encode(running, forKey: OnlineGameInfo.CodingKeys.running)
        try container.encode(configuration, forKey: OnlineGameInfo.CodingKeys.configuration)
        try container.encode(lastAction.unixTimestamp, forKey: OnlineGameInfo.CodingKeys.lastAction)
        try container.encode(won, forKey: OnlineGameInfo.CodingKeys.won)
        try container.encode(spectatorCount, forKey: OnlineGameInfo.CodingKeys.spectatorCount)
    }
}
