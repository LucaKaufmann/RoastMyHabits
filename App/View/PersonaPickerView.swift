import SwiftUI

struct PersonaPickerView: View {
    @Binding var selectedPersona: Persona
    let title: String
    let dismissTitle: String
    let onDismiss: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                Text(title)
                    .font(DesignTokens.Typography.section)
                    .foregroundStyle(DesignTokens.Colors.foreground)

                ForEach(Persona.allCases) { persona in
                    Button {
                        selectedPersona = persona
                    } label: {
                        BrutalistCard {
                            Text(persona.displayName)
                                .font(DesignTokens.Typography.title)
                                .foregroundStyle(DesignTokens.Colors.foreground)
                            Text(persona.quote)
                                .font(DesignTokens.Typography.body)
                                .foregroundStyle(DesignTokens.Colors.foreground)
                            Text(selectedPersona == persona ? "SELECTED" : "TAP TO PICK")
                                .font(DesignTokens.Typography.caption)
                                .foregroundStyle(selectedPersona == persona ? DesignTokens.Colors.accentPrimary : DesignTokens.Colors.foreground)
                        }
                    }
                    .buttonStyle(.plain)
                }

                BrutalistButton(title: dismissTitle, color: DesignTokens.Colors.accentPrimary, action: onDismiss)
            }
            .padding(DesignTokens.Spacing.lg)
        }
        .background(DesignTokens.Colors.background.ignoresSafeArea())
    }
}
