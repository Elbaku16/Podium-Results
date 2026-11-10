import SwiftUI

struct LoginView: View {
    @Environment(AuthViewModel.self) private var auth
    let onContinue: () -> Void
    var initialMode: Mode = .signIn

    @Environment(\.dismiss) private var dismiss
    @State private var mode: Mode = .signIn
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isPasswordVisible = false
    @State private var didAttemptSubmit = false
    @State private var errorText: String?

    enum Mode: String, CaseIterable { case signIn = "Sign In", createAccount = "Create Account" }

    private var isEmailValid: Bool {
        email.range(of: #"^\S+@\S+\.\S+$"#, options: .regularExpression) != nil
    }
    private var isPasswordValid: Bool { password.count >= 6 }
    private var isNameValid: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }
    private var doPasswordsMatch: Bool { password == confirmPassword }

    private var canSubmit: Bool {
        switch mode {
        case .signIn:
            return isEmailValid && isPasswordValid
        case .createAccount:
            return isNameValid && isEmailValid && isPasswordValid && doPasswordsMatch
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.podiumCharcoal.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .stroke(Color.podiumCopper, lineWidth: 1.5)
                                .frame(width: 64, height: 64)
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 26))
                                .foregroundStyle(Color.podiumCopper)
                        }
                        .padding(.top, 12)

                        Picker("Mode", selection: $mode.animation()) {
                            ForEach(Mode.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                        }
                        .pickerStyle(.segmented)
                        .environment(\.colorScheme, .dark)

                        VStack(spacing: 14) {
                            if mode == .createAccount {
                                field(label: "Name", text: $name, isValid: isNameValid, errorMessage: "Enter your name.")
                            }

                            field(label: "Email", text: $email, isValid: isEmailValid,
                                  errorMessage: "Enter a valid email address.", keyboard: .emailAddress)

                            passwordField(label: "Password", text: $password, isValid: isPasswordValid,
                                          errorMessage: "Password must be at least 6 characters.")

                            if mode == .createAccount {
                                passwordField(label: "Confirm Password", text: $confirmPassword, isValid: doPasswordsMatch,
                                              errorMessage: "Passwords don't match.")
                            }
                        }
                        .cardBackground(Color.white.opacity(0.06))

                        Button {
                            didAttemptSubmit = true
                            guard canSubmit else { return }
                            Task {
                                let succeeded: Bool
                                switch mode {
                                case .signIn:
                                    succeeded = await auth.signIn(email: email, password: password)
                                case .createAccount:
                                    succeeded = await auth.signUp(name: name.trimmingCharacters(in: .whitespaces),
                                                                  email: email, password: password)
                                }
                                if succeeded {
                                    dismiss()
                                    onContinue()
                                } else {
                                    errorText = auth.errorMessage
                                }
                            }
                        } label: {
                            Text(auth.isLoading ? "Please wait..." : (mode == .signIn ? "Sign In" : "Create Account"))
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PillButtonStyle())
                        .disabled(auth.isLoading)

                        if mode == .signIn {
                            Button("Forgot your password?") {}
                                .font(.subheadline)
                                .foregroundStyle(Color.podiumCopper)
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle(mode == .signIn ? "Sign In" : "Create Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.podiumCharcoal, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Couldn't continue", isPresented: Binding(get: { errorText != nil }, set: { if !$0 { errorText = nil } })) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorText ?? "")
            }
        }
        .tint(.podiumCopper)
        .onAppear { mode = initialMode }
    }

    private func field(label: String, text: Binding<String>, isValid: Bool, errorMessage: String,
                        keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.podiumMuted)
            TextField(label, text: text, prompt: Text(label).foregroundStyle(Color.podiumMuted))
                .textFieldStyle(.plain)
                .foregroundStyle(.white)
                .keyboardType(keyboard)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            if didAttemptSubmit && !isValid {
                Text(errorMessage)
                    .font(.caption2)
                    .foregroundStyle(.red)
            }
            Divider().overlay(.white.opacity(0.07))
        }
    }

    private func passwordField(label: String, text: Binding<String>, isValid: Bool, errorMessage: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.podiumMuted)
            HStack {
                Group {
                    if isPasswordVisible {
                        TextField(label, text: text, prompt: Text(label).foregroundStyle(Color.podiumMuted))
                    } else {
                        SecureField(label, text: text, prompt: Text(label).foregroundStyle(Color.podiumMuted))
                    }
                }
                .foregroundStyle(.white)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

                Button {
                    isPasswordVisible.toggle()
                } label: {
                    Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                        .foregroundStyle(Color.podiumMuted)
                }
            }
            if didAttemptSubmit && !isValid {
                Text(errorMessage)
                    .font(.caption2)
                    .foregroundStyle(.red)
            }
            Divider().overlay(.white.opacity(0.07))
        }
    }
}

#Preview {
    LoginView(onContinue: {})
        .environment(AuthViewModel())
}

