import FlangOnline
import FlangOnlineUI
import SwiftUI

struct CommunityScene: View {

    @Environment(CommunityService.self) private var communityService
    @State private var topPlayers: [UserInfo] = []
    @State private var onlinePlayers: [UserInfo] = []
    @State private var searchResults: [UserInfo] = []
    @State private var searchText = ""
    @State private var isLoadingTop = false
    @State private var isLoadingOnline = false
    @State private var isSearching = false
    @State private var error: String?
    @State private var selectedTab: Tab? = .top
    @State private var showingSearch: Bool = false
    
    init() {}

    var body: some View {
        ZStack {
            GeometryReader { proxy in
                ScrollView(.horizontal) {
                    LazyHStack(spacing: .zero) {
                        ForEach(Tab.allCases, id: \.hashValue) { tab in
                            switch tab {
                            case .top: topPlayersView
                            case .online: onlinePlayersView
                            case .search: searchView
                            }
                        }
                        .frame(width: proxy.size.width)
                    }
                    .scrollTargetLayout()
                }
                .scrollIndicators(.hidden, axes: .horizontal)
                .scrollTargetBehavior(.paging)
                .scrollPosition(id: $selectedTab)
                .safeAreaInset(edge: .top) {
                    Picker("view", selection: $selectedTab) {
                        Text("tab_top_players").tag(Tab.top)
                        Text("tab_online").tag(Tab.online)
                        Text("search").tag(Tab.search)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                }
            }
        }
        .navigationTitle("tab_community")
        .navigationBarTitleDisplayMode(.inline)
        .task(loadData)
        .searchable(text: $searchText, isPresented: $showingSearch)
        .onChange(of: showingSearch) { oldValue, newValue in
            guard oldValue == false, newValue == true else { return }
            selectedTab = .search
        }
        .onChange(of: searchText) { oldValue, newValue in
            let old = oldValue.trimmingCharacters(in: .whitespacesAndNewlines)
            let new = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
            guard old != new else { return }
            selectedTab = .search
            performSearch()
        }
    }

    // MARK: - Top Players View

    private var topPlayersView: some View {
        Group {
            if isLoadingTop && topPlayers.isEmpty {
                loadingView
            } else {
                Group {
                    if let error, topPlayers.isEmpty {
                        errorView(message: error)
                    } else if topPlayers.isEmpty {
                        emptyView(message: String(localized: "community_empty_top_players"))
                    } else {
                        userList(for: topPlayers, showRank: true)
                    }
                }
                .refreshable(action: loadTopPlayers)
            }
        }
        .id(Tab.top)
    }

    // MARK: - Online Players View

    private var onlinePlayersView: some View {
        Group {
            if isLoadingOnline && onlinePlayers.isEmpty {
                loadingView
            } else {
                Group {
                    if let error, onlinePlayers.isEmpty {
                        errorView(message: error)
                    } else if onlinePlayers.isEmpty {
                        emptyView(message: String(localized: "community_empty_online"))
                    } else {
                        userList(for: onlinePlayers)
                    }
                }
                .refreshable(action: loadOnlinePlayers)
            }
        }
        .id(Tab.online)
    }

    // MARK: - Search View

    private var searchView: some View {
        Group {
            if isSearching {
                loadingView
            } else if searchText.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 50))
                        .foregroundStyle(.secondary)
                    Text("search_players")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text("search_placeholder")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if searchResults.isEmpty && !isSearching {
                emptyView(message: String(localized: "community_search_no_results_\(searchText)"))
            } else {
                userList(for: searchResults)
            }
        }
        .id(Tab.search)
    }

    // MARK: - Helper Views
    
    @ViewBuilder
    private func userList(for userInfos: [UserInfo], showRank: Bool = false) -> some View {
        List {
            ForEach(Array(userInfos.enumerated()), id: \.element.username) { index, userInfo in
                NavigationLink(value: NavigationDestination.playerProfile(username: userInfo.username)) {
                    UserRow(user: userInfo, rank: showRank ? index + 1 : nil)
                }
            }
        }
        .listStyle(.plain)
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("loading")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundStyle(.red)
            Text("title_error")
                .font(.headline)
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("retry") {
                Task {
                    await loadData()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func emptyView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)
            Text(message)
                .font(.headline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Data Loading

    private func loadData() async {
        await loadTopPlayers()
        await loadOnlinePlayers()
    }

    private func loadTopPlayers() async {
        isLoadingTop = true
        error = nil

        do {
            topPlayers = try await communityService.getTopPlayers()
        } catch {
            self.error = error.localizedDescription
        }

        isLoadingTop = false
    }

    private func loadOnlinePlayers() async {
        isLoadingOnline = true
        error = nil
        do {
            onlinePlayers = try await communityService.getOnlinePlayers()
        } catch {
            self.error = error.localizedDescription
        }
        isLoadingOnline = false
    }

    private func performSearch() {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
            searchResults = []
            return
        }
        Task {
            isSearching = true
            error = nil
            do {
                searchResults = try await communityService.searchUsers(username: searchText)
            } catch {
                self.error = error.localizedDescription
                searchResults = []
            }
            isSearching = false
        }
    }
    
    enum Tab: Hashable, CaseIterable {
        case top
        case online
        case search
    }
}
