import SwiftUI

struct BootstrapFailureView: View {
    var body: some View {
        ZStack {
            DesignTokens.Colors.background
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                Text("BOOT FAILED")
                    .font(DesignTokens.Typography.section)
                    .foregroundStyle(DesignTokens.Colors.accentSecondary)
                Text("SwiftData could not start. Check the logs, then try again.")
                    .font(DesignTokens.Typography.body)
                    .foregroundStyle(DesignTokens.Colors.foreground)
            }
            .padding(DesignTokens.Spacing.lg)
        }
    }
}
