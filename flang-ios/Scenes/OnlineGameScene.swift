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
    
    private var showError: Binding<Bool> {
        .init {
            errorMessage != nil
        } set: { showError in
            guard !showError else { return }
            errorMessage = nil
        }
    }
    
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
        .alert("title_error", isPresented: showError) {
            Button("dismiss") {}
        } message: {
            Text(errorMessage ?? String(localized: "error_unknown"))
        }
        .onChange(of: onlineGameState?.playerColor) { oldValue, newValue in
            guard oldValue == nil, let newValue else { return }
            perspective = newValue == .white ? .singlePlayerWhite : .singlePlayerBlack
        }
        .navigationTitle(String(localized: "online_game_title_\(gameId.formatted())"))
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
        .alert("share", isPresented: $showShareSheet) {
            Button("share_game") {
                if let fmn = try? onlineGameState.game.toFMN() {
                    UIPasteboard.general.string = fmn
                }
            }
            Button("share_board") {
                UIPasteboard.general.string = onlineGameState.game.toFBN()
            }
            Button("cancel", role: .cancel) { }
        } message: {
            Text("share_clipboard_message")
        }
        .alert("resign", isPresented: $showResignConfirmation) {
            Button("resign", role: .destructive) {
                Task {
                    try? await onlineGameState.resign()
                }
            }
            Button("cancel", role: .cancel) { }
        } message: {
            Text("confirm_resign_message")
        }
    }
    
    @ViewBuilder private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView().controlSize(.large)
            Text("loading_game").foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func errorView(for onlineGameState: OnlineGameState, and error: Error) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundStyle(.tint)
            Text("error_loading_game")
                .font(.headline)
            Text(error.localizedDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
            Button("retry") {
                Task {
                    try? await onlineGameState.start()
                }
            }
            .buttonStyle(.glassProminent)
            Button("dismiss", action: dismissAction.callAsFunction)
        }
        .tint(.red)
        .multilineTextAlignment(.center)
        .padding()
    }

    @ViewBuilder private var fallbackView: some View {
        VStack {
            Text("error_generic")
            Button("dismiss", action: dismissAction.callAsFunction)
        }
    }
}
