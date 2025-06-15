import SwiftUI
import MediaPlayer

struct PlayCountComparison: View {
    let sourceTrack: MPMediaItem
    let targetTrack: MPMediaItem
    let showActionPreviews: Bool
    
    init(
        sourceTrack: MPMediaItem,
        targetTrack: MPMediaItem,
        showActionPreviews: Bool = true
    ) {
        self.sourceTrack = sourceTrack
        self.targetTrack = targetTrack
        self.showActionPreviews = showActionPreviews
    }
    
    var body: some View {
        AppCard {
            VStack(spacing: AppSpacing.medium) {
                AppSectionHeader("Play Count Comparison")
                
                // Track Comparison Row
                comparisonRow
                
                // Action Previews (if enabled)
                if showActionPreviews {
                    actionPreviewsSection
                }
            }
        }
    }
    
    // MARK: - Comparison Row
    private var comparisonRow: some View {
        HStack(spacing: AppSpacing.medium) {
            // Source track info
            PlayCountTrackDisplay(
                track: sourceTrack,
                label: "Source",
                color: Color.designPrimary
            )
            
            // Arrow and difference indicator
            differenceIndicator
            
            // Target track info
            PlayCountTrackDisplay(
                track: targetTrack,
                label: "Target",
                color: Color.designSecondary
            )
        }
    }
    
    // MARK: - Difference Indicator
    private var differenceIndicator: some View {
        VStack(spacing: 4) {
            Image(systemName: "arrow.right")
                .font(AppFont.iconMedium)
                .foregroundColor(Color.designTextSecondary)
            
            let difference = sourceTrack.playCount - targetTrack.playCount
            if difference > 0 {
                Text("+\(difference)")
                    .font(AppFont.caption)
                    .foregroundColor(Color.designSecondary)
            } else if difference < 0 {
                Text("\(difference)")
                    .font(AppFont.caption)
                    .foregroundColor(Color.designWarning)
            } else {
                Text("0")
                    .font(AppFont.caption)
                    .foregroundColor(Color.designSuccess)
            }
        }
    }
    
    // MARK: - Action Previews Section
    private var actionPreviewsSection: some View {
        VStack(spacing: AppSpacing.small) {
            Divider()
                .background(Color.designTextTertiary)
            
            VStack(spacing: AppSpacing.small) {
                // Match action preview
                ActionPreviewRow(
                    action: "Match",
                    description: "\(targetTrack.playCount) → \(sourceTrack.playCount)",
                    color: Color.designPrimary
                )
                
                // Add action preview
                ActionPreviewRow(
                    action: "Add",
                    description: "\(targetTrack.playCount) → \(targetTrack.playCount + sourceTrack.playCount)",
                    color: Color.designSecondary
                )
            }
        }
    }
}

// MARK: - Play Count Track Display

struct PlayCountTrackDisplay: View {
    let track: MPMediaItem
    let label: String
    let color: Color
    let isCompact: Bool
    
    init(
        track: MPMediaItem,
        label: String,
        color: Color,
        isCompact: Bool = false
    ) {
        self.track = track
        self.label = label
        self.color = color
        self.isCompact = isCompact
    }
    
    var body: some View {
        VStack(spacing: isCompact ? 2 : AppSpacing.small) {
            Text(label)
                .font(isCompact ? AppFont.caption2 : AppFont.caption)
                .foregroundColor(Color.designTextSecondary)
            
            Text("\(track.playCount)")
                .font(isCompact ? AppFont.headline : AppFont.counterMedium)
                .foregroundColor(color)
            
            Text(isCompact ? "plays" : "plays")
                .font(isCompact ? AppFont.caption2 : AppFont.caption)
                .foregroundColor(Color.designTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Action Preview Row

struct ActionPreviewRow: View {
    let action: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack {
            Text("\(action):")
                .font(AppFont.subheadline)
                .foregroundColor(Color.designTextSecondary)
            
            Spacer()
            
            Text(description)
                .font(AppFont.subheadline)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
    }
}

// MARK: - Compact Play Count Comparison

struct CompactPlayCountComparison: View {
    let sourceCount: Int
    let targetCount: Int
    let sourceLabel: String
    let targetLabel: String
    
    init(
        sourceCount: Int,
        targetCount: Int,
        sourceLabel: String = "Source",
        targetLabel: String = "Target"
    ) {
        self.sourceCount = sourceCount
        self.targetCount = targetCount
        self.sourceLabel = sourceLabel
        self.targetLabel = targetLabel
    }
    
    var body: some View {
        HStack(spacing: AppSpacing.medium) {
            // Source
            VStack(spacing: 2) {
                Text(sourceLabel)
                    .font(AppFont.caption2)
                    .foregroundColor(Color.designTextSecondary)
                
                Text("\(sourceCount)")
                    .font(AppFont.headline)
                    .foregroundColor(Color.designPrimary)
            }
            
            // Arrow
            Image(systemName: "arrow.right")
                .font(AppFont.iconSmall)
                .foregroundColor(Color.designTextSecondary)
            
            // Target
            VStack(spacing: 2) {
                Text(targetLabel)
                    .font(AppFont.caption2)
                    .foregroundColor(Color.designTextSecondary)
                
                Text("\(targetCount)")
                    .font(AppFont.headline)
                    .foregroundColor(Color.designSecondary)
            }
            
            // Difference
            if sourceCount != targetCount {
                VStack(spacing: 2) {
                    Text("Diff")
                        .font(AppFont.caption2)
                        .foregroundColor(Color.designTextSecondary)
                    
                    let diff = sourceCount - targetCount
                    Text(diff > 0 ? "+\(diff)" : "\(diff)")
                        .font(AppFont.caption)
                        .foregroundColor(diff > 0 ? Color.designSuccess : Color.designWarning)
                }
            }
        }
        .padding(AppSpacing.small)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.small)
                .fill(Color.designBackgroundTertiary)
        )
    }
}

// MARK: - Play Count Status Indicator

struct PlayCountStatusIndicator: View {
    let sourceCount: Int
    let targetCount: Int
    let showRecommendation: Bool
    
    init(
        sourceCount: Int,
        targetCount: Int,
        showRecommendation: Bool = true
    ) {
        self.sourceCount = sourceCount
        self.targetCount = targetCount
        self.showRecommendation = showRecommendation
    }
    
    var body: some View {
        HStack(spacing: AppSpacing.small) {
            // Status icon
            Image(systemName: statusIcon)
                .font(AppFont.iconSmall)
                .foregroundColor(statusColor)
            
            // Status message
            Text(statusMessage)
                .font(AppFont.caption)
                .foregroundColor(statusColor)
            
            Spacer()
            
            // Recommendation (if enabled)
            if showRecommendation && needsAction {
                Text(recommendation)
                    .font(AppFont.caption)
                    .foregroundColor(Color.designInfo)
            }
        }
        .padding(AppSpacing.small)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.small)
                .fill(statusColor.opacity(0.1))
        )
    }
    
    // MARK: - Computed Properties
    private var statusIcon: String {
        if sourceCount == targetCount {
            return "checkmark.circle.fill"
        } else if sourceCount > targetCount {
            return "arrow.up.circle.fill"
        } else {
            return "arrow.down.circle.fill"
        }
    }
    
    private var statusColor: Color {
        if sourceCount == targetCount {
            return Color.designSuccess
        } else if sourceCount > targetCount {
            return Color.designPrimary
        } else {
            return Color.designWarning
        }
    }
    
    private var statusMessage: String {
        let difference = abs(sourceCount - targetCount)
        
        if sourceCount == targetCount {
            return "Play counts already match"
        } else if sourceCount > targetCount {
            return "Source has \(difference) more plays"
        } else {
            return "Target has \(difference) more plays"
        }
    }
    
    private var recommendation: String {
        if sourceCount > targetCount {
            return "Consider using Match or Add"
        } else {
            return "Consider swapping source and target"
        }
    }
    
    private var needsAction: Bool {
        return sourceCount != targetCount
    }
}

// MARK: - Play Count Summary Card

struct PlayCountSummaryCard: View {
    let tracks: [MPMediaItem]
    let title: String
    
    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                AppSectionHeader(title)
                
                VStack(spacing: AppSpacing.small) {
                    // Total play counts
                    let totalPlays = tracks.reduce(0) { $0 + $1.playCount }
                    AppInfoRow(
                        "Total Play Counts:",
                        value: totalPlays.formatted(),
                        valueColor: Color.designPrimary
                    )
                    
                    // Range
                    if tracks.count > 1 {
                        let minPlays = tracks.map { $0.playCount }.min() ?? 0
                        let maxPlays = tracks.map { $0.playCount }.max() ?? 0
                        
                        AppInfoRow(
                            "Range:",
                            value: minPlays == maxPlays ? "\(minPlays)" : "\(minPlays) - \(maxPlays)",
                            valueColor: Color.designTextPrimary
                        )
                    }
                    
                    // Average
                    if tracks.count > 1 {
                        let avgPlays = totalPlays / tracks.count
                        AppInfoRow(
                            "Average:",
                            value: "\(avgPlays)",
                            valueColor: Color.designInfo
                        )
                    }
                    
                    // Version count
                    AppInfoRow(
                        "Versions:",
                        value: tracks.count.formatted(),
                        valueColor: Color.designSecondary
                    )
                }
            }
        }
    }
}

// MARK: - Preview
#if DEBUG
struct PlayCountComparison_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // This would need sample MPMediaItems in a real preview
            CompactPlayCountComparison(
                sourceCount: 25,
                targetCount: 15
            )
            
            PlayCountStatusIndicator(
                sourceCount: 30,
                targetCount: 20
            )
            
            Text("PlayCountComparison Preview")
                .font(AppFont.headline)
                .foregroundColor(Color.designTextPrimary)
        }
        .padding()
        .background(Color.designBackground)
    }
}
#endif
