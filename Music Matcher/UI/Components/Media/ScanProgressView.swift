import SwiftUI

struct ScanProgressView: View {
    let progress: Double
    let totalSongsScanned: Int
    let isScanning: Bool
    let style: ProgressStyle
    
    enum ProgressStyle {
        case fullScreen     // Large center display for main scanning
        case compact        // Smaller inline display
        case minimal        // Just the progress ring
        
        var ringSize: CGFloat {
            switch self {
            case .fullScreen: return 160
            case .compact: return 80
            case .minimal: return 60
            }
        }
        
        var showsDetails: Bool {
            switch self {
            case .fullScreen: return true
            case .compact: return true
            case .minimal: return false
            }
        }
        
        var showsTitle: Bool {
            switch self {
            case .fullScreen: return true
            default: return false
            }
        }
    }
    
    init(
        progress: Double,
        totalSongsScanned: Int = 0,
        isScanning: Bool = true,
        style: ProgressStyle = .fullScreen
    ) {
        self.progress = progress
        self.totalSongsScanned = totalSongsScanned
        self.isScanning = isScanning
        self.style = style
    }
    
    var body: some View {
        VStack(spacing: style == .fullScreen ? AppSpacing.xl : AppSpacing.medium) {
            // Title (for full screen style)
            if style.showsTitle {
                Text("Scanning Library")
                    .font(AppFont.title)
                    .foregroundColor(Color.designTextPrimary)
            }
            
            // Progress Ring with Center Content
            ZStack {
                AppProgressRing(
                    progress: progress,
                    lineWidth: style == .fullScreen ? 10 : 6,
                    size: style.ringSize
                )
                
                // Center Content
                centerContent
            }
            
            // Details (if enabled)
            if style.showsDetails {
                detailsSection
            }
        }
    }
    
    // MARK: - Center Content
    private var centerContent: some View {
        VStack(spacing: 4) {
            // Percentage
            Text("\(Int(progress * 100))%")
                .font(style == .fullScreen ? AppFont.counterMedium : AppFont.headline)
                .foregroundColor(Color.designTextPrimary)
            
            // Status text
            Text(statusText)
                .font(style == .fullScreen ? AppFont.subheadline : AppFont.caption)
                .foregroundColor(Color.designTextSecondary)
        }
    }
    
    // MARK: - Details Section
    private var detailsSection: some View {
        VStack(spacing: AppSpacing.small) {
            if totalSongsScanned > 0 {
                Text("Analyzing \(totalSongsScanned.formatted()) songs")
                    .font(AppFont.subheadline)
                    .foregroundColor(Color.designTextSecondary)
            }
            
            Text("Looking for duplicate titles across different albums")
                .font(AppFont.caption)
                .foregroundColor(Color.designTextTertiary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Computed Properties
    private var statusText: String {
        if !isScanning {
            return "Complete"
        } else {
            return "complete"
        }
    }
}

// MARK: - Scan Status Card

struct ScanStatusCard: View {
    let isScanning: Bool
    let progress: Double
    let totalSongsScanned: Int
    let timeElapsed: TimeInterval?
    let estimatedTimeRemaining: TimeInterval?
    
    var body: some View {
        AppCard {
            VStack(spacing: AppSpacing.medium) {
                // Header
                HStack {
                    Image(systemName: scanStatusIcon)
                        .font(AppFont.iconMedium)
                        .foregroundColor(scanStatusColor)
                    
                    Text(scanStatusTitle)
                        .font(AppFont.headline)
                        .foregroundColor(Color.designTextPrimary)
                    
                    Spacer()
                    
                    if isScanning {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.designPrimary))
                            .scaleEffect(0.8)
                    }
                }
                
                // Progress Details
                if isScanning {
                    VStack(spacing: AppSpacing.small) {
                        // Songs scanned
                        AppInfoRow(
                            "Songs Analyzed:",
                            value: totalSongsScanned.formatted()
                        )
                        
                        // Progress percentage
                        AppInfoRow(
                            "Progress:",
                            value: "\(Int(progress * 100))%",
                            valueColor: Color.designPrimary
                        )
                        
                        // Time information
                        if let timeElapsed = timeElapsed {
                            AppInfoRow(
                                "Time Elapsed:",
                                value: formatTime(timeElapsed)
                            )
                        }
                        
                        if let estimatedTimeRemaining = estimatedTimeRemaining {
                            AppInfoRow(
                                "Est. Remaining:",
                                value: formatTime(estimatedTimeRemaining),
                                valueColor: Color.designInfo
                            )
                        }
                    }
                }
            }
        }
    }
    
    private var scanStatusIcon: String {
        isScanning ? "magnifyingglass" : "checkmark.circle.fill"
    }
    
    private var scanStatusColor: Color {
        isScanning ? Color.designPrimary : Color.designSuccess
    }
    
    private var scanStatusTitle: String {
        isScanning ? "Scanning in Progress" : "Scan Complete"
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.minute, .second]
        return formatter.string(from: time) ?? "0s"
    }
}

// MARK: - Scanning Animation View

struct ScanningAnimationView: View {
    @State private var animationOffset: CGFloat = 0
    @State private var animationOpacity: Double = 0.3
    
    var body: some View {
        VStack(spacing: AppSpacing.large) {
            // Animated scanning icon
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.designPrimary.opacity(0.2), lineWidth: 2)
                    .frame(width: 100, height: 100)
                
                // Animated scanning line
                Rectangle()
                    .fill(Color.designPrimary)
                    .frame(width: 80, height: 2)
                    .offset(y: animationOffset)
                    .opacity(animationOpacity)
                    .clipped()
                
                // Center magnifying glass
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 40))
                    .foregroundColor(Color.designPrimary)
            }
            .frame(width: 100, height: 100)
            .onAppear {
                startAnimation()
            }
            
            Text("Analyzing your music library...")
                .font(AppFont.subheadline)
                .foregroundColor(Color.designTextSecondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private func startAnimation() {
        withAnimation(
            Animation.easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true)
        ) {
            animationOffset = 30
            animationOpacity = 1.0
        }
    }
}

// MARK: - Scan Complete Animation

struct ScanCompleteAnimationView: View {
    @State private var checkmarkScale: CGFloat = 0.5
    @State private var checkmarkOpacity: Double = 0
    @State private var showingContent = false
    
    let duplicatesFound: Int
    let totalSongsScanned: Int
    
    var body: some View {
        VStack(spacing: AppSpacing.large) {
            // Animated checkmark
            ZStack {
                Circle()
                    .fill(Color.designSuccess.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color.designSuccess)
                    .scaleEffect(checkmarkScale)
                    .opacity(checkmarkOpacity)
            }
            
            // Results text
            if showingContent {
                VStack(spacing: AppSpacing.small) {
                    Text("Scan Complete!")
                        .font(AppFont.headline)
                        .foregroundColor(Color.designTextPrimary)
                    
                    if duplicatesFound > 0 {
                        Text("Found \(duplicatesFound) duplicate groups")
                            .font(AppFont.subheadline)
                            .foregroundColor(Color.designPrimary)
                    } else {
                        Text("No duplicates found")
                            .font(AppFont.subheadline)
                            .foregroundColor(Color.designSuccess)
                    }
                    
                    Text("Scanned \(totalSongsScanned.formatted()) songs")
                        .font(AppFont.caption)
                        .foregroundColor(Color.designTextSecondary)
                }
                .transition(.opacity.combined(with: .scale))
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        // Animate checkmark
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            checkmarkScale = 1.0
            checkmarkOpacity = 1.0
        }
        
        // Show content after checkmark animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeInOut(duration: 0.5)) {
                showingContent = true
            }
        }
    }
}

// MARK: - Preview
#if DEBUG
struct ScanProgressView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 40) {
            // Full screen progress
            ScanProgressView(
                progress: 0.65,
                totalSongsScanned: 1250,
                style: .fullScreen
            )
            
            // Compact progress
            ScanProgressView(
                progress: 0.35,
                totalSongsScanned: 500,
                style: .compact
            )
            
            // Scanning animation
            ScanningAnimationView()
        }
        .padding()
        .background(Color.designBackground)
    }
}
#endif
