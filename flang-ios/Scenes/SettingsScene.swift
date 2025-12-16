import FlangOnline
import MarkdownUI
import SwiftUI

struct SettingsScene: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(Router.self) private var router
    @Environment(SessionManager.self) private var sessionManager
    @State private var confirmLogOut = false
    
    private var version: String {
        let marketingVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "nil"
        let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "nil"
        return "\(marketingVersion) (\(buildVersion))"
    }
    
    var body: some View {
        List {
            Section {
                Button {
                    switch sessionManager.status {
                    case .loggedIn(let username, _):
                        router.sheets.removeAll()
                        router.path.append(NavigationDestination.playerProfile(username: username))
                    case .loggedOut:
                        router.sheets.append(.authentication)
                    case .tryingToRestoreSession:
                        break
                    }
                } label: {
                    HStack(spacing: 10) {
                        Group {
                            switch sessionManager.status {
                            case .loggedIn:
                                Image(systemName: "person.circle.fill")
                            case .loggedOut:
                                Image(systemName: "person.circle")
                            case .tryingToRestoreSession:
                                ProgressView()
                            }
                        }
                        .font(.system(size: 48))
                        .controlSize(.extraLarge)
                        
                        VStack(alignment: .leading) {
                            if sessionManager.username != nil {
                                Text("settings_logged_in_as").font(.footnote).opacity(0.6)
                            }
                            Text(sessionManager.username ?? .init(localized: "register"))
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .tint(.primary)
            }
            Section {
                Button("settings_show_tutorial") {
                    router.sheets.append(.tutorial)
                }
            }
            Section {
                markdownLink("privacy_policy", file: "PRIVACY")
                markdownLink("settings_copyright_notice", file: "NOTICE")
                markdownLink("settings_license", file: "LICENSE")
                Button {
                    guard let url = URL(string: "https://github.com/timfraedrich/flang-ios") else { return }
                    openURL.callAsFunction(url)
                } label: {
                    NavigationLink("settings_source_code", destination: EmptyView.init)
                }
                .foregroundStyle(.primary)
                LabeledContent("settings_version", value: version)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("settings")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(role: .cancel, action: dismiss.callAsFunction)
            }
            if sessionManager.username != nil {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("logout", role: .destructive) {
                        confirmLogOut = true
                    }
                    .confirmationDialog("logout", isPresented: $confirmLogOut) {
                        Button("logout", role: .destructive) {
                            try? sessionManager.logout()
                        }
                    } message: {
                        Text("confirm_logout_message")
                    }
                    .tint(.red)
                }
            }
        }
    }
    
    @ViewBuilder
    private func markdownLink(_ title: LocalizedStringKey, file: String) -> some View {
        NavigationLink(title) {
            MarkdownFileView(file: file).navigationTitle(title)
        }
    }
}
