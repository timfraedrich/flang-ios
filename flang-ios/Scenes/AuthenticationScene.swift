import FlangOnline
import SwiftUI

struct AuthenticationScene: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(SessionManager.self) private var sessionManager
    @State private var isLogin = true
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private var isFormValid: Bool {
        !username.isEmpty &&
        !password.isEmpty &&
        username.count >= 5 &&
        username.count <= 15 &&
        (isLogin || password == confirmPassword)
    }

    private func handleSubmit() {
        errorMessage = nil
        isLoading = true
        Task {
            do {
                if isLogin {
                    try await sessionManager.login(username: username, password: password)
                } else {
                    let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_-"))
                    if username.rangeOfCharacter(from: allowedCharacters.inverted) != nil {
                        throw AuthError.invalidUsername
                    }
                    try await sessionManager.register(username: username, password: password)
                    try await sessionManager.login(username: username, password: password)
                }

                await MainActor.run {
                    isLoading = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    init() {}

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    header
                    inputs
                }
                .padding(.top, 40)
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom, content: bottomSafeAreaInset)
            .ignoresSafeArea(.container, edges: .bottom)
            .toolbar(content: toolbarContent)
        }
    }
    
    @ViewBuilder private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
            Text(isLogin ? "Login" : "Create Account")
                .font(.title.bold())
        }
    }
    
    @ViewBuilder private var inputs: some View {
        VStack(spacing: 16) {
            inputField("Username") {
                TextField("Enter username", text: $username).textContentType(.username)
            }
            inputField("Password") {
                SecureField("Enter password", text: $password).textContentType(.password)
            }
            if !isLogin {
                inputField("Username") {
                    SecureField("Confirm password", text: $confirmPassword).textContentType(.password)
                }
            }
        }
        .backgroundStyle(.background.secondary)
        .padding(.horizontal, 24)
    }
    
    @ViewBuilder
    private func inputField<V: View>(_ title: LocalizedStringKey, @ViewBuilder inputContent: () -> V) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            inputContent()
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textFieldStyle(.plain)
                .padding(16)
                .background()
                .clipShape(.capsule)
        }
    }
    
    @ViewBuilder
    private func bottomSafeAreaInset() -> some View {
        VStack(spacing: 16) {
            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.horizontal)
            }
            Button(action: handleSubmit) {
                Group {
                    if isLoading {
                        ProgressView().progressViewStyle(.circular).controlSize(.regular)
                    } else {
                        Text(isLogin ? "Login" : "Register").font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .controlSize(.large)
            .disabled(!isFormValid || isLoading)
            
            Button(action: { isLogin.toggle() }) {
                Text(isLogin ? "Don't have an account? Register" : "Already have an account? Login")
                    .font(.subheadline)
            }
        }
        .padding(.init(top: 48, leading: 24, bottom: 32, trailing: 24))
        .background { BackgroundBlackoutGradient(startPoint: .top, endPoint: .center) }
    }
    
    @ToolbarContentBuilder
    private func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel", action: dismiss.callAsFunction)
        }
    }

    enum AuthError: Error, LocalizedError {
        case invalidUsername
        case passwordMismatch

        var errorDescription: String? {
            switch self {
            case .invalidUsername:
                return "Username must be 5-15 alphanumeric characters, underscores, or hyphens"
            case .passwordMismatch:
                return "Passwords do not match"
            }
        }
    }
}
