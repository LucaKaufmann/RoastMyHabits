import Observation
import SwiftUI

struct HabitListView: View {
    @Bindable var viewModel: HabitListViewModel
    @Bindable var roastViewModel: RoastViewModel
    @Binding var selectedPersona: Persona

    @State private var isShowingPersonaPicker = false

    var body: some View {
        ZStack {
            DesignTokens.Colors.background
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                HStack {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                        Text("TODAY'S DAMAGE")
                            .font(DesignTokens.Typography.caption)
                            .foregroundStyle(DesignTokens.Colors.accentPrimary)
                        Text(selectedPersona.displayName)
                            .font(DesignTokens.Typography.section)
                            .foregroundStyle(DesignTokens.Colors.foreground)
                    }

                    Spacer()

                    Button("PERSONA") {
                        isShowingPersonaPicker = true
                    }
                    .font(DesignTokens.Typography.body)
                    .foregroundStyle(DesignTokens.Colors.foreground)
                }

                ScrollView {
                    VStack(spacing: DesignTokens.Spacing.md) {
                        ForEach(viewModel.habits) { habit in
                            HabitRowView(item: habit) {
                                Task {
                                    await viewModel.increment(habit.id)
                                }
                            } onDecrement: {
                                Task {
                                    await viewModel.decrement(habit.id)
                                }
                            }
                        }
                    }
                }

                if let error = viewModel.error {
                    Text(error)
                        .font(DesignTokens.Typography.caption)
                        .foregroundStyle(DesignTokens.Colors.accentSecondary)
                }

                BrutalistButton(title: "JUDGE ME", color: DesignTokens.Colors.accentPrimary) {
                    Task {
                        await roastViewModel.judgeMe(persona: selectedPersona)
                    }
                }
            }
            .padding(DesignTokens.Spacing.lg)

            if roastViewModel.isPresenting {
                RoastView(viewModel: roastViewModel)
                    .transition(.opacity.combined(with: .scale))
                    .zIndex(1)
            }
        }
        .sheet(isPresented: $isShowingPersonaPicker) {
            PersonaPickerView(
                selectedPersona: $selectedPersona,
                title: "SWITCH PERSONA",
                dismissTitle: "DONE"
            ) {
                isShowingPersonaPicker = false
            }
            .presentationDetents([.medium, .large])
        }
        .task {
            await viewModel.load()
        }
        .animation(DesignTokens.Animation.overlay, value: roastViewModel.isPresenting)
    }
}
