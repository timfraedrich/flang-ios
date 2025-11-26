import FlangModel
import FlangOnline
import FlangOnlineUI
import FlangUI
import SwiftUI

struct OnlineGameScene: View {

    @Environment(\.dismiss) private var dismissAction
    @Environment(Router.self) private var router
    @Environment(SessionManager.self) private var sessionManager
    @Environment(OnlineGameService.self) private var onlineGameService
    @State private var onlineGameState: OnlineGameState?
    @State private var perspective: BoardView.Perspective = .singlePlayerWhite
    @State private var showShareSheet = false
    @State private var showResignConfirmation = false
    @State private var errorMessage: String?
    
    private let gameId: Int

    init(gameId: Int) {
        self.gameId = gameId
    }

    var body: some View {
        ZStack {
            if let onlineGameState, let onlineGameInfo = onlineGameState.gameInfo {
                activeGameView(for: onlineGameState, and: onlineGameInfo)
            } else if let onlineGameState, onlineGameState.isActive == true {
                loadingView
            } else if let onlineGameState, let error = onlineGameState.error {
                errorView(for: onlineGameState, and: error)
            } else {
                fallbackView
            }
        }
        .padding(.horizontal)
        .task {
            // Initialize GameSyncService with the apiService from environment
            onlineGameState = OnlineGameState(gameId: gameId, sessionManager: sessionManager, onlineGameService: onlineGameService)
            do {
                try await onlineGameState?.start()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
        .onDisappear {
            onlineGameState?.stop()
        }
    }
    
    @ViewBuilder
    private func activeGameView(for onlineGameState: OnlineGameState, and onlineGameInfo: OnlineGameInfo) -> some View {
        GeometryReader { proxy in
            VStack(spacing: 16) {
                OnlineGameView(
                    onlineGameState: onlineGameState,
                    perspective: perspective,
                    onPlayerSelection: { playerInfo in
                        router.path.append(NavigationDestination.playerProfile(username: playerInfo.username))
                    }
                )
                GameControls(
                    isFirstPlayerPerspective: true,
                    backEnabled: onlineGameState.backEnabled,
                    forwardEnabled: onlineGameState.forwardEnabled,
                    closeAction: {
                        onlineGameState.stop()
                        dismissAction()
                    },
                    shareAction: { showShareSheet = true },
                    rotateBoardAction: { perspective.rotate() },
                    backwardAction: { try? onlineGameState.back() },
                    forwardAction: { try? onlineGameState.forward() },
                    resignAction: onlineGameState.playerColor != nil ? { showResignConfirmation = true } : nil,
                    canResign: onlineGameState.playerIsAtMove && onlineGameState.winner == nil
                )
            }
            .backgroundStyle(.background.secondary)
            .containerShape(.rect(cornerRadius: 20))
            .padding(.top, max(proxy.safeAreaInsets.top, 20))
            .padding(.bottom, max(proxy.safeAreaInsets.bottom, 20))
            .ignoresSafeArea()
        }
        .alert("Share", isPresented: $showShareSheet) {
            Button("Share Game") {
                if let fmn = try? onlineGameState.game.toFMN() {
                    UIPasteboard.general.string = fmn
                }
            }
            Button("Share Board") {
                UIPasteboard.general.string = onlineGameState.game.toFBN()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("The game or board will be copied to your clipboard in text form.")
        }
        .alert("Resign", isPresented: $showResignConfirmation) {
            Button("Resign", role: .destructive) {
                Task {
                    try? await onlineGameState.resign()
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to resign this game?")
        }
    }
    
    @ViewBuilder private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView().controlSize(.large)
            Text("Loading game...").foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    private func errorView(for onlineGameState: OnlineGameState, and error: Error) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundStyle(.tint)
            Text("Error loading game")
                .font(.headline)
            Text(error.localizedDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
            Button("Retry") {
                Task {
                    try? await onlineGameState.start()
                }
            }
            .buttonStyle(.glassProminent)
            Button("Dismiss", action: dismissAction.callAsFunction)
        }
        .tint(.red)
        .multilineTextAlignment(.center)
        .padding()
    }
    
    @ViewBuilder private var fallbackView: some View {
        VStack {
            Text("Something went wrong.")
            Button("Dismiss", action: dismissAction.callAsFunction)
        }
    }
}
