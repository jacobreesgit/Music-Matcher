import SwiftUI

struct TabSelector: View {
    let tabs: [TabItem]
    @Binding var selectedIndex: Int
    let style: TabSelectorStyle
    
    struct TabItem {
        let title: String
        let count: Int?
        let color: Color
        
        init(title: String, count: Int? = nil, color: Color = Color.designPrimary) {
            self.title = title
            self.count = count
            self.color = color
        }
        
        var displayTitle: String {
            if let count = count {
                return "\(title) (\(count))"
            } else {
                return title
            }
        }
    }
    
    enum TabSelectorStyle {
        case underline      // Traditional underline tabs
        case pill          // Pill-style segment control
        case button        // Button-style tabs
        
        var backgroundColor: Color {
            switch self {
            case .underline: return Color.clear
            case .pill: return Color.designBackgroundTertiary
            case .button: return Color.clear
            }
        }
        
        var cornerRadius: CGFloat {
            switch self {
            case .underline: return 0
            case .pill: return AppCornerRadius.large
            case .button: return AppCornerRadius.medium
            }
        }
    }
    
    init(
        tabs: [TabItem],
        selectedIndex: Binding<Int>,
        style: TabSelectorStyle = .underline
    ) {
        self.tabs = tabs
        self._selectedIndex = selectedIndex
        self.style = style
    }
    
    var body: some View {
        Group {
            switch style {
            case .underline:
                underlineTabView
            case .pill:
                pillTabView
            case .button:
                buttonTabView
            }
        }
    }
    
    // MARK: - Underline Tab Style
    private var underlineTabView: some View {
        HStack(spacing: 0) {
            ForEach(tabs.indices, id: \.self) { index in
                Button(action: {
                    withAnimation(AppAnimation.quick) {
                        selectedIndex = index
                    }
                }) {
                    VStack(spacing: 4) {
                        Text(tabs[index].displayTitle)
                            .font(AppFont.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(selectedIndex == index ? tabs[index].color : Color.designTextSecondary)
                        
                        Rectangle()
                            .fill(selectedIndex == index ? tabs[index].color : Color.clear)
                            .frame(height: 2)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    // MARK: - Pill Tab Style
    private var pillTabView: some View {
        HStack(spacing: 2) {
            ForEach(tabs.indices, id: \.self) { index in
                Button(action: {
                    withAnimation(AppAnimation.quick) {
                        selectedIndex = index
                    }
                }) {
                    Text(tabs[index].displayTitle)
                        .font(AppFont.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(selectedIndex == index ? .white : Color.designTextSecondary)
                        .padding(.horizontal, AppSpacing.medium)
                        .padding(.vertical, AppSpacing.small)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                .fill(selectedIndex == index ? tabs[index].color : Color.clear)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: style.cornerRadius)
                .fill(style.backgroundColor)
        )
    }
    
    // MARK: - Button Tab Style
    private var buttonTabView: some View {
        HStack(spacing: AppSpacing.small) {
            ForEach(tabs.indices, id: \.self) { index in
                Button(action: {
                    withAnimation(AppAnimation.quick) {
                        selectedIndex = index
                    }
                }) {
                    HStack(spacing: AppSpacing.xs) {
                        Text(tabs[index].title)
                            .font(AppFont.subheadline)
                            .fontWeight(.medium)
                        
                        if let count = tabs[index].count {
                            Text("\(count)")
                                .font(AppFont.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(selectedIndex == index ? .white.opacity(0.3) : tabs[index].color)
                                )
                        }
                    }
                    .foregroundColor(selectedIndex == index ? .white : tabs[index].color)
                    .padding(.horizontal, AppSpacing.medium)
                    .padding(.vertical, AppSpacing.small)
                    .background(
                        RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                            .fill(selectedIndex == index ? tabs[index].color : Color.clear)
                            .stroke(tabs[index].color, lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

// MARK: - Convenience Initializers

extension TabSelector {
    // Simple string-based tabs
    init(
        titles: [String],
        selectedIndex: Binding<Int>,
        style: TabSelectorStyle = .underline
    ) {
        let tabItems = titles.map { TabItem(title: $0) }
        self.init(tabs: tabItems, selectedIndex: selectedIndex, style: style)
    }
    
    // String and count based tabs
    init(
        titlesWithCounts: [(String, Int)],
        selectedIndex: Binding<Int>,
        colors: [Color] = [Color.designPrimary, Color.designSecondary],
        style: TabSelectorStyle = .underline
    ) {
        let tabItems = titlesWithCounts.enumerated().map { index, item in
            let color = colors.indices.contains(index) ? colors[index] : Color.designPrimary
            return TabItem(title: item.0, count: item.1, color: color)
        }
        self.init(tabs: tabItems, selectedIndex: selectedIndex, style: style)
    }
}

// MARK: - Tab Content View

struct TabContentView<Content: View>: View {
    let tabs: [TabSelector.TabItem]
    @State private var selectedIndex: Int = 0
    let style: TabSelector.TabSelectorStyle
    let content: (Int) -> Content
    
    init(
        tabs: [TabSelector.TabItem],
        style: TabSelector.TabSelectorStyle = .underline,
        @ViewBuilder content: @escaping (Int) -> Content
    ) {
        self.tabs = tabs
        self.style = style
        self.content = content
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab Selector
            TabSelector(
                tabs: tabs,
                selectedIndex: $selectedIndex,
                style: style
            )
            .padding(.horizontal, style == .underline ? 0 : AppSpacing.medium)
            .padding(.top, AppSpacing.medium)
            
            // Tab Content
            content(selectedIndex)
                .animation(.easeInOut(duration: 0.2), value: selectedIndex)
        }
    }
}

// MARK: - Specialized Tab Views

struct SettingsTabSelector: View {
    let ignoredSongsCount: Int
    let ignoredGroupsCount: Int
    @Binding var selectedTab: Int
    
    var body: some View {
        TabSelector(
            tabs: [
                TabSelector.TabItem(
                    title: "Songs",
                    count: ignoredSongsCount,
                    color: Color.designPrimary
                ),
                TabSelector.TabItem(
                    title: "Groups",
                    count: ignoredGroupsCount,
                    color: Color.designSecondary
                )
            ],
            selectedIndex: $selectedTab,
            style: .underline
        )
    }
}

struct FilterTabSelector: View {
    let filters: [String]
    @Binding var selectedFilter: String
    
    var body: some View {
        let selectedIndex = Binding<Int>(
            get: { filters.firstIndex(of: selectedFilter) ?? 0 },
            set: { selectedFilter = filters[$0] }
        )
        
        TabSelector(
            titles: filters,
            selectedIndex: selectedIndex,
            style: .pill
        )
    }
}

// MARK: - Preview
#if DEBUG
struct TabSelector_Previews: PreviewProvider {
    @State static var selectedTab1 = 0
    @State static var selectedTab2 = 0
    @State static var selectedTab3 = 0
    
    static var previews: some View {
        VStack(spacing: 40) {
            // Underline style
            VStack {
                Text("Underline Style")
                    .font(AppFont.headline)
                
                TabSelector(
                    tabs: [
                        TabSelector.TabItem(title: "Songs", count: 5, color: Color.designPrimary),
                        TabSelector.TabItem(title: "Groups", count: 12, color: Color.designSecondary)
                    ],
                    selectedIndex: $selectedTab1,
                    style: .underline
                )
            }
            
            // Pill style
            VStack {
                Text("Pill Style")
                    .font(AppFont.headline)
                
                TabSelector(
                    titles: ["All", "Favorites", "Recent"],
                    selectedIndex: $selectedTab2,
                    style: .pill
                )
            }
            
            // Button style
            VStack {
                Text("Button Style")
                    .font(AppFont.headline)
                
                TabSelector(
                    tabs: [
                        TabSelector.TabItem(title: "Active", count: 8, color: Color.designSuccess),
                        TabSelector.TabItem(title: "Ignored", count: 3, color: Color.designWarning)
                    ],
                    selectedIndex: $selectedTab3,
                    style: .button
                )
            }
        }
        .padding()
        .background(Color.designBackground)
    }
}
#endif
