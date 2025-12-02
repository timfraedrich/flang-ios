import FlangOnline
import FlangOnlineUI
import SwiftUI

struct LobbyScene: View {

    @Environment(Router.self) private var router
    @Environment(SessionManager.self) private var sessionManager
    @Environment(OnlineGameService.self) private var onlineGameService
    @State private var lobby: OnlineGameRequestLobby?
    @State private var activeGames: [OnlineGameInfo] = []
    @State private var isLoading = false
    @State private var error: String?
    
    init() {}

    var body: some View {
        List {
            // Active Games Section
            if !activeGames.isEmpty {
                Section("my_active_games") {
                    ForEach(activeGames, id: \.gameId) { game in
                        NavigationLink(value: NavigationDestination.onlineGame(id: game.gameId)) {
                            ActiveGameRow(game: game)
                        }
                        .tint(.primary)
                    }
                }
            }

            // Game Requests Section
            if let lobby {
                if !lobby.liveRequests.isEmpty {
                    Section("live_game_requests") {
                        ForEach(lobby.liveRequests, id: \.id) { request in
                            if request.requester.username != sessionManager.status.username {
                                GameRequestRow(liveRequest: request) {
                                    acceptLiveGameRequest(id: request.id)
                                }
                            }
                        }
                    }
                }

                if !lobby.dailyRequests.isEmpty {
                    Section("daily_game_requests") {
                        ForEach(lobby.dailyRequests, id: \.id) { request in
                            let userIsRequester = request.requester.username == sessionManager.status.username
                            GameRequestRow(dailyRequest: request, userIsRequester: userIsRequester) {
                                if userIsRequester {
                                    cancelDailyGameRequest(id: request.id)
                                } else {
                                    acceptDailyGameRequest(id: request.id)
                                }
                            }
                        }
                    }
                }
            }

            // Empty state
            if lobby?.liveRequests.isEmpty == true && lobby?.dailyRequests.isEmpty == true && activeGames.isEmpty {
                Section {
                    VStack(spacing: 16) {
                        Image(systemName: "person.2.slash")
                            .font(.system(size: 50))
                            .foregroundStyle(.secondary)
                        Text("no_active_games")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Text("create_request_prompt")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                }
            }
        }
        .navigationTitle("game_lobby")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink(value: NavigationDestination.createOnlineGameRequest) {
                    Image(systemName: "plus")
                }
            }
        }
        .alert("title_error", isPresented: .constant(error != nil)) {
            Button("ok") { error = nil }
        } message: {
            if let error {
                Text(error)
            }
        }
        .task(loadData)
        .refreshable(action: loadData)
    }

    private func loadData() async {
        isLoading = true
        await loadActiveGames()
        loadLobby()
        isLoading = false
    }

    private func loadActiveGames() async {
        do {
            activeGames = try await onlineGameService.getActiveGames()
        } catch {
            self.error = String(localized: "lobby_error_load_games_\(error.localizedDescription)")
        }
    }

    private func loadLobby() {
        Task {
            do {
                lobby = try await onlineGameService.getGameRequestLobby()
            } catch {
                self.error = String(localized: "lobby_error_load_lobby_\(error.localizedDescription)")
            }
        }
    }

    private func acceptLiveGameRequest(id: Int) {
        Task {
            do {
                let gameId = try await onlineGameService.acceptLiveGameRequest(id: id)
                router.path.append(NavigationDestination.onlineGame(id: gameId))
            } catch {
                self.error = String(localized: "lobby_error_accept_request_\(error.localizedDescription)")
            }
        }
    }

    private func acceptDailyGameRequest(id: Int) {
        Task {
            do {
                let gameId = try await onlineGameService.acceptDailyGameRequest(id: id)
                router.path.append(NavigationDestination.onlineGame(id: gameId))
            } catch {
                self.error = String(localized: "lobby_error_accept_daily_request_\(error.localizedDescription)")
            }
        }
    }
    
    private func cancelDailyGameRequest(id: Int) {
        Task {
            do {
                try await onlineGameService.cancelDailyGameRequest(id: id)
                lobby = try await onlineGameService.getGameRequestLobby()
            } catch {
                self.error = String(localized: "lobby_error_cancel_request_\(error.localizedDescription)")
            }
        }
    }
}
