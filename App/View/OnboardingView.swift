import Observation
import SwiftUI

struct OnboardingView: View {
    @Bindable var viewModel: OnboardingViewModel
    let onComplete: (Persona) -> Void

    @State private var isShowingPersonaPicker = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                Text("ROAST\nMY\nHABITS")
                    .font(DesignTokens.Typography.hero)
                    .foregroundStyle(DesignTokens.Colors.foreground)
                    .lineLimit(3)

                Text("Add one to five habits. Then choose the voice that will judge you.")
                    .font(DesignTokens.Typography.body)
                    .foregroundStyle(DesignTokens.Colors.foreground)

                BrutalistCard {
                    TextField("Habit name", text: $viewModel.draftName)
                        .textInputAutocapitalization(.words)
                    TextField("Daily goal", text: $viewModel.draftGoal)
                        .keyboardType(.numberPad)
                    TextField("Unit", text: $viewModel.draftUnit)
                        .textInputAutocapitalization(.never)
                }
                .font(DesignTokens.Typography.body)
                .foregroundStyle(DesignTokens.Colors.foreground)

                BrutalistButton(
                    title: "ADD HABIT",
                    color: DesignTokens.Colors.accentSecondary,
                    isDisabled: viewModel.canAddHabit == false || viewModel.isSaving
                ) {
                    Task {
                        await viewModel.addHabit()
                    }
                }

                VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                    ForEach(viewModel.createdHabits) { habit in
                        BrutalistCard {
                            Text(habit.name.uppercased())
                                .font(DesignTokens.Typography.title)
                                .foregroundStyle(DesignTokens.Colors.foreground)
                            Text("\(habit.goal) \(habit.unit) / day")
                                .font(DesignTokens.Typography.body)
                                .foregroundStyle(DesignTokens.Colors.foreground)
                        }
                    }
                }

                if let error = viewModel.error {
                    Text(error)
                        .font(DesignTokens.Typography.caption)
                        .foregroundStyle(DesignTokens.Colors.accentSecondary)
                }

                BrutalistButton(
                    title: "PICK PERSONA",
                    color: DesignTokens.Colors.accentPrimary,
                    isDisabled: viewModel.canComplete == false
                ) {
                    isShowingPersonaPicker = true
                }
            }
            .padding(DesignTokens.Spacing.lg)
        }
        .background(DesignTokens.Colors.background.ignoresSafeArea())
        .task {
            await viewModel.load()
        }
        .sheet(isPresented: $isShowingPersonaPicker) {
            PersonaPickerView(
                selectedPersona: $viewModel.selectedPersona,
                title: "PICK YOUR ABUSER",
                dismissTitle: "START"
            ) {
                isShowingPersonaPicker = false
                onComplete(viewModel.selectedPersona)
            }
            .presentationDetents([.medium, .large])
        }
    }
}
