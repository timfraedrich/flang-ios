import Charts
import FlangOnline
import FlangOnlineUI
import SwiftUI

struct PlayerProfileScene: View {

    private let username: String

    @Environment(SessionManager.self) private var sessionManager
    @Environment(CommunityService.self) private var communityService
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    @Environment(\.dismiss) private var dismiss
    @State private var playerProfile: PlayerProfile?
    @State private var gameHistory: [OnlineGameInfo] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showAllGames = false
    @State private var confirmLogOut = false
    
    private let maxGamesPreview = 42
    
    private func loadProfile() async {
        isLoading = true
        errorMessage = nil
        do {
            playerProfile = try await communityService.getUserProfile(username: username)
            await loadHistory()
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    private func loadHistory() async {
        do {
            gameHistory = try await communityService.getUserGames(username: username, max: showAllGames ? nil : maxGamesPreview, offset: 0)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    init(username: String) {
        self.username = username
    }

    var body: some View {
        ZStack {
            if let playerProfile {
                List {
                    mainSection(for: playerProfile)
                    ratingsSection(for: playerProfile)
                    ratingHistorySection(for: playerProfile)
                    gameHistorySection(for: gameHistory)
                }
            } else if isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .controlSize(.large)
                    Text("loading_profile")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundStyle(.tint)
                    VStack {
                        Text("error_loading_profile")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .multilineTextAlignment(.center)
                    Button("retry") {
                        Task {
                            await loadProfile()
                        }
                    }
                    .buttonStyle(.glassProminent)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .tint(.red)
            }
        }
        .navigationTitle(String(localized: "player_profile_title_\(username)"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .title) {
                Color.clear
            }
            if sessionManager.username == username {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("logout", role: .destructive) {
                        confirmLogOut = true
                    }.confirmationDialog("logout", isPresented: $confirmLogOut) {
                        Button("logout", role: .destructive) {
                            do {
                                try sessionManager.logout()
                                dismiss()
                            } catch {}
                        }
                    } message: {
                        Text("confirm_logout_message")
                    }
                    .tint(.red)
                }
            }
        }
        .task(loadProfile)
        .refreshable(action: loadProfile)
    }
    
    @ViewBuilder
    private func mainSection(for playerProfile: PlayerProfile) -> some View {
        Section {
            VStack(spacing: 12) {
                Image(systemName: playerProfile.isBot ? "cpu.fill" : "person.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(playerProfile.isBot ? .blue : .primary)
                VStack(spacing: 8) {
                    HStack {
                        if playerProfile.isOnline {
                            Circle().fill(.green).frame(width: 8, height: 8)
                        }
                        UserLabel(username: playerProfile.username, title: playerProfile.title, isBot: playerProfile.isBot).font(.title)
                    }
                    Group {
                        Text("member_since_\(playerProfile.registrationDate.formatted(date: .long, time: .omitted))")
                        Text("games_count_\(playerProfile.completedGames.description)")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .listRowBackground(Color.clear)
        }
    }
    
    @ViewBuilder
    private func ratingsSection(for playerProfile: PlayerProfile) -> some View {
        Section {
            HStack(spacing: 12) {
                ForEach(playerProfile.ratings, id: \.type.hashValue) { rating in
                    LabeledContent(rating.type.localized) {
                        RatingLabel(rating: rating.value)
                    }
                }
            }
            .backgroundStyle(colorScheme == .dark ? AnyShapeStyle(.background.secondary) : AnyShapeStyle(.background))
            .labeledContentStyle(.statBox)
            .listRowBackground(Color.clear)
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
    }
    
    @ViewBuilder
    private func ratingHistorySection(for playerProfile: PlayerProfile) -> some View {
        if !playerProfile.history.isEmpty {
            Section("rating_history") {
                Chart {
                    ForEach(playerProfile.history, id: \.date) { entry in
                        let x: PlottableValue = .value(String(localized: "title_date"), entry.date)
                        let y: PlottableValue = .value(String(localized: "rating"), abs(entry.rating))
                        let series: PlottableValue = .value(entry.type.localized, entry.type.rawValue)
                        LineMark(x: x, y: y, series: series)
                            .foregroundStyle(by: series)
                            .interpolationMethod(.linear)
                    }
                }
                .frame(height: 200)
                .padding([.leading, .bottom], 16)
                .padding([.trailing, .top], 32)
                .chartYAxis { AxisMarks(position: .leading) }
                .chartLegend(position: .bottom, alignment: .trailing)
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
        }
    }
    
    @ViewBuilder
    private func gameHistorySection(for gameHistory: [OnlineGameInfo]) -> some View {
        if !gameHistory.isEmpty {
            Section {
                ForEach(gameHistory, id: \.gameId) { game in
                    NavigationLink(value: NavigationDestination.onlineGame(id: game.gameId)) {
                        GameHistoryRow(game: game, currentUsername: username)
                    }
                }
            } header: {
                HStack {
                    Text("game_history")
                    Spacer()
                    if !showAllGames {
                        Button("show_all") {
                            showAllGames = true
                            Task { await loadHistory() }
                        }
                        .font(.subheadline.weight(.semibold))
                    }
                }
            }
        }
    }
}
