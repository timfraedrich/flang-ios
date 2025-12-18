import FlangOnline
import SwiftUI

struct DeleteAccountScene: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(SessionManager.self) private var sessionManager
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showConfirmation = false

    private var isFormValid: Bool { !password.isEmpty }

    private func delete() {
        errorMessage = nil
        isLoading = true
        Task {
            do {
                try await sessionManager.deleteAccount(password: password)
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

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                header
                warningSection
                inputs
            }
            .padding(.top, 40)
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("delete_account")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom, content: bottomSafeAreaInset)
        .ignoresSafeArea(.container, edges: .bottom)
        .tint(.red)
    }

    @ViewBuilder private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.tint)
            Text("delete_account")
                .font(.title.bold())
        }
    }

    @ViewBuilder private var warningSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("warning")
                .font(.headline.weight(.bold))
                .foregroundStyle(.tint)
            Text("delete_account_warning")
            Text("delete_account_consequences")
        }
        .font(.callout)
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.tint.opacity(0.1))
        .clipShape(.rect(cornerRadius: 16))
        .overlay { RoundedRectangle(cornerRadius: 16).strokeBorder(.tint.opacity(0.3), lineWidth: 1) }
        .padding(.horizontal, 24)
    }

    @ViewBuilder private var inputs: some View {
        VStack(spacing: 16) {
            FormInputField("input_password") {
                SecureField("input_enter_password", text: $password).textContentType(.password)
            }
        }
        .backgroundStyle(.background.secondary)
        .padding(.horizontal, 24)
    }

    @ViewBuilder
    private func bottomSafeAreaInset() -> some View {
        VStack(spacing: 16) {
            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.tint)
                    .padding(.horizontal)
            }
            Button(action: delete) {
                Group {
                    if isLoading {
                        ProgressView().progressViewStyle(.circular).controlSize(.regular)
                    } else {
                        Text("delete_account_button").font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .controlSize(.large)
            .disabled(!isFormValid || isLoading)
        }
        .padding(.init(top: 48, leading: 24, bottom: 32, trailing: 24))
        .background { BackgroundBlackoutGradient(startPoint: .top, endPoint: .center) }
    }
}
