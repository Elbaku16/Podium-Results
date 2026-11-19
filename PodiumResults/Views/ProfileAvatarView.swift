import SwiftUI
import PhotosUI

struct ProfileAvatarView: View {
    let photo: ProfilePhotoViewModel
    let name: String?

    @State private var isPickingPhoto = false
    @State private var pickedItem: PhotosPickerItem?

    private var initials: String? {
        guard let name else { return nil }
        let letters = name.split(separator: " ").prefix(2).compactMap { $0.first }
        let text = String(letters).uppercased()
        return text.isEmpty ? nil : text
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            avatar
                .frame(width: 112, height: 112)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.podiumCopper, lineWidth: 3))

            Menu {
                Button("Choose Photo", systemImage: "photo") { isPickingPhoto = true }
                if photo.image != nil {
                    Button("Remove Photo", systemImage: "trash", role: .destructive) { photo.removePhoto() }
                }
            } label: {
                Image(systemName: "camera.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(Color.podiumCopper)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.podiumCharcoal, lineWidth: 2))
            }
        }
        .photosPicker(isPresented: $isPickingPhoto, selection: $pickedItem, matching: .images)
        .onChange(of: pickedItem) { _, item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    photo.setPhoto(data)
                }
                pickedItem = nil
            }
        }
    }

    @ViewBuilder
    private var avatar: some View {
        if let image = photo.image {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            ZStack {
                Color.white.opacity(0.06)
                if let initials {
                    Text(initials)
                        .font(.system(size: 40, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.podiumBeige)
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 42))
                        .foregroundStyle(Color.podiumBeige.opacity(0.8))
                }
            }
        }
    }
}
