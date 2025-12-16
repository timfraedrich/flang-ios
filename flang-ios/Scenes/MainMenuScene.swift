import FlangModel
import FlangOnline
import FlangOnlineUI
import FlangUI
import SwiftUI

struct MainMenuScene: View {
    
    @Environment(Router.self) private var router
    @Environment(SessionManager.self) private var sessionManager
    @Environment(\.fontResolutionContext) var fontContext
    @State private var showLoadError = false
    @State private var loadErrorMessage = ""
    
    var body: some View {
        VStack(spacing: .zero) {
            Spacer()
            VStack(spacing: 8) {
                Image("flang_transparent")
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.primary)
                    .frame(height: 80)
                Text("title_flang")
                    .fontWidth(.expanded)
                    .font(.system(size: 48, weight: .heavy))

            }
            Spacer()
            VStack(spacing: 16) {
                menuButton("menu_button_new_local_game", systemName: "plus.circle.fill", color: .blue) {
                    router.path.append(NavigationDestination.game(nil))
                }
                menuButton("menu_button_play_online", systemName: "globe", color: .purple) {
                    if sessionManager.isLoggedIn {
                        router.path.append(NavigationDestination.lobby)
                    } else {
                        router.sheets.append(.authentication)
                    }
                }
                menuButton("menu_button_community", systemName: "trophy.fill", color: .orange) {
                    router.path.append(NavigationDestination.community)
                }
                menuButton("menu_button_load_clipboard", systemName: "doc.on.clipboard.fill", color: .green) {
                    loadFromClipboard()
                }
            }
            .padding(.horizontal, 32)
            Spacer()
        }
        .ignoresSafeArea()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    switch sessionManager.status {
                    case .loggedIn(let username, _):
                        router.path.append(NavigationDestination.playerProfile(username: username))
                    case .loggedOut:
                        router.sheets.append(.authentication)
                    case .tryingToRestoreSession:
                        break
                    }
                } label: {
                    switch sessionManager.status {
                    case .loggedIn:
                        Image(systemName: "person.crop.circle.fill")
                    case .loggedOut:
                        Image(systemName: "person.crop.circle")
                    case .tryingToRestoreSession:
                        ProgressView()
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    router.sheets.append(.settings)
                } label: {
                    Image(systemName: "gear")
                }
            }
        }
        .alert("load_error", isPresented: $showLoadError) {
            Button("ok", role: .cancel) { }
        } message: {
            Text(loadErrorMessage)
        }
        .navigationTitle("main_menu")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .title) {
                Color.clear
            }
        }
    }
    
    @ViewBuilder
    private func menuButton(_ key: LocalizedStringKey, systemName: String, color: Color, action: @escaping () -> Void) -> some View {
        let font = Font.title3
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: systemName)
                Text(key)
                Spacer()
                Image(systemName: "chevron.forward")
            }
            .frame(height: font.resolve(in: fontContext).pointSize)
            .font(font.weight(.semibold))
            .padding(24)
            .glassEffect(.regular.interactive().tint(color.opacity(0.2)), in: .containerRelative)
            .contentShape(.containerRelative)
            .containerShape(.capsule)
        }
        .foregroundStyle(.tint)
        .tint(color)
        .buttonStyle(.plain)
    }

    private func loadFromClipboard() {
        guard let clipboardString = UIPasteboard.general.string else {
            loadErrorMessage = String(localized: "clipboard_empty_error")
            showLoadError = true
            return
        }
        let trimmed = clipboardString.trimmingCharacters(in: .whitespacesAndNewlines)
        // Try to parse as FMNe (starts with !)
        if trimmed.starts(with: "!"), let game = Game(fromFMNe: trimmed) {
            router.path.append(game)
            return
        }
        // Try to parse as FBN (starts with + or -)
        if trimmed.starts(with: "+") || trimmed.starts(with: "-"), let game = Game(fromFBN: trimmed) {
            router.path.append(game)
            return
        }
        // Try to parse as FMN (space-separated moves)
        if let game = Game(fromFMN: trimmed) {
            router.path.append(game)
            return
        }
        // If all parsing attempts failed
        loadErrorMessage = String(localized: "clipboard_parse_error_\(trimmed.prefix(100))")
        showLoadError = true
    }
}
