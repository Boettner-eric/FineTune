// FineTune/Views/Components/MinimalSlider.swift
import SwiftUI

/// A minimal line slider with thin track and subtle thumb
/// The thumb appears on hover/drag for a clean resting appearance
struct MinimalSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let showUnityMarker: Bool
    let onEditingChanged: ((Bool) -> Void)?

    @State private var isHovered = false
    @State private var isDragging = false

    init(
        value: Binding<Double>,
        in range: ClosedRange<Double> = 0...1,
        showUnityMarker: Bool = false,
        onEditingChanged: ((Bool) -> Void)? = nil
    ) {
        self._value = value
        self.range = range
        self.showUnityMarker = showUnityMarker
        self.onEditingChanged = onEditingChanged
    }

    private var normalizedValue: Double {
        (value - range.lowerBound) / (range.upperBound - range.lowerBound)
    }

    private var showThumb: Bool {
        isHovered || isDragging
    }

    var body: some View {
        GeometryReader { geometry in
            let trackWidth = geometry.size.width
            let thumbPosition = trackWidth * normalizedValue

            ZStack(alignment: .leading) {
                // Track background
                Capsule()
                    .fill(DesignTokens.Colors.sliderTrack)
                    .frame(height: DesignTokens.Dimensions.sliderTrackHeight)

                // Filled track
                Capsule()
                    .fill(DesignTokens.Colors.sliderFill)
                    .frame(width: max(0, thumbPosition), height: DesignTokens.Dimensions.sliderTrackHeight)

                // Unity marker (optional - shows at 50% for 0-1 range)
                if showUnityMarker {
                    let unityPosition = trackWidth * 0.5
                    Rectangle()
                        .fill(DesignTokens.Colors.unityMarker)
                        .frame(width: 1, height: 10)
                        .position(x: unityPosition, y: geometry.size.height / 2)
                        .allowsHitTesting(false)
                }

                // Thumb
                Circle()
                    .fill(DesignTokens.Colors.sliderThumb)
                    .frame(
                        width: DesignTokens.Dimensions.sliderThumbSize,
                        height: DesignTokens.Dimensions.sliderThumbSize
                    )
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                    .position(
                        x: thumbPosition,
                        y: geometry.size.height / 2
                    )
                    .opacity(showThumb ? 1 : 0)
                    .scaleEffect(showThumb ? 1 : 0.5)
                    .animation(DesignTokens.Animation.thumbReveal, value: showThumb)
            }
            .frame(height: geometry.size.height)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        if !isDragging {
                            isDragging = true
                            onEditingChanged?(true)
                        }
                        let newValue = gesture.location.x / trackWidth
                        let clamped = min(max(newValue, 0), 1)
                        value = range.lowerBound + clamped * (range.upperBound - range.lowerBound)
                    }
                    .onEnded { _ in
                        isDragging = false
                        onEditingChanged?(false)
                    }
            )
            .onHover { hovering in
                isHovered = hovering
            }
        }
        .frame(height: DesignTokens.Dimensions.sliderThumbSize)
        .frame(minWidth: DesignTokens.Dimensions.sliderMinWidth)
    }
}

// MARK: - Previews

#Preview("Minimal Slider - Default") {
    struct PreviewWrapper: View {
        @State private var value: Double = 0.5

        var body: some View {
            ComponentPreviewContainer {
                VStack(spacing: 20) {
                    MinimalSlider(value: $value)

                    Text("Value: \(Int(value * 100))%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    return PreviewWrapper()
}

#Preview("Minimal Slider - With Unity Marker") {
    struct PreviewWrapper: View {
        @State private var value: Double = 0.75

        var body: some View {
            ComponentPreviewContainer {
                VStack(spacing: 20) {
                    MinimalSlider(value: $value, showUnityMarker: true)

                    Text("Value: \(Int(value * 200))% (unity at 100%)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    return PreviewWrapper()
}

#Preview("Minimal Slider - Multiple States") {
    ComponentPreviewContainer {
        VStack(spacing: 16) {
            SliderPreviewRow(label: "0%", value: 0)
            SliderPreviewRow(label: "25%", value: 0.25)
            SliderPreviewRow(label: "50%", value: 0.5)
            SliderPreviewRow(label: "75%", value: 0.75)
            SliderPreviewRow(label: "100%", value: 1.0)
        }
    }
}

private struct SliderPreviewRow: View {
    let label: String
    @State var value: Double

    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .frame(width: 40)
            MinimalSlider(value: $value)
        }
    }
}
