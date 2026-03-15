import Observation
import SwiftUI

struct RoastView: View {
    @Bindable var viewModel: RoastViewModel

    var body: some View {
        ZStack {
            DesignTokens.Colors.background.opacity(0.96)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                Text(viewModel.activePersona.displayName.uppercased())
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(DesignTokens.Colors.accentPrimary)

                if viewModel.isGenerating {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 56, weight: .black))
                            .foregroundStyle(DesignTokens.Colors.accentPrimary)
                            .symbolEffect(.pulse)
                        Text("COOKING UP SOMETHING MEAN...")
                            .font(DesignTokens.Typography.section)
                            .foregroundStyle(DesignTokens.Colors.foreground)
                    }
                } else {
                    Text(viewModel.roastText)
                        .font(DesignTokens.Typography.section)
                        .foregroundStyle(DesignTokens.Colors.foreground)

                    if let error = viewModel.error {
                        Text(error)
                            .font(DesignTokens.Typography.caption)
                            .foregroundStyle(DesignTokens.Colors.accentSecondary)
                    }

                    Text("TAP ANYWHERE TO DISMISS")
                        .font(DesignTokens.Typography.caption)
                        .foregroundStyle(DesignTokens.Colors.accentPrimary)
                }
            }
            .padding(DesignTokens.Spacing.xl)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            guard viewModel.isGenerating == false else {
                return
            }

            viewModel.dismiss()
        }
    }
}
