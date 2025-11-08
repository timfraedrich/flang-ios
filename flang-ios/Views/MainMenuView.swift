import SwiftUI

struct MainMenuView: View {

    @State private var showLoadError = false
    @State private var loadErrorMessage = ""
    @State private var navigateToGame = false
    @State private var gameToLoad: Game?

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                // Title
                VStack(spacing: 8) {
                    Text("Flang")
                        .font(.system(size: 60, weight: .bold))
                    Text("Chess Reimagined")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 60)

                Spacer()

                // Menu Buttons
                VStack(spacing: 20) {
                    MenuButton(
                        title: "New Game",
                        icon: "plus.circle.fill",
                        color: .blue
                    ) {
                        gameToLoad = Game()
                        navigateToGame = true
                    }

                    MenuButton(
                        title: "Load from Clipboard",
                        icon: "doc.on.clipboard.fill",
                        color: .green
                    ) {
                        loadFromClipboard()
                    }
                }
                .padding(.horizontal, 40)

                Spacer()

                // Info text
                Text("Copy a game (FMN/FMNe) or board (FBN) to clipboard to load it")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
            }
            .navigationDestination(isPresented: $navigateToGame) {
                if let game = gameToLoad {
                    GameView(gameState: GameState(game: game))
                }
            }
            .alert("Load Error", isPresented: $showLoadError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(loadErrorMessage)
            }
        }
    }

    private func loadFromClipboard() {
        guard let clipboardString = UIPasteboard.general.string else {
            loadErrorMessage = "Clipboard is empty or doesn't contain text."
            showLoadError = true
            return
        }

        let trimmed = clipboardString.trimmingCharacters(in: .whitespacesAndNewlines)

        // Try to parse as FMNe (starts with !)
        if trimmed.starts(with: "!") {
            if let game = Game(fromFMNe: trimmed) {
                gameToLoad = game
                navigateToGame = true
                return
            }
        }

        // Try to parse as FBN (starts with + or -)
        if trimmed.starts(with: "+") || trimmed.starts(with: "-") {
            if let game = Game(fromFBN: trimmed) {
                gameToLoad = game
                navigateToGame = true
                return
            }
        }

        // Try to parse as FMN (space-separated moves)
        if let game = Game(fromFMN: trimmed) {
            gameToLoad = game
            navigateToGame = true
            return
        }

        // If all parsing attempts failed
        loadErrorMessage = "Could not parse clipboard content as FBN, FMN, or FMNe notation.\n\nClipboard content: \(trimmed.prefix(100))..."
        showLoadError = true
    }
}

// MARK: - Menu Button

struct MenuButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .frame(width: 30)

                Text(title)
                    .font(.title3.weight(.semibold))

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(color.opacity(0.1))
            .foregroundStyle(color)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

#Preview {
    MainMenuView()
}
