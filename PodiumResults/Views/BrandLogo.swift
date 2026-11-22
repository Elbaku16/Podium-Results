import SwiftUI

struct BrandLogo: View {
    var width: CGFloat = 160

    var body: some View {
        Image("BrandLogoFull")
            .resizable()
            .scaledToFit()
            .frame(width: width * 1.1)
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
