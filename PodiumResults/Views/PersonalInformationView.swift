import SwiftUI
import SwiftData

struct PersonalInformationView: View {
    let onAccountClosed: () -> Void

    @Environment(AuthViewModel.self) private var auth
    @Query private var tournaments: [Tournament]
    @State private var name = ""
    @State private var message: String?
    @State private var isConfirmingDelete = false
    @State private var isWorking = false
    @State private var publishViewModel = PublishViewModel()

    private var trimmedName: String { name.trimmingCharacters(in: .whitespaces) }

    var body: some View {
        SettingsScreen(title: "Personal Information") {
            if let user = auth.user {
                accountGroup(user)
                if trimmedName != user.name && !trimmedName.isEmpty {
                    saveButton
                }
                if let message {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(Color.podiumCopper)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                deleteGroup
            } else {
                SettingsGroup(footer: "Log in to see and change your account information.") {
                    SettingsValueRow(icon: "person.fill", title: "Session", value: "Guest")
                }
            }
        }
        .onAppear { name = auth.user?.name ?? "" }
        .confirmationDialog("Delete your account?", isPresented: $isConfirmingDelete, titleVisibility: .visible) {
            Button("Delete Account", role: .destructive) { deleteAccount() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your account and the online copies of your tournaments will be deleted. Tournaments saved on this phone stay. This can't be undone.")
        }
    }

    private func accountGroup(_ user: AuthUser) -> some View {
        SettingsGroup(title: "Account") {
            HStack(spacing: 12) {
                SettingsIcon(name: "person.fill")
                TextField("Name", text: $name, prompt: Text("Name").foregroundStyle(Color.podiumMuted))
                    .font(.body)
                    .foregroundStyle(.white)
                    .textInputAutocapitalization(.words)
            }
            .padding(.vertical, 12)
            SettingsDivider()
            SettingsValueRow(icon: "envelope.fill", title: "Email", value: user.email)
            if let createdAt = user.createdAt {
                SettingsDivider()
                SettingsValueRow(icon: "calendar", title: "Member since",
                                 value: createdAt.formatted(date: .abbreviated, time: .omitted))
            }
        }
    }

    private var saveButton: some View {
        Button {
            Task {
                let saved = await auth.updateName(trimmedName)
                message = saved ? "Name updated." : auth.errorMessage
            }
        } label: {
            Text(auth.isLoading ? "Saving..." : "Save Name")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color.podiumCharcoal)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(Color.podiumCopper)
                .clipShape(Capsule())
        }
        .disabled(auth.isLoading)
    }

    private var deleteGroup: some View {
        SettingsGroup(footer: "Deleting your account removes your login and the tournaments you published online.") {
            Button(role: .destructive) {
                isConfirmingDelete = true
            } label: {
                HStack(spacing: 12) {
                    SettingsIcon(name: "person.crop.circle.badge.xmark", tint: Color(hex: 0xE8907A))
                    Text(isWorking ? "Deleting..." : "Delete Account")
                        .font(.body)
                        .foregroundStyle(Color(hex: 0xE8907A))
                    Spacer()
                }
                .padding(.vertical, 12)
            }
            .disabled(isWorking)
        }
    }

    private func deleteAccount() {
        guard let user = auth.user else { return }
        isWorking = true
        message = nil
        Task {
            for tournament in tournaments where tournament.publishedAt != nil {
                await publishViewModel.unpublish(tournament)
            }
            if await auth.deleteAccount() {
                ProfilePhotoStore().remove(for: user.uid)
                onAccountClosed()
            } else {
                message = auth.errorMessage
            }
            isWorking = false
        }
    }
}
