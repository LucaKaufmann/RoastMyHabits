import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("selectedPersona") private var selectedPersonaRawValue = Persona.disappointedParent.rawValue

    @State private var onboardingViewModel: OnboardingViewModel
    @State private var habitListViewModel: HabitListViewModel
    @State private var roastViewModel: RoastViewModel

    init(dependencies: AppDependencies) {
        _onboardingViewModel = State(initialValue: OnboardingViewModel(habitRepository: dependencies.habitRepository))
        _habitListViewModel = State(
            initialValue: HabitListViewModel(
                habitRepository: dependencies.habitRepository,
                dailyLogRepository: dependencies.dailyLogRepository,
                hapticService: dependencies.hapticService
            )
        )
        _roastViewModel = State(
            initialValue: RoastViewModel(
                habitRepository: dependencies.habitRepository,
                dailyLogRepository: dependencies.dailyLogRepository,
                roastGenerator: dependencies.roastGenerator,
                hapticService: dependencies.hapticService
            )
        )
    }

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                HabitListView(
                    viewModel: habitListViewModel,
                    roastViewModel: roastViewModel,
                    selectedPersona: selectedPersona
                )
            } else {
                OnboardingView(viewModel: onboardingViewModel) { persona in
                    selectedPersonaRawValue = persona.rawValue
                    hasCompletedOnboarding = true
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var selectedPersona: Binding<Persona> {
        Binding {
            Persona(rawValue: selectedPersonaRawValue) ?? .disappointedParent
        } set: { newValue in
            selectedPersonaRawValue = newValue.rawValue
        }
    }
}
