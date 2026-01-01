// FineTune/Audio/AudioEngine.swift
import Foundation
import os

@Observable
@MainActor
final class AudioEngine {
    let monitor = AudioProcessMonitor()
    let volumeState = VolumeState()

    private var taps: [pid_t: ProcessTapController] = [:]
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "FineTune", category: "AudioEngine")

    init() {
        Task { @MainActor in
            monitor.start()
        }
    }

    var apps: [AudioApp] {
        monitor.activeApps
    }

    func start() {
        monitor.start()
        logger.info("AudioEngine started")
    }

    func stop() {
        monitor.stop()
        // Cleanup all taps
        for tap in taps.values {
            tap.invalidate()
        }
        taps.removeAll()
        logger.info("AudioEngine stopped")
    }

    func setVolume(for app: AudioApp, to volume: Float) {
        volumeState.setVolume(for: app.id, to: volume)

        if volume >= 1.0 {
            // No need for tap at 100% volume
            if let tap = taps.removeValue(forKey: app.id) {
                tap.invalidate()
                logger.debug("Removed tap for \(app.name) (volume at 100%)")
            }
        } else {
            // Need a tap for volume control
            if let existingTap = taps[app.id] {
                existingTap.volume = volume
            } else {
                // Create new tap
                let tap = ProcessTapController(app: app)
                tap.volume = volume
                do {
                    try tap.activate()
                    taps[app.id] = tap
                    logger.debug("Created tap for \(app.name) at \(Int(volume * 100))%")
                } catch {
                    logger.error("Failed to create tap for \(app.name): \(error.localizedDescription)")
                }
            }
        }
    }

    func getVolume(for app: AudioApp) -> Float {
        volumeState.getVolume(for: app.id)
    }

    func cleanupStaleTaps() {
        let activePIDs = Set(apps.map { $0.id })
        let stalePIDs = Set(taps.keys).subtracting(activePIDs)

        for pid in stalePIDs {
            if let tap = taps.removeValue(forKey: pid) {
                tap.invalidate()
                logger.debug("Cleaned up stale tap for PID \(pid)")
            }
        }

        volumeState.cleanup(keeping: activePIDs)
    }
}
