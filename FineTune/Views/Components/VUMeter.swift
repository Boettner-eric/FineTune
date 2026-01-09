// FineTune/Views/Components/VUMeter.swift
import SwiftUI

/// A vertical VU meter visualization for audio levels
/// Shows 8 bars that light up based on audio level with peak hold
struct VUMeter: View {
    let level: Float

    @State private var peakLevel: Float = 0
    @State private var peakHoldTimer: Timer?

    private let barCount = DesignTokens.Dimensions.vuMeterBarCount

    var body: some View {
        HStack(spacing: DesignTokens.Dimensions.vuMeterBarSpacing) {
            ForEach(0..<barCount, id: \.self) { index in
                VUMeterBar(
                    index: index,
                    level: level,
                    peakLevel: peakLevel,
                    barCount: barCount
                )
            }
        }
        .frame(width: DesignTokens.Dimensions.vuMeterWidth)
        .onChange(of: level) { _, newLevel in
            // Update peak hold
            if newLevel > peakLevel {
                peakLevel = newLevel
                resetPeakTimer()
            }
        }
        .onDisappear {
            peakHoldTimer?.invalidate()
        }
    }

    private func resetPeakTimer() {
        peakHoldTimer?.invalidate()
        peakHoldTimer = Timer.scheduledTimer(withTimeInterval: DesignTokens.Timing.vuMeterPeakHold, repeats: false) { _ in
            withAnimation(DesignTokens.Animation.vuMeterDecay) {
                peakLevel = level
            }
        }
    }
}

/// Individual bar in the VU meter
private struct VUMeterBar: View {
    let index: Int
    let level: Float
    let peakLevel: Float
    let barCount: Int

    /// Threshold for this bar (0-1)
    private var threshold: Float {
        Float(index + 1) / Float(barCount)
    }

    /// Whether this bar should be lit based on current level
    private var isLit: Bool {
        level >= threshold
    }

    /// Whether this bar is the peak indicator
    private var isPeakIndicator: Bool {
        let peakBarIndex = Int(peakLevel * Float(barCount))
        return index == min(peakBarIndex, barCount - 1) && peakLevel > level
    }

    /// Color for this bar based on its position
    private var barColor: Color {
        if index < 5 {
            return DesignTokens.Colors.vuGreen
        } else if index < 7 {
            return DesignTokens.Colors.vuYellow
        } else {
            return DesignTokens.Colors.vuRed
        }
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 1)
            .fill(isLit || isPeakIndicator ? barColor : DesignTokens.Colors.vuUnlit)
            .frame(
                width: (DesignTokens.Dimensions.vuMeterWidth - CGFloat(barCount - 1) * DesignTokens.Dimensions.vuMeterBarSpacing) / CGFloat(barCount),
                height: DesignTokens.Dimensions.vuMeterBarHeight
            )
            .animation(DesignTokens.Animation.vuMeterLevel, value: isLit)
    }
}

/// Vertical VU meter (bars stacked vertically)
struct VUMeterVertical: View {
    let level: Float

    @State private var peakLevel: Float = 0
    @State private var peakHoldTimer: Timer?

    private let barCount = DesignTokens.Dimensions.vuMeterBarCount

    var body: some View {
        VStack(spacing: DesignTokens.Dimensions.vuMeterBarSpacing) {
            // Bars are displayed top to bottom (highest level at top)
            ForEach((0..<barCount).reversed(), id: \.self) { index in
                VUMeterBarVertical(
                    index: index,
                    level: level,
                    peakLevel: peakLevel,
                    barCount: barCount
                )
            }
        }
        .frame(width: DesignTokens.Dimensions.vuMeterWidth)
        .onChange(of: level) { _, newLevel in
            if newLevel > peakLevel {
                peakLevel = newLevel
                resetPeakTimer()
            }
        }
        .onDisappear {
            peakHoldTimer?.invalidate()
        }
    }

    private func resetPeakTimer() {
        peakHoldTimer?.invalidate()
        peakHoldTimer = Timer.scheduledTimer(withTimeInterval: DesignTokens.Timing.vuMeterPeakHold, repeats: false) { _ in
            withAnimation(DesignTokens.Animation.vuMeterDecay) {
                peakLevel = level
            }
        }
    }
}

/// Individual bar for vertical VU meter
private struct VUMeterBarVertical: View {
    let index: Int
    let level: Float
    let peakLevel: Float
    let barCount: Int

    private var threshold: Float {
        Float(index + 1) / Float(barCount)
    }

    private var isLit: Bool {
        level >= threshold
    }

    private var isPeakIndicator: Bool {
        let peakBarIndex = Int(peakLevel * Float(barCount))
        return index == min(peakBarIndex, barCount - 1) && peakLevel > level
    }

    private var barColor: Color {
        if index < 5 {
            return DesignTokens.Colors.vuGreen
        } else if index < 7 {
            return DesignTokens.Colors.vuYellow
        } else {
            return DesignTokens.Colors.vuRed
        }
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 1)
            .fill(isLit || isPeakIndicator ? barColor : DesignTokens.Colors.vuUnlit)
            .frame(height: DesignTokens.Dimensions.vuMeterBarHeight)
            .animation(DesignTokens.Animation.vuMeterLevel, value: isLit)
    }
}

// MARK: - Previews

#Preview("VU Meter - Horizontal") {
    ComponentPreviewContainer {
        VStack(spacing: DesignTokens.Spacing.md) {
            HStack {
                Text("0%")
                    .font(.caption)
                VUMeter(level: 0)
            }

            HStack {
                Text("25%")
                    .font(.caption)
                VUMeter(level: 0.25)
            }

            HStack {
                Text("50%")
                    .font(.caption)
                VUMeter(level: 0.5)
            }

            HStack {
                Text("75%")
                    .font(.caption)
                VUMeter(level: 0.75)
            }

            HStack {
                Text("100%")
                    .font(.caption)
                VUMeter(level: 1.0)
            }
        }
    }
}

#Preview("VU Meter - Vertical") {
    ComponentPreviewContainer {
        HStack(spacing: DesignTokens.Spacing.lg) {
            VStack {
                VUMeterVertical(level: 0.25)
                Text("25%").font(.caption2)
            }

            VStack {
                VUMeterVertical(level: 0.5)
                Text("50%").font(.caption2)
            }

            VStack {
                VUMeterVertical(level: 0.75)
                Text("75%").font(.caption2)
            }

            VStack {
                VUMeterVertical(level: 1.0)
                Text("100%").font(.caption2)
            }
        }
    }
}

#Preview("VU Meter - Animated") {
    struct AnimatedPreview: View {
        @State private var level: Float = 0

        var body: some View {
            ComponentPreviewContainer {
                VStack(spacing: DesignTokens.Spacing.lg) {
                    VUMeter(level: level)

                    VUMeterVertical(level: level)

                    Slider(value: Binding(
                        get: { Double(level) },
                        set: { level = Float($0) }
                    ))
                }
            }
        }
    }
    return AnimatedPreview()
}
