import SwiftUI

struct BrutalistButton: View {
    let title: String
    let color: Color
    let isDisabled: Bool
    let action: () -> Void

    init(
        title: String,
        color: Color,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.color = color
        self.isDisabled = isDisabled
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DesignTokens.Typography.title)
                .foregroundStyle(DesignTokens.Colors.background)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignTokens.Spacing.md)
                .background(isDisabled ? DesignTokens.Colors.muted : color)
                .overlay(
                    Rectangle()
                        .stroke(DesignTokens.Colors.foreground, lineWidth: DesignTokens.Border.heavy)
                )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}
