import FlangModel
import FlangOnline
import FlangOnlineUI
import FlangUI
import SwiftUI

struct MainMenuScene: View {

    @Environment(Router.self) private var router
    @Environment(SessionManager.self) private var sessionManager
    @State private var showLoadError = false
    @State private var loadErrorMessage = ""
    
    var body: some View {
        VStack(spacing: .zero) {
            VStack(spacing: 8) {
                Image("flang_transparent")
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.primary)
                    .frame(height: 80)
                Text("Flang")
                    .fontWidth(.expanded)
                    .font(.system(size: 48, weight: .heavy))
                
            }
            VStack(spacing: 16) {
                menuButton("New Local Game", systemName: "plus.circle.fill", color: .blue) {
                    router.path.append(NavigationDestination.game(nil))
                }
                menuButton("Play Online", systemName: "globe", color: .purple) {
                    if sessionManager.isLoggedIn {
                        router.path.append(NavigationDestination.lobby)
                    } else {
                        router.showAuthentication = true
                    }
                }
                menuButton("Community", systemName: "trophy.fill", color: .orange) {
                    router.path.append(NavigationDestination.community)
                }
                menuButton("Load from Clipboard", systemName: "doc.on.clipboard.fill", color: .green) {
                    loadFromClipboard()
                }
            }
            .padding(.horizontal, 32)
            .frame(maxHeight: .infinity)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    switch sessionManager.status {
                    case .loggedIn(let username, _):
                        router.path.append(NavigationDestination.playerProfile(username: username))
                    case .loggedOut:
                        router.showAuthentication = true
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
        }
        .alert("Load Error", isPresented: $showLoadError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(loadErrorMessage)
        }
        .navigationTitle("Main Menu")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .title) {
                Color.clear
            }
        }
    }
    
    @ViewBuilder
    private func menuButton(_ title: String, systemName: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: systemName)
                Text(title)
                Spacer()
                Image(systemName: "chevron.forward")
            }
            .font(.title3.weight(.semibold))
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
            loadErrorMessage = "Clipboard is empty or doesn't contain text."
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
        loadErrorMessage = "Could not parse clipboard content as FBN, FMN, or FMNe notation.\n\nClipboard content: \(trimmed.prefix(100))..."
        showLoadError = true
    }
}
