import SwiftUI

// MARK: - Components

struct GlassPanel<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 22))
    }
}

struct GlassField<FocusValue: Hashable>: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var focus: FocusState<FocusValue>.Binding
    var focusValue: FocusValue

    private var isFocused: Bool {
        focus.wrappedValue == focusValue
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            TextField(placeholder, text: $text)
                .font(.body.monospaced())
                .foregroundStyle(.primary)
                .textFieldStyle(.plain)
                .padding(.horizontal, 14)
                .padding(.vertical, 13)
                .focused(focus, equals: focusValue)
                #if canImport(UIKit)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                #endif
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.quaternary.opacity(0.45))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(
                            isFocused ? GlassTheme.accent.opacity(0.55) : Color.primary.opacity(0.12),
                            lineWidth: isFocused ? 1.5 : 1
                        )
                }
                .animation(.easeOut(duration: 0.15), value: isFocused)
        }
    }
}

struct GlassToast: View {
    let message: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color(red: 0.3, green: 0.9, blue: 0.55))
            Text(message)
                .font(.subheadline.weight(.medium))
        }
        .foregroundStyle(.primary)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .glassEffect(.regular, in: .capsule)
    }
}

enum GlassTheme {
    static let accent = Color(red: 1.0, green: 0.48, blue: 0.15)
    static let accentGlow = Color(red: 1.0, green: 0.55, blue: 0.25)
    static let success = Color(red: 0.35, green: 0.92, blue: 0.62)
    static let error = Color(red: 1.0, green: 0.38, blue: 0.42)
}
