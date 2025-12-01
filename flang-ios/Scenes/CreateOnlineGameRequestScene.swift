import FlangOnline
import SwiftUI

struct CreateOnlineGameRequestScene: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(Router.self) private var router: Router
    @Environment(OnlineGameService.self) private var onlineGameService
    @State private var isCreating = false
    @State private var errorMessage: String?
    @State private var gameType: GameType = .live
    @State private var ratingRange: GameRatingRange = .threeHundred
    @State private var isRated = true
    @State private var allowBots = true
    @State private var liveGamePreset: LiveGamePreset? = .blitzFive
    @State private var liveGameDuration: LiveGameDuration = .fiveMinutes
    @State private var liveGameTimeIncrement: LiveGameTimeIncrement = .zero
    @State private var dailyGameMoveDuration: DailyGameMoveDuration = .oneDay
    
    private func createGameRequest() {
        errorMessage = nil
        isCreating = true
        Task {
            do {
                let gameId: Int?
                switch gameType {
                case .daily:
                    gameId = if case .gameStarted(let gameId) = try await onlineGameService.requestDailyGame(
                        isRated: isRated,
                        ratingRange: ratingRange,
                        moveDuration: dailyGameMoveDuration
                    ) {
                        gameId
                    } else {
                        nil
                    }
                case .live:
                    gameId = try await onlineGameService.requestLiveGame(
                        allowBots: allowBots,
                        isRated: isRated,
                        ratingRange: ratingRange,
                        duration: liveGameDuration,
                        timeIncrement: liveGameTimeIncrement
                    )
                }
                await MainActor.run {
                    isCreating = false
                    router.path.removeLast()
                    if let gameId {
                        router.path.append(NavigationDestination.onlineGame(id: gameId))
                    }
                }
            } catch {
                await MainActor.run {
                    isCreating = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    var body: some View {
        Form {
            gameTypeSection
            ratingSection
            configurationSection
        }
        .navigationTitle("create_game_request")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom, content: bottomSafeAreaInset)
        .ignoresSafeArea(.container, edges: .bottom)
        .disabled(isCreating)
    }

    @ViewBuilder private var gameTypeSection: some View {
        Section("game_type") {
            Picker("game_type", selection: $gameType) {
                ForEach(GameType.allCases, id: \.hashValue) { type in
                    Text(type.localized).tag(type)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    @ViewBuilder private var ratingSection: some View {
        Section("rating") {
            Toggle("rated", isOn: $isRated)
            Picker("rating_range", selection: $ratingRange) {
                ForEach(GameRatingRange.allCases, id: \.hashValue) { range in
                    Text(range.description).tag(range)
                }
            }
        }
    }

    @ViewBuilder private var configurationSection: some View {
        Section("game_configuration") {
            switch gameType {
            case .daily:
                Picker("game_time_per_move", selection: $dailyGameMoveDuration) {
                    ForEach(DailyGameMoveDuration.allCases, id: \.hashValue) { duration in
                        Text(duration.description).tag(duration)
                    }
                }
            case .live:
                Toggle("allow_bot_opponents", isOn: $allowBots)
                Picker("game_preset", selection: $liveGamePreset) {
                    ForEach(LiveGamePreset.allCases, id: \.hashValue) { preset in
                        Text(preset.localized).tag(preset)
                    }
                    Text("game_preset_custom").tag(LiveGamePreset?.none)
                }
                if liveGamePreset == nil {
                    Picker("game_duration", selection: $liveGameDuration) {
                        ForEach(LiveGameDuration.allCases, id: \.hashValue) { duration in
                            Text(duration.description).tag(duration)
                        }
                    }
                    Picker("game_increment_per_move", selection: $liveGameTimeIncrement) {
                        ForEach(LiveGameTimeIncrement.allCases, id: \.hashValue) { timeIncrement in
                            Text(timeIncrement.description).tag(timeIncrement)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func bottomSafeAreaInset() -> some View {
        Button(action: createGameRequest) {
            ZStack {
                if isCreating {
                    ProgressView().progressViewStyle(.circular).controlSize(.regular)
                } else {
                    Text("create").bold()
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.glassProminent)
        .controlSize(.large)
        .padding(.init(top: 48, leading: 24, bottom: 32, trailing: 24))
        .background { BackgroundBlackoutGradient(startPoint: .top, endPoint: .center) }
    }
}
