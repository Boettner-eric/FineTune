// FineTune/Views/Components/IconButton.swift
import SwiftUI

/// A styled icon button with hover effect
/// Supports active state for toggleable buttons like mute
struct IconButton: View {
    let systemName: String
    let isActive: Bool
    let action: () -> Void
    let helpText: String?

    @State private var isHovered = false

    init(
        systemName: String,
        isActive: Bool = false,
        helpText: String? = nil,
        action: @escaping () -> Void
    ) {
        self.systemName = systemName
        self.isActive = isActive
        self.helpText = helpText
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 14))
                .foregroundStyle(buttonColor)
                .frame(
                    minWidth: DesignTokens.Dimensions.minTouchTarget,
                    minHeight: DesignTokens.Dimensions.minTouchTarget
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
        .help(helpText ?? "")
        .animation(DesignTokens.Animation.hover, value: isHovered)
    }

    private var buttonColor: Color {
        if isActive {
            return DesignTokens.Colors.mutedIndicator
        } else if isHovered {
            return DesignTokens.Colors.interactiveHover
        } else {
            return DesignTokens.Colors.interactiveDefault
        }
    }
}

/// A radio-style button for selecting default device
struct RadioButton: View {
    let isSelected: Bool
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 14))
                .foregroundStyle(isSelected ? DesignTokens.Colors.defaultDevice : buttonColor)
                .frame(
                    minWidth: DesignTokens.Dimensions.minTouchTarget,
                    minHeight: DesignTokens.Dimensions.minTouchTarget
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
        .help(isSelected ? "Default device" : "Set as default")
        .animation(DesignTokens.Animation.hover, value: isHovered)
    }

    private var buttonColor: Color {
        isHovered ? DesignTokens.Colors.interactiveHover : DesignTokens.Colors.interactiveDefault
    }
}

// MARK: - Previews

#Preview("Icon Buttons") {
    ComponentPreviewContainer {
        HStack(spacing: DesignTokens.Spacing.md) {
            IconButton(systemName: "speaker.wave.2.fill", helpText: "Mute") {}

            IconButton(systemName: "speaker.slash.fill", isActive: true, helpText: "Unmute") {}

            IconButton(systemName: "gearshape", helpText: "Settings") {}

            IconButton(systemName: "xmark", helpText: "Close") {}
        }
    }
}

#Preview("Radio Buttons") {
    ComponentPreviewContainer {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack {
                RadioButton(isSelected: true) {}
                Text("MacBook Pro Speakers")
            }

            HStack {
                RadioButton(isSelected: false) {}
                Text("AirPods Pro")
            }

            HStack {
                RadioButton(isSelected: false) {}
                Text("External Display")
            }
        }
    }
}
