import SwiftUI

struct BrandLogo: View {
    var width: CGFloat = 160

    private let gold = Color(red: 233 / 255, green: 194 / 255, blue: 129 / 255)
    private let copper = Color(red: 201 / 255, green: 130 / 255, blue: 91 / 255)

    var body: some View {
        VStack(spacing: 6) {
            Image("BrandMark")
                .resizable()
                .scaledToFit()
                .frame(width: width * 0.62)

            VStack(spacing: -4) {
                Text(AppInfo.firstWord)
                    .foregroundStyle(gold)
                Text(AppInfo.secondWord)
                    .foregroundStyle(copper)
            }
            .font(.system(size: width * 0.24, weight: .bold, design: .rounded))
            .lineLimit(1)
            .minimumScaleFactor(0.6)
        }
        .frame(width: width)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(AppInfo.name)
    }
}

#Preview {
    BrandLogo()
        .padding()
        .background(Color.podiumCharcoal)
}
