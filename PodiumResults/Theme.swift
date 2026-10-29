import SwiftUI

extension Color {
    init(hex: UInt32) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }

    static let boardGreen = Color(hex: 0x1F4D2B)
    static let boardGreenLight = Color(hex: 0xE3EEE2)
    static let boardCream = Color(hex: 0xF7F4EC)
    static let boardCard = Color(hex: 0xFFFFFF)
    static let boardInk = Color(hex: 0x1C1C1A)
    static let boardGold = Color(hex: 0xC9A646)
    static let boardSilver = Color(hex: 0x9AA5AD)
    static let boardBronze = Color(hex: 0xB07A4B)

    static let boardDark = Color(hex: 0x0E1812)
    static let boardDarkCard = Color(hex: 0x1A2A21)

    static let podiumEspresso = Color(hex: 0x2B1D19)
    static let podiumCharcoal = Color(hex: 0x211B19)
    static let podiumCream = Color(hex: 0xF3E8DA)
    static let podiumBeige = Color(hex: 0xD7C2AC)
    static let podiumCopper = Color(hex: 0xC9825B)
    static let podiumMuted = Color(hex: 0xA8A09A)
}

extension Double {
    var scoreText: String {
        self == 0.5 ? "½" : formatted()
    }
}

struct CardBackground: ViewModifier {
    var fill: Color = .white
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(fill)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: Color.podiumEspresso.opacity(0.08), radius: 6, y: 3)
    }
}

extension View {
    func cardBackground(_ fill: Color = .white) -> some View {
        modifier(CardBackground(fill: fill))
    }
}

struct PillButtonStyle: ButtonStyle {
    var isProminent: Bool = true
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding(.vertical, 14)
            .padding(.horizontal, 24)
            .frame(maxWidth: isProminent ? .infinity : nil)
            .background(isProminent ? Color.podiumCopper : Color.podiumBeige.opacity(0.4))
            .foregroundStyle(isProminent ? .white : .podiumCopper)
            .clipShape(Capsule())
            .opacity(configuration.isPressed ? 0.85 : 1)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}

