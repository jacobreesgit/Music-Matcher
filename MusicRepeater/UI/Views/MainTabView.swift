import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Image(systemName: "music.note")
                        .accessibilityLabel("Music Repeater")
                    Text("Repeater")
                        .font(AppFont.caption)
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                        .accessibilityLabel("Settings")
                    Text("Settings")
                        .font(AppFont.caption)
                }
        }
        .accentColor(Color.designPrimary)
        .background(Color.designBackground)
    }
}

#if DEBUG
// Mock ContentView for previews that bypasses permission checks
struct MockContentView: View {
    let scenario: PreviewScenario
    @StateObject private var viewModel = MusicRepeaterViewModel()
    @State private var showingSourcePicker = false
    @State private var showingTargetPicker = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    init(scenario: PreviewScenario = .successState) {
        self.scenario = scenario
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: AppSpacing.large) {
                    // Main Title
                    Text("Music Repeater")
                        .font(AppFont.largeTitle)
                        .foregroundColor(Color.designTextPrimary)
                        .padding(.top, AppSpacing.xxl)
                    
                    VStack(spacing: AppSpacing.medium) {
                        // Source Track Section
                        VStack(alignment: .leading, spacing: AppSpacing.small) {
                            AppSectionHeader("Source Track", subtitle: "Track to copy play count from")
                            
                            mockSourceButton
                        }
                        
                        // Target Track Section
                        VStack(alignment: .leading, spacing: AppSpacing.small) {
                            AppSectionHeader("Target Track", subtitle: "Track to update play count for")
                            
                            mockTargetButton
                        }
                    }
                    .appPadding(.horizontal)
                    
                    // Warnings and Comparisons based on scenario
                    mockWarningsAndComparisons
                        .padding(.horizontal, AppSpacing.medium)
                    
                    // Add bottom spacing for safe area
                    Spacer(minLength: 120)
                }
            }
            
            // Fixed Action Buttons at bottom
            mockActionButtons
        }
        .background(Color.designBackground)
        .sheet(isPresented: $showingSourcePicker) {
            // Mock sheet for preview
            MockMusicPickerView(title: "Select Source Track")
        }
        .sheet(isPresented: $showingTargetPicker) {
            // Mock sheet for preview
            MockMusicPickerView(title: "Select Target Track")
        }
    }
    
    @ViewBuilder
    private var mockSourceButton: some View {
        if scenario == .noTracksSelected {
            AppSelectionButton(
                icon: "music.note",
                placeholderTitle: "Choose Source Track",
                placeholderSubtitle: "Tap to select from your music library"
            ) {
                showingSourcePicker = true
            }
        } else {
            mockTrackButton(
                icon: "music.note",
                title: "Song Title - Artist Name",
                subtitle: mockSourcePlayCount
            ) {
                showingSourcePicker = true
            }
        }
    }
    
    @ViewBuilder
    private var mockTargetButton: some View {
        if scenario == .noTracksSelected || scenario == .onlySourceSelected {
            AppSelectionButton(
                icon: "music.note.list",
                placeholderTitle: "Choose Target Track",
                placeholderSubtitle: "Tap to select from your music library"
            ) {
                showingTargetPicker = true
            }
        } else {
            mockTrackButton(
                icon: "music.note.list",
                title: scenario == .sameSong ? "Song Title - Artist Name" : "Song Title (Album Version) - Artist Name",
                subtitle: mockTargetPlayCount
            ) {
                showingTargetPicker = true
            }
        }
    }
    
    private func mockTrackButton(icon: String, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.medium) {
                // Mock artwork
                RoundedRectangle(cornerRadius: AppCornerRadius.small)
                    .fill(Color.designBackgroundTertiary)
                    .overlay(
                        Image(systemName: icon)
                            .font(AppFont.iconMedium)
                            .foregroundColor(Color.designPrimary)
                    )
                    .frame(width: 60, height: 60)
                
                // Mock track info
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(AppFont.body)
                        .foregroundColor(Color.designTextPrimary)
                        .lineLimit(2)
                    
                    Text(subtitle)
                        .font(AppFont.subheadline)
                        .foregroundColor(Color.designTextSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(AppFont.iconSmall)
                    .foregroundColor(Color.designTextTertiary)
            }
            .padding(AppSpacing.medium)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                    .fill(Color.designBackgroundSecondary)
                    .appShadow(.light)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    private var mockWarningsAndComparisons: some View {
        switch scenario {
        case .noTracksSelected, .onlySourceSelected:
            EmptyView()
            
        case .sameSong:
            AppWarningBanner("Warning: You've selected the same song for both source and target.")
            
        case .sourceFewerPlays:
            AppWarningBanner("Source track has fewer plays (25) than target track (42). Consider swapping the tracks or selecting a different source.", icon: "exclamationmark.triangle.fill")
            
        case .samePlayCount:
            AppWarningBanner("Both tracks have the same play count (30). No additional plays are needed.", icon: "exclamationmark.triangle.fill")
            
        case .successState:
            mockComparisonCard
        }
    }
    
    private var mockComparisonCard: some View {
        AppCard {
            VStack(spacing: AppSpacing.medium) {
                AppSectionHeader("Play Count Comparison")
                
                HStack(spacing: AppSpacing.medium) {
                    // Source track mini info
                    VStack(spacing: AppSpacing.small) {
                        Text("Source")
                            .font(AppFont.caption)
                            .foregroundColor(Color.designTextSecondary)
                        
                        Text("42")
                            .font(AppFont.counterMedium)
                            .foregroundColor(Color.designPrimary)
                        
                        Text("plays")
                            .font(AppFont.caption)
                            .foregroundColor(Color.designTextSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Arrow and difference
                    VStack(spacing: 4) {
                        Image(systemName: "arrow.right")
                            .font(AppFont.iconMedium)
                            .foregroundColor(Color.designTextSecondary)
                        
                        Text("+17")
                            .font(AppFont.caption)
                            .foregroundColor(Color.designSecondary)
                    }
                    
                    // Target track mini info
                    VStack(spacing: AppSpacing.small) {
                        Text("Target")
                            .font(AppFont.caption)
                            .foregroundColor(Color.designTextSecondary)
                        
                        Text("25")
                            .font(AppFont.counterMedium)
                            .foregroundColor(Color.designSecondary)
                        
                        Text("plays")
                            .font(AppFont.caption)
                            .foregroundColor(Color.designTextSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }
                
                // Action Previews
                Divider()
                    .background(Color.designTextTertiary)
                
                VStack(spacing: AppSpacing.small) {
                    HStack {
                        Text("Match:")
                            .font(AppFont.subheadline)
                            .foregroundColor(Color.designTextSecondary)
                        
                        Spacer()
                        
                        Text("25 → 42")
                            .font(AppFont.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Color.designPrimary)
                    }
                    
                    HStack {
                        Text("Add:")
                            .font(AppFont.subheadline)
                            .foregroundColor(Color.designTextSecondary)
                        
                        Spacer()
                        
                        Text("25 → 67")
                            .font(AppFont.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Color.designSecondary)
                    }
                }
            }
        }
    }
    
    private var mockActionButtons: some View {
        VStack(spacing: AppSpacing.small) {
            HStack(spacing: AppSpacing.medium) {
                // Match Play Count Button
                AppPrimaryButton(
                    "Match",
                    isEnabled: mockButtonsEnabled
                ) { }
                
                // Add Play Count Button
                AppSecondaryButton(
                    "Add",
                    isEnabled: mockButtonsEnabled
                ) { }
            }
            .appPadding(.horizontal)
        }
        .padding(.bottom, AppSpacing.medium)
        .background(Color.designBackground)
    }
    
    private var mockButtonsEnabled: Bool {
        scenario == .successState
    }
    
    private var mockSourcePlayCount: String {
        switch scenario {
        case .sourceFewerPlays: return "25 plays"
        case .samePlayCount: return "30 plays"
        case .sameSong: return "35 plays"
        default: return "42 plays"
        }
    }
    
    private var mockTargetPlayCount: String {
        switch scenario {
        case .sourceFewerPlays: return "42 plays"
        case .samePlayCount: return "30 plays"
        case .sameSong: return "35 plays"
        default: return "25 plays"
        }
    }
}

// Mock Music Picker for Previews
struct MockMusicPickerView: View {
    let title: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: AppSpacing.large) {
                Text("Mock Music Library")
                    .font(AppFont.title2)
                    .foregroundColor(Color.designTextPrimary)
                
                Text("This is a preview placeholder")
                    .font(AppFont.body)
                    .foregroundColor(Color.designTextSecondary)
                
                Spacer()
            }
            .padding()
            .background(Color.designBackground)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct MockMainTabView: View {
    let scenario: PreviewScenario
    
    init(scenario: PreviewScenario = .successState) {
        self.scenario = scenario
    }
    
    var body: some View {
        TabView {
            MockContentView(scenario: scenario)
                .tabItem {
                    Image(systemName: "music.note")
                        .accessibilityLabel("Music Repeater")
                    Text("Repeater")
                        .font(AppFont.caption)
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                        .accessibilityLabel("Settings")
                    Text("Settings")
                        .font(AppFont.caption)
                }
        }
        .accentColor(Color.designPrimary)
        .background(Color.designBackground)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // 1. No tracks selected
            MockMainTabView(scenario: .noTracksSelected)
                .previewDisplayName("No Tracks Selected")
            
            // 2. Only source track selected
            MockMainTabView(scenario: .onlySourceSelected)
                .previewDisplayName("Only Source Selected")
            
            // 3. Same song selected (warning)
            MockMainTabView(scenario: .sameSong)
                .previewDisplayName("Same Song Warning")
            
            // 4. Source has fewer plays (warning)
            MockMainTabView(scenario: .sourceFewerPlays)
                .previewDisplayName("Source Fewer Plays Warning")
            
            // 5. Same play count (warning)
            MockMainTabView(scenario: .samePlayCount)
                .previewDisplayName("Same Play Count Warning")
            
            // 6. Success state - source has more plays
            MockMainTabView(scenario: .successState)
                .previewDisplayName("Success State")
        }
    }
}

enum PreviewScenario {
    case noTracksSelected
    case onlySourceSelected
    case sameSong
    case sourceFewerPlays
    case samePlayCount
    case successState
}
#endif
