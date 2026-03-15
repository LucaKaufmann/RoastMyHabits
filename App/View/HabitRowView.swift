import SwiftUI

struct HabitRowView: View {
    let item: HabitListViewModel.HabitProgress
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    private var progressColor: Color {
        item.currentValue >= item.goal ? DesignTokens.Colors.accentPrimary : DesignTokens.Colors.accentSecondary
    }

    var body: some View {
        BrutalistCard {
            Text(item.habit.name.uppercased())
                .font(DesignTokens.Typography.title)
                .foregroundStyle(DesignTokens.Colors.foreground)

            HStack(alignment: .firstTextBaseline) {
                Text("\(item.currentValue)")
                    .font(DesignTokens.Typography.hero)
                    .foregroundStyle(progressColor)
                Text("/ \(item.goal) \(item.habit.unit)")
                    .font(DesignTokens.Typography.body)
                    .foregroundStyle(DesignTokens.Colors.foreground)
            }

            Rectangle()
                .fill(DesignTokens.Colors.muted)
                .frame(height: 16)
                .overlay(alignment: .leading) {
                    GeometryReader { proxy in
                        Rectangle()
                            .fill(progressColor)
                            .frame(width: proxy.size.width * item.progress)
                    }
                }

            HStack(spacing: DesignTokens.Spacing.md) {
                BrutalistButton(title: "-", color: DesignTokens.Colors.accentSecondary, action: onDecrement)
                BrutalistButton(title: "+", color: DesignTokens.Colors.accentPrimary, action: onIncrement)
            }
        }
    }
}
