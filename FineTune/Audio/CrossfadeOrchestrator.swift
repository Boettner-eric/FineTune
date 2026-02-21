// FineTune/Audio/CrossfadeOrchestrator.swift
import AudioToolbox
import os

/// Error types for crossfade and tap operations
enum CrossfadeError: LocalizedError {
    case tapCreationFailed(OSStatus)
    case aggregateCreationFailed(OSStatus)
    case deviceNotReady
    case timeout
    case secondaryTapFailed
    case noTapDescription

    var errorDescription: String? {
        switch self {
        case .tapCreationFailed(let status):
            return "Failed to create process tap: \(status)"
        case .aggregateCreationFailed(let status):
            return "Failed to create aggregate device: \(status)"
        case .deviceNotReady:
            return "Device not ready within timeout"
        case .timeout:
            return "Crossfade timed out"
        case .secondaryTapFailed:
            return "Secondary tap invalid after timeout"
        case .noTapDescription:
            return "No tap description available"
        }
    }
}

/// Configuration for crossfade behavior during device switching.
/// The crossfade overlaps audio from old and new devices using equal-power curves
/// to maintain perceived loudness during the transition.
enum CrossfadeConfig {
    /// 50ms is short enough to feel instantaneous but long enough to avoid clicks.
    /// Shorter durations risk audible artifacts; longer durations feel sluggish.
    /// Can be overridden via UserDefaults for testing/debugging.
    static let defaultDuration: TimeInterval = 0.050  // 50ms

    static var duration: TimeInterval {
        let custom = UserDefaults.standard.double(forKey: "FineTuneCrossfadeDuration")
        return custom > 0 ? custom : defaultDuration
    }

    static func totalSamples(at sampleRate: Double) -> Int64 {
        Int64(sampleRate * duration)
    }
}

/// Utility methods for tap management.
/// The main crossfade orchestration stays in ProcessTapController to maintain
/// direct access to RT-safe state without introducing virtual dispatch.
enum CrossfadeOrchestrator {
    private static let logger = Logger(subsystem: "com.finetuneapp.FineTune", category: "CrossfadeOrchestrator")

    /// Destroys a tap and its associated aggregate device in the correct teardown order:
    /// 1. Stop device proc → 2. Destroy IO proc → 3. Destroy aggregate → 4. Destroy tap
    /// Safe to call with invalid IDs - they will be skipped.
    static func destroyTap(
        aggregateID: AudioObjectID,
        deviceProcID: AudioDeviceIOProcID?,
        tapID: AudioObjectID
    ) {
        // Step 1 & 2: Stop and destroy IO proc
        if aggregateID.isValid {
            if let procID = deviceProcID {
                let stopErr = AudioDeviceStop(aggregateID, procID)
                if stopErr != noErr {
                    logger.error("AudioDeviceStop failed for aggregate \(aggregateID): OSStatus \(stopErr)")
                }
                let destroyProcErr = AudioDeviceDestroyIOProcID(aggregateID, procID)
                if destroyProcErr != noErr {
                    logger.error("AudioDeviceDestroyIOProcID failed for aggregate \(aggregateID): OSStatus \(destroyProcErr)")
                }
            }
        }

        // Step 3: Destroy aggregate device
        if aggregateID.isValid {
            CrashGuard.untrackDevice(aggregateID)
            let aggErr = AudioHardwareDestroyAggregateDevice(aggregateID)
            if aggErr != noErr {
                logger.error("AudioHardwareDestroyAggregateDevice failed for \(aggregateID): OSStatus \(aggErr)")
            }
        }

        // Step 4: Destroy process tap
        if tapID.isValid {
            let tapErr = AudioHardwareDestroyProcessTap(tapID)
            if tapErr != noErr {
                logger.error("AudioHardwareDestroyProcessTap failed for \(tapID): OSStatus \(tapErr)")
            }
        }
    }
}
