import Foundation
import Observation

@MainActor
@Observable
final class OnboardingViewModel {
    private let habitRepository: HabitRepository

    var draftName = ""
    var draftGoal = ""
    var draftUnit = ""
    var createdHabits: [Habit] = []
    var selectedPersona: Persona = .disappointedParent
    var error: String?
    var isSaving = false

    init(habitRepository: HabitRepository) {
        self.habitRepository = habitRepository
    }

    var canAddHabit: Bool {
        draftName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false &&
        normalizedGoal != nil &&
        draftUnit.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false &&
        createdHabits.count < AppConfiguration.maxHabits
    }

    var canComplete: Bool {
        createdHabits.isEmpty == false
    }

    func load() async {
        do {
            createdHabits = try await habitRepository.fetchAll()
        } catch {
            error = error.localizedDescription
        }
    }

    func addHabit() async {
        guard let normalizedGoal else {
            error = "Goals need a real integer greater than zero."
            return
        }

        let nextSortOrder = (createdHabits.map(\.sortOrder).max() ?? -1) + 1
        let habit = Habit(
            name: draftName.trimmingCharacters(in: .whitespacesAndNewlines),
            goal: normalizedGoal,
            unit: draftUnit.trimmingCharacters(in: .whitespacesAndNewlines),
            sortOrder: nextSortOrder
        )

        isSaving = true
        defer { isSaving = false }

        do {
            try await habitRepository.insert(habit)
            createdHabits = try await habitRepository.fetchAll()
            draftName = ""
            draftGoal = ""
            draftUnit = ""
            error = nil
        } catch {
            self.error = error.localizedDescription
        }
    }

    private var normalizedGoal: Int? {
        guard let goal = Int(draftGoal), goal >= AppConfiguration.minimumHabitGoal else {
            return nil
        }

        return goal
    }
}
