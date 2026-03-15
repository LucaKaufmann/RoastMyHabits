import SwiftUI

struct BrutalistCard<Content: View>: View {
    @ViewBuilder private let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            content()
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(
            Rectangle()
                .stroke(DesignTokens.Colors.foreground, lineWidth: DesignTokens.Border.regular)
        )
    }
}
