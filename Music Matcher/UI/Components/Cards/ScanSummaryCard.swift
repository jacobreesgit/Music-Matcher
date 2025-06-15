import SwiftUI

struct ScanSummaryCard: View {
    let totalSongsScanned: Int
    let duplicatesFound: Int
    let totalDuplicateSongs: Int
    let totalIgnoredItems: Int
    let lastScanDate: Date?
    let onRescan: () -> Void
    let showIgnoredItems: Bool
    
    init(
        totalSongsScanned: Int,
        duplicatesFound: Int,
        totalDuplicateSongs: Int = 0,
        totalIgnoredItems: Int = 0,
        lastScanDate: Date? = nil,
        showIgnoredItems: Bool = true,
        onRescan: @escaping () -> Void
    ) {
        self.totalSongsScanned = totalSongsScanned
        self.duplicatesFound = duplicatesFound
        self.totalDuplicateSongs = totalDuplicateSongs
        self.totalIgnoredItems = totalIgnoredItems
        self.lastScanDate = lastScanDate
        self.showIgnoredItems = showIgnoredItems
        self.onRescan = onRescan
    }
    
    var body: some View {
        AppCard {
            VStack(spacing: AppSpacing.medium) {
                // Header
                headerSection
                
                // Main Metrics
                metricsSection
                
                // Ignored Items (if any)
                if showIgnoredItems && totalIgnoredItems > 0 {
                    ignoredItemsSection
                }
                
                // Last Scan Info
                if let lastScanDate = lastScanDate {
                    lastScanSection(date: lastScanDate)
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Scan Complete")
                    .font(AppFont.headline)
                    .foregroundColor(Color.designTextPrimary)
                
                Text(headerSubtitle)
                    .font(AppFont.subheadline)
                    .foregroundColor(Color.designTextSecondary)
            }
            
            Spacer()
            
            Button("Rescan") {
                onRescan()
            }
            .font(AppFont.subheadline)
            .foregroundColor(Color.designPrimary)
        }
    }
    
    // MARK: - Metrics Section
    private var metricsSection: some View {
        HStack(spacing: AppSpacing.large) {
            // Songs Scanned
            MetricDisplay(
                value: totalSongsScanned.formatted(),
                label: "songs scanned",
                color: Color.designTextPrimary,
                icon: "music.note"
            )
            
            // Duplicate Groups
            MetricDisplay(
                value: duplicatesFound.formatted(),
                label: duplicatesFound == 1 ? "duplicate group" : "duplicate groups",
                color: duplicatesFound > 0 ? Color.designPrimary : Color.designSuccess,
                icon: duplicatesFound > 0 ? "doc.on.doc" : "checkmark.circle"
            )
            
            // Total Duplicate Songs (if there are duplicates)
            if totalDuplicateSongs > 0 {
                MetricDisplay(
                    value: totalDuplicateSongs.formatted(),
                    label: "total songs",
                    color: Color.designSecondary,
                    icon: "music.note.list"
                )
            }
        }
    }
    
    // MARK: - Ignored Items Section
    private var ignoredItemsSection: some View {
        VStack(spacing: AppSpacing.small) {
            Divider()
                .background(Color.designTextTertiary)
            
            HStack {
                Image(systemName: "eye.slash")
                    .font(AppFont.iconSmall)
                    .foregroundColor(Color.designInfo)
                
                Text("\(totalIgnoredItems) items ignored from previous removals")
                    .font(AppFont.caption)
                    .foregroundColor(Color.designInfo)
                
                Spacer()
            }
        }
    }
    
    // MARK: - Last Scan Section
    private func lastScanSection(date: Date) -> some View {
        VStack(spacing: AppSpacing.small) {
            Divider()
                .background(Color.designTextTertiary)
            
            HStack {
                Image(systemName: "clock")
                    .font(AppFont.iconSmall)
                    .foregroundColor(Color.designTextTertiary)
                
                Text("Last scanned \(formatScanDate(date))")
                    .font(AppFont.caption)
                    .foregroundColor(Color.designTextTertiary)
                
                Spacer()
            }
        }
    }
    
    // MARK: - Computed Properties
    private var headerSubtitle: String {
        if duplicatesFound > 0 {
            return "Found potential duplicates"
        } else {
            return "No duplicates found"
        }
    }
    
    // MARK: - Helper Methods
    private func formatScanDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Metric Display Component

struct MetricDisplay: View {
    let value: String
    let label: String
    let color: Color
    let icon: String?
    
    init(
        value: String,
        label: String,
        color: Color,
        icon: String? = nil
    ) {
        self.value = value
        self.label = label
        self.color = color
        self.icon = icon
    }
    
    var body: some View {
        VStack(spacing: 4) {
            // Icon (if provided)
            if let icon = icon {
                Image(systemName: icon)
                    .font(AppFont.iconSmall)
                    .foregroundColor(color.opacity(0.7))
            }
            
            // Value
            Text(value)
                .font(AppFont.counterMedium)
                .foregroundColor(color)
            
            // Label
            Text(label)
                .font(AppFont.caption)
                .foregroundColor(Color.designTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Scan Results Overview Card

struct ScanResultsOverviewCard: View {
    let duplicatesFound: Int
    let totalSongsScanned: Int
    let highestImpactGroup: String?
    let potentialPlayCountsToSync: Int
    let scanDuration: TimeInterval?
    
    var body: some View {
        AppCard {
            VStack(spacing: AppSpacing.medium) {
                // Title
                AppSectionHeader("Scan Results", subtitle: "Summary of findings")
                
                // Key Findings
                VStack(spacing: AppSpacing.small) {
                    if duplicatesFound > 0 {
                        // Duplicates found
                        ScanFindingRow(
                            icon: "doc.on.doc.fill",
                            title: "Duplicate Groups Found",
                            value: "\(duplicatesFound)",
                            color: Color.designPrimary,
                            isHighlight: true
                        )
                        
                        // Potential impact
                        if potentialPlayCountsToSync > 0 {
                            ScanFindingRow(
                                icon: "play.fill",
                                title: "Potential Play Counts to Sync",
                                value: "\(potentialPlayCountsToSync)",
                                color: Color.designSecondary
                            )
                        }
                        
                        // Highest impact group
                        if let highestImpact = highestImpactGroup {
                            ScanFindingRow(
                                icon: "star.fill",
                                title: "Highest Impact",
                                value: highestImpact,
                                color: Color.designWarning
                            )
                        }
                    } else {
                        // No duplicates
                        ScanFindingRow(
                            icon: "checkmark.circle.fill",
                            title: "Library Status",
                            value: "Clean - No duplicates found",
                            color: Color.designSuccess,
                            isHighlight: true
                        )
                    }
                    
                    // Songs analyzed
                    ScanFindingRow(
                        icon: "music.note",
                        title: "Songs Analyzed",
                        value: totalSongsScanned.formatted(),
                        color: Color.designTextSecondary
                    )
                    
                    // Scan duration
                    if let scanDuration = scanDuration {
                        ScanFindingRow(
                            icon: "clock",
                            title: "Scan Duration",
                            value: formatDuration(scanDuration),
                            color: Color.designTextSecondary
                        )
                    }
                }
            }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.minute, .second]
        return formatter.string(from: duration) ?? "0s"
    }
}

// MARK: - Scan Finding Row

struct ScanFindingRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    let isHighlight: Bool
    
    init(
        icon: String,
        title: String,
        value: String,
        color: Color,
        isHighlight: Bool = false
    ) {
        self.icon = icon
        self.title = title
        self.value = value
        self.color = color
        self.isHighlight = isHighlight
    }
    
    var body: some View {
        HStack {
            // Icon
            Image(systemName: icon)
                .font(AppFont.iconSmall)
                .foregroundColor(color)
                .frame(width: 20)
            
            // Title
            Text(title)
                .font(isHighlight ? AppFont.subheadline : AppFont.caption)
                .fontWeight(isHighlight ? .medium : .regular)
                .foregroundColor(Color.designTextSecondary)
            
            Spacer()
            
            // Value
            Text(value)
                .font(isHighlight ? AppFont.subheadline : AppFont.caption)
                .fontWeight(isHighlight ? .semibold : .medium)
                .foregroundColor(isHighlight ? color : Color.designTextPrimary)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Empty Scan Results Card

struct EmptyScanResultsCard: View {
    let totalSongsScanned: Int
    let hasIgnoredItems: Bool
    let onRescan: () -> Void
    
    var body: some View {
        AppCard {
            VStack(spacing: AppSpacing.large) {
                // Success icon
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 50))
                    .foregroundColor(Color.designSuccess)
                
                VStack(spacing: AppSpacing.small) {
                    Text("No Duplicates Found")
                        .font(AppFont.title3)
                        .foregroundColor(Color.designTextPrimary)
                    
                    Text(emptyResultsMessage)
                        .font(AppFont.body)
                        .foregroundColor(Color.designTextSecondary)
                        .multilineTextAlignment(.center)
                }
                
                // Stats
                VStack(spacing: AppSpacing.small) {
                    Text("✓ \(totalSongsScanned.formatted()) songs analyzed")
                        .font(AppFont.caption)
                        .foregroundColor(Color.designSuccess)
                    
                    if hasIgnoredItems {
                        Text("Some items were excluded from previous removals")
                            .font(AppFont.caption)
                            .foregroundColor(Color.designInfo)
                    }
                }
                
                // Rescan button
                Button("Scan Again") {
                    onRescan()
                }
                .font(AppFont.subheadline)
                .foregroundColor(Color.designPrimary)
            }
            .padding(AppSpacing.medium)
        }
    }
    
    private var emptyResultsMessage: String {
        if hasIgnoredItems {
            return "Your music library doesn't contain any new songs with the same title and artist across different albums."
        } else {
            return "Your music library doesn't contain songs with the same title and artist across different albums."
        }
    }
}

// MARK: - Preview
#if DEBUG
struct ScanSummaryCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ScanSummaryCard(
                totalSongsScanned: 1250,
                duplicatesFound: 8,
                totalDuplicateSongs: 24,
                totalIgnoredItems: 3,
                lastScanDate: Date().addingTimeInterval(-3600),
                onRescan: {}
            )
            
            EmptyScanResultsCard(
                totalSongsScanned: 500,
                hasIgnoredItems: false,
                onRescan: {}
            )
        }
        .padding()
        .background(Color.designBackground)
    }
}
#endif
