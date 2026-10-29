import SwiftUI
import SwiftData

struct WelcomeView: View {
    @State private var isShowingApp = false
    @State private var isShowingSignUp = false
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var didAttemptSubmit = false
    @State private var isShowingGuestNotice = false

    private var isEmailValid: Bool {
        email.range(of: #"^\S+@\S+\.\S+$"#, options: .regularExpression) != nil
    }
    private var isPasswordValid: Bool { password.count >= 6 }
    private var canSubmit: Bool { isEmailValid && isPasswordValid }

    var body: some View {
        ZStack {
            backdrop

            ScrollView {
                VStack(spacing: 22) {
                    Spacer(minLength: 40)

                    Image("PodiumLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150)

                    Text("More than tournaments. A global chess community.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    Spacer(minLength: 16)

                    VStack(spacing: 12) {
                        socialButton(label: "Continue with Apple") {
                            Image(systemName: "apple.logo")
                        }
                        socialButton(label: "Continue with Google") {
                            Image("GoogleLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 18, height: 18)
                        }
                    }

                    HStack {
                        Rectangle().fill(.white.opacity(0.15)).frame(height: 1)
                        Text("or").font(.caption).foregroundStyle(.white.opacity(0.5))
                        Rectangle().fill(.white.opacity(0.15)).frame(height: 1)
                    }

                    VStack(spacing: 12) {
                        pillField(placeholder: "Email", text: $email, isValid: isEmailValid, keyboard: .emailAddress)
                        passwordPillField()
                    }

                    Button {
                        didAttemptSubmit = true
                        if canSubmit { isShowingGuestNotice = true }
                    } label: {
                        Text("Log In")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .foregroundStyle(.white)
                    .background(Color.podiumCopper)
                    .clipShape(Capsule())

                    Button {
                        isShowingApp = true
                    } label: {
                        Text("Skip")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.6))
                    }

                    HStack(spacing: 4) {
                        Text("Don't have an account?")
                            .foregroundStyle(.white.opacity(0.6))
                        Button("Sign Up") { isShowingSignUp = true }
                            .foregroundStyle(Color.podiumCopper)
                            .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                    .padding(.bottom, 24)
                }
                .padding(.horizontal, 28)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .fullScreenCover(isPresented: $isShowingApp) {
            MainTabView()
        }
        .sheet(isPresented: $isShowingSignUp) {
            LoginView(onContinue: { isShowingApp = true }, initialMode: .createAccount)
        }
        .alert("Accounts Coming Soon", isPresented: $isShowingGuestNotice) {
            Button("Continue as Guest") { isShowingApp = true }
        } message: {
            Text("Podium Results doesn't have real accounts yet — your info checks out, but there's nothing to authenticate against. You can keep using the app as a guest for now.")
        }
    }

    private func socialButton(label: String, @ViewBuilder icon: () -> some View) -> some View {
        Button {
            isShowingGuestNotice = true
        } label: {
            HStack {
                icon()
                Text(label)
                    .font(.subheadline.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
        }
        .foregroundStyle(Color.podiumEspresso)
        .background(.white)
        .clipShape(Capsule())
    }

    private func pillField(placeholder: String, text: Binding<String>, isValid: Bool, keyboard: UIKeyboardType) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField(placeholder, text: text)
                .foregroundStyle(.white)
                .tint(.white)
                .keyboardType(keyboard)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .padding(.vertical, 13)
                .padding(.horizontal, 16)
                .background(.white.opacity(0.12))
                .clipShape(Capsule())
            if didAttemptSubmit && !isValid {
                Text("Enter a valid email address.")
                    .font(.caption2)
                    .foregroundStyle(Color(hex: 0xE8907A))
                    .padding(.leading, 16)
            }
        }
    }

    private func passwordPillField() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Group {
                    if isPasswordVisible {
                        TextField("Password", text: $password)
                    } else {
                        SecureField("Password", text: $password)
                    }
                }
                .foregroundStyle(.white)
                .tint(.white)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

                Button {
                    isPasswordVisible.toggle()
                } label: {
                    Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .padding(.vertical, 13)
            .padding(.horizontal, 16)
            .background(.white.opacity(0.12))
            .clipShape(Capsule())
            if didAttemptSubmit && !isPasswordValid {
                Text("Password must be at least 6 characters.")
                    .font(.caption2)
                    .foregroundStyle(Color(hex: 0xE8907A))
                    .padding(.leading, 16)
            }
        }
    }

    private var backdrop: some View {
        ZStack {
            Image("ChessBackdrop")
                .resizable()
                .scaledToFill()

            LinearGradient(
                colors: [
                    Color.podiumCharcoal.opacity(0.65),
                    Color.podiumCharcoal.opacity(0.3),
                    Color.podiumCharcoal.opacity(0.55),
                    Color.podiumCharcoal.opacity(0.95),
                ],
                startPoint: .top, endPoint: .bottom
            )
        }
        .ignoresSafeArea()
    }
}

#Preview {
    WelcomeView()
        .modelContainer(for: [Tournament.self, Player.self, Match.self], inMemory: true)
}

