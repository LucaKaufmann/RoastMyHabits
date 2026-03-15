import Testing

@testable import RoastMyHabits

@Suite("RoastQualityEvals")
struct RoastQualityEvalTests {
    @Test("all personas mention the supplied habit name")
    func outputMentionsHabits() async throws {
        let generator = RoastGenerator()
        let snapshot = HabitSnapshot(name: "Sleep", currentValue: 4, goal: 8, unit: "hours")

        for persona in Persona.allCases {
            let roast = try await generator.generate(persona: persona, habitData: [snapshot])
            #expect(roast.contains("Sleep"))
            #expect(roast.isEmpty == false)
        }
    }
}
