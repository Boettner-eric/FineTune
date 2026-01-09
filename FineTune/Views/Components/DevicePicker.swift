// FineTune/Views/Components/DevicePicker.swift
import SwiftUI

/// A styled device picker dropdown
/// Shows current device with icon, name, and chevron
struct DevicePicker: View {
    let devices: [AudioDevice]
    let selectedDeviceUID: String
    let onDeviceSelected: (String) -> Void

    @State private var isHovered = false

    private var selectedDevice: AudioDevice? {
        devices.first { $0.uid == selectedDeviceUID }
    }

    var body: some View {
        Menu {
            ForEach(devices) { device in
                Button {
                    onDeviceSelected(device.uid)
                } label: {
                    HStack {
                        if let icon = device.icon {
                            Image(nsImage: icon)
                        } else {
                            Image(systemName: "speaker.wave.2")
                        }
                        Text(device.name)

                        if device.uid == selectedDeviceUID {
                            Spacer()
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: DesignTokens.Spacing.xs) {
                // Device icon
                Group {
                    if let icon = selectedDevice?.icon {
                        Image(nsImage: icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        Image(systemName: "speaker.wave.2")
                    }
                }
                .frame(
                    width: DesignTokens.Dimensions.iconSizeSmall,
                    height: DesignTokens.Dimensions.iconSizeSmall
                )

                // Device name
                Text(selectedDevice?.name ?? "Select Device")
                    .font(DesignTokens.Typography.pickerText)
                    .lineLimit(1)

                // Chevron
                Image(systemName: "chevron.down")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(DesignTokens.Colors.textTertiary)
            }
            .padding(.horizontal, DesignTokens.Spacing.sm)
            .padding(.vertical, DesignTokens.Spacing.xs)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.Dimensions.buttonRadius)
                    .fill(isHovered ? DesignTokens.Colors.pickerHover : DesignTokens.Colors.pickerBackground)
            )
            .foregroundStyle(DesignTokens.Colors.textSecondary)
        }
        .menuStyle(.borderlessButton)
        .frame(minWidth: DesignTokens.Dimensions.pickerMinWidth)
        .onHover { hovering in
            isHovered = hovering
        }
        .animation(DesignTokens.Animation.hover, value: isHovered)
    }
}

// MARK: - Previews

#Preview("Device Picker") {
    ComponentPreviewContainer {
        VStack(spacing: DesignTokens.Spacing.md) {
            DevicePicker(
                devices: MockData.sampleDevices,
                selectedDeviceUID: MockData.sampleDevices[0].uid,
                onDeviceSelected: { _ in }
            )

            DevicePicker(
                devices: MockData.sampleDevices,
                selectedDeviceUID: MockData.sampleDevices[1].uid,
                onDeviceSelected: { _ in }
            )
        }
    }
}
