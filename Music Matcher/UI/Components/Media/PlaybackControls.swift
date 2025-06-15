import SwiftUI

struct PlaybackControls: View {
    let isPlaying: Bool
    let canPlay: Bool
    let onPlayPause: () -> Void
    let onStop: () -> Void
    let style: ControlStyle
    
    enum ControlStyle {
        case standard       // Default size controls
        case large         // Prominent controls for main playback
        case compact       // Smaller controls for inline use
        
        var buttonSize: CGFloat {
            switch self {
            case .standard: return 50
            case .large: return 60
            case .compact: return 40
            }
        }
        
        var spacing: CGFloat {
            switch self {
            case .standard: return AppSpacing.large
            case .large: return AppSpacing.xl
            case .compact: return AppSpacing.medium
            }
        }
        
        var showLabels: Bool {
            switch self {
            case .large: return true
            default: return false
            }
        }
    }
    
    init(
        isPlaying: Bool,
        canPlay: Bool = true,
        style: ControlStyle = .standard,
        onPlayPause: @escaping () -> Void,
        onStop: @escaping () -> Void
    ) {
        self.isPlaying = isPlaying
        self.canPlay = canPlay
        self.style = style
        self.onPlayPause = onPlayPause
        self.onStop = onStop
    }
    
    var body: some View {
        VStack(spacing: style.showLabels ? AppSpacing.medium : 0) {
            // Control Buttons
            HStack(spacing: style.spacing) {
                // Play/Pause Button
                PlaybackButton(
                    icon: playPauseIcon,
                    color: Color.designPrimary,
                    size: style.buttonSize,
                    isEnabled: canPlay,
                    action: onPlayPause
                )
                
                // Stop Button
                PlaybackButton(
                    icon: "stop.circle.fill",
                    color: Color.designError,
                    size: style.buttonSize,
                    isEnabled: true,
                    action: onStop
                )
            }
            
            // Control Labels (for large style)
            if style.showLabels {
                HStack(spacing: labelSpacing) {
                    Text(playPauseLabel)
                        .font(AppFont.caption)
                        .foregroundColor(Color.designTextSecondary)
                    
                    Text("Stop")
                        .font(AppFont.caption)
                        .foregroundColor(Color.designTextSecondary)
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    private var playPauseIcon: String {
        if isPlaying {
            return "pause.circle.fill"
        } else {
            return "play.circle.fill"
        }
    }
    
    private var playPauseLabel: String {
        if isPlaying {
            return "Pause"
        } else {
            return canPlay ? "Resume" : "Play"
        }
    }
    
    private var labelSpacing: CGFloat {
        // Calculate spacing to align labels with buttons
        switch style {
        case .large: return 70
        case .standard: return 50
        case .compact: return 30
        }
    }
}

// MARK: - Playback Button Component

struct PlaybackButton: View {
    let icon: String
    let color: Color
    let size: CGFloat
    let isEnabled: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.6)) // Icon size relative to button
                .foregroundColor(isEnabled ? color : Color.designTextTertiary)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(Color.designBackgroundSecondary)
                        .appShadow(isPressed ? .light : .medium)
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .animation(AppAnimation.quick, value: isPressed)
        }
        .disabled(!isEnabled)
        .onTapGesture {
            withAnimation(AppAnimation.quick) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(AppAnimation.quick) {
                    isPressed = false
                }
            }
            
            action()
        }
    }
}

// MARK: - Playback Status Indicator

struct PlaybackStatusIndicator: View {
    let isProcessing: Bool
    let isPlaying: Bool
    let isPaused: Bool
    
    var body: some View {
        HStack(spacing: AppSpacing.small) {
            // Status Icon
            Image(systemName: statusIcon)
                .font(AppFont.iconSmall)
                .foregroundColor(statusColor)
            
            // Status Text
            Text(statusText)
                .font(AppFont.caption)
                .foregroundColor(statusColor)
        }
        .padding(.horizontal, AppSpacing.small)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(statusColor.opacity(0.1))
        )
    }
    
    private var statusIcon: String {
        if !isProcessing {
            return "stop.circle"
        } else if isPlaying {
            return "play.circle.fill"
        } else {
            return "pause.circle"
        }
    }
    
    private var statusText: String {
        if !isProcessing {
            return "Stopped"
        } else if isPlaying {
            return "Playing"
        } else {
            return "Paused"
        }
    }
    
    private var statusColor: Color {
        if !isProcessing {
            return Color.designTextTertiary
        } else if isPlaying {
            return Color.designSuccess
        } else {
            return Color.designWarning
        }
    }
}

// MARK: - Playback Progress Indicator

struct PlaybackProgressIndicator: View {
    let currentIteration: Int
    let totalIterations: Int
    let isProcessing: Bool
    
    var body: some View {
        VStack(spacing: AppSpacing.small) {
            // Progress Text
            HStack {
                Text("Progress")
                    .font(AppFont.caption)
                    .foregroundColor(Color.designTextSecondary)
                
                Spacer()
                
                Text("\(currentIteration) of \(totalIterations)")
                    .font(AppFont.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Color.designTextPrimary)
            }
            
            // Progress Bar
            ProgressView(value: progressValue)
                .progressViewStyle(LinearProgressViewStyle(tint: Color.designPrimary))
                .scaleEffect(y: 2) // Make the progress bar thicker
            
            // Percentage
            HStack {
                Spacer()
                
                Text("\(Int(progressValue * 100))%")
                    .font(AppFont.caption2)
                    .foregroundColor(Color.designTextTertiary)
            }
        }
        .padding(AppSpacing.small)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.small)
                .fill(Color.designBackgroundTertiary)
        )
    }
    
    private var progressValue: Double {
        guard totalIterations > 0 else { return 0 }
        return Double(currentIteration) / Double(totalIterations)
    }
}

// MARK: - Combined Playback Control Panel

struct PlaybackControlPanel: View {
    let isProcessing: Bool
    let isPlaying: Bool
    let currentIteration: Int
    let totalIterations: Int
    let onPlayPause: () -> Void
    let onStop: () -> Void
    
    var body: some View {
        VStack(spacing: AppSpacing.medium) {
            // Status and Progress
            VStack(spacing: AppSpacing.small) {
                PlaybackStatusIndicator(
                    isProcessing: isProcessing,
                    isPlaying: isPlaying,
                    isPaused: isProcessing && !isPlaying
                )
                
                if isProcessing {
                    PlaybackProgressIndicator(
                        currentIteration: currentIteration,
                        totalIterations: totalIterations,
                        isProcessing: isProcessing
                    )
                }
            }
            
            // Controls
            PlaybackControls(
                isPlaying: isPlaying,
                canPlay: isProcessing,
                style: .large,
                onPlayPause: onPlayPause,
                onStop: onStop
            )
        }
        .padding(AppSpacing.medium)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                .fill(Color.designBackgroundSecondary)
                .appShadow(.light)
        )
    }
}

// MARK: - Preview
#if DEBUG
struct PlaybackControls_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            // Large style with labels
            PlaybackControls(
                isPlaying: true,
                style: .large,
                onPlayPause: {},
                onStop: {}
            )
            
            // Standard style
            PlaybackControls(
                isPlaying: false,
                style: .standard,
                onPlayPause: {},
                onStop: {}
            )
            
            // Compact style
            PlaybackControls(
                isPlaying: true,
                style: .compact,
                onPlayPause: {},
                onStop: {}
            )
            
            // Control panel
            PlaybackControlPanel(
                isProcessing: true,
                isPlaying: true,
                currentIteration: 15,
                totalIterations: 25,
                onPlayPause: {},
                onStop: {}
            )
        }
        .padding()
        .background(Color.designBackground)
    }
}
#endif
