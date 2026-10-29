import SwiftUI

struct PlayerAvatar: View {
    let name: String
    var size: CGFloat = 32

    private var initials: String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        let result = String(letters).uppercased()
        return result.isEmpty ? "?" : result
    }

    private var color: Color {
        let hash = name.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return Color.avatarPalette[hash % Color.avatarPalette.count]
    }

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .overlay(
                Text(initials)
                    .font(.system(size: size * 0.4, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            )
            .overlay(Circle().stroke(.white.opacity(0.85), lineWidth: max(1.5, size * 0.05)))
    }
}

extension Color {
    static let avatarPalette: [Color] = [
        Color(hex: 0xC9A646),
        Color(hex: 0xB0523F),
        Color(hex: 0x3F6B84),
        Color(hex: 0x6B4E71),
        Color(hex: 0x3F7A6B),
        Color(hex: 0x8A6D3F),
    ]
}

