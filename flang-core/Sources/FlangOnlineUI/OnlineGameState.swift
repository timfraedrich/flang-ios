import Combine
import FlangModel
import FlangOnline
import FlangUI
import Foundation
import Observation

/// Wrapper around GameState that syncs moves with the server
@MainActor
@Observable
public class OnlineGameState {

    private var gameState: GameState
    private let gameId: Int
    private let sessionManager: SessionManager
    private let onlineGameService: OnlineGameService
    private var pollingTaskCancellable: AnyCancellable?
    private let pollingTimeout: Int = 30000
    
    public private(set) var gameInfo: OnlineGameInfo?
    public private(set) var lastUpdate: Date = .now
    public private(set) var isActive = false
    public private(set) var error: Error?
    
    public var game: Game { gameState.game }
    public var board: Board { gameState.board }
    public var selectedPosition: BoardPosition? { gameState.selectedPosition }
    public var legalMoves: Set<BoardPosition> { gameState.legalMoves }
    public var winner: PieceColor? { gameState.winner }
    public var backEnabled: Bool { gameState.backEnabled }
    public var forwardEnabled: Bool { gameState.forwardEnabled }
    
    public var atMove: PieceColor { (gameInfo?.moves ?? 0) % 2 == 0 ? .white : .black }
    public var playerIsAtMove: Bool { atMove == playerColor }
    public var playerColor: PieceColor? {
        guard let gameInfo, let username = sessionManager.username else { return nil }
        return if gameInfo.white.username == username {
            .white
        } else if gameInfo.black.username == username {
            .black
        } else {
            nil
        }
    }
    
    public init(gameId: Int, sessionManager: SessionManager, onlineGameService: OnlineGameService) {
        self.gameState = .init()
        self.gameId = gameId
        self.sessionManager = sessionManager
        self.onlineGameService = onlineGameService
    }

    // MARK: - Game Interaction
    
    /// Start syncing the game
    public func start() async throws {
        guard !isActive else { return }
        isActive = true
        error = nil
        // Initial fetch
        try await fetchGame(timeout: nil)
        // Start long polling
        startPolling()
    }

    /// Stop syncing the game
    public func stop() {
        isActive = false
        pollingTaskCancellable?.cancel()
    }
    
    /// Handle position selection, sending moves to server when made
    public func selectPosition(_ position: BoardPosition) async throws {
        guard gameInfo != nil else { throw GameSyncError.noGameLoaded }
        guard playerIsAtMove else { throw GameSyncError.notYourTurn }
        if let selectedPos = gameState.selectedPosition, gameState.legalMoves.contains(position) {
            let moveNotation = try Action.move(from: selectedPos, to: position).notation(on: gameState.board)
            try await onlineGameService.executeMove(gameId: gameId, move: moveNotation)
            // Apply locally for immediate feedback
            gameState.selectPosition(position)
            // The next polling cycle will fetch the confirmed game state
        } else {
            gameState.selectPosition(position)
        }
    }

    /// Resign from the game
    public func resign() async throws {
        guard gameInfo != nil else { throw GameSyncError.noGameLoaded }
        guard playerIsAtMove else { throw GameSyncError.notYourTurn }
        try await onlineGameService.resignGame(id: gameId)
        try gameState.resign()
    }
    
    public func back() throws {
        try gameState.back()
    }
    public func forward() throws {
        try gameState.forward()
    }

    // MARK: - Private Methods

    private func fetchGame(expectedMoves: Int? = nil, timeout: Int?) async throws {
        let info = try await onlineGameService.getGame(
            id: gameId,
            expectedMoves: expectedMoves,
            timeout: timeout
        )
        lastUpdate = .now
        gameInfo = info
        // Parse game from FMN
        // We always re-parse to ensure we have the latest state from server
        if let newGame = Game(fromFMN: info.fmn), !Game.isMoveEquivalent(gameState.game, newGame) {
            gameState = GameState(game: newGame)
        }
    }

    private func startPolling() {
        pollingTaskCancellable = Task {
            while isActive && !Task.isCancelled {
                do {
                    // Use current move count for long polling
                    let currentMoves = gameInfo?.moves
                    try await fetchGame(expectedMoves: currentMoves, timeout: pollingTimeout)
                    // Check if game is still running
                    if let info = gameInfo, !info.running {
                        // Game has ended
                        isActive = false
                        break
                    }
                    error = nil
                } catch {
                    // Handle error
                    self.error = error
                    // If unauthorized, stop polling
                    if let apiError = error as? APIError, case .operationFailed(errorCode: 401, _) = apiError {
                        isActive = false
                        break
                    }
                    // Wait a bit before retrying on error
                    try? await Task.sleep(for: .seconds(5))
                }
            }
        }.eraseToAnyCancellable()
    }

    // MARK: - Error

    public enum GameSyncError: Error {
        case noGameLoaded
        case notYourTurn
        case gameNotRunning
    }
}
