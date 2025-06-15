import SwiftUI

struct ActionButtonGroup: View {
    let buttons: [ActionButton]
    let layout: ButtonLayout
    let spacing: CGFloat
    let isEnabled: Bool
    
    struct ActionButton {
        let title: String
        let subtitle: String?
        let style: ButtonStyle
        let isEnabled: Bool
        let action: () -> Void
        
        enum ButtonStyle {
            case primary
            case secondary
            case destructive
            case outline
            
            var backgroundColor: Color {
                switch self {
                case .primary: return Color.designPrimary
                case .secondary: return Color.designSecondary
                case .destructive: return Color.designError
                case .outline: return Color.clear
                }
            }
            
            var foregroundColor: Color {
                switch self {
                case .primary, .secondary, .destructive: return .white
                case .outline: return Color.designPrimary
                }
            }
            
            var borderColor: Color? {
                switch self {
                case .outline: return Color.designPrimary
                default: return nil
                }
            }
        }
        
        init(
            title: String,
            subtitle: String? = nil,
            style: ButtonStyle = .primary,
            isEnabled: Bool = true,
            action: @escaping () -> Void
        ) {
            self.title = title
            self.subtitle = subtitle
            self.style = style
            self.isEnabled = isEnabled
            self.action = action
        }
    }
    
    enum ButtonLayout {
        case horizontal     // Side by side
        case vertical      // Stacked
        case grid(columns: Int)  // Grid layout
        
        var axis: Axis {
            switch self {
            case .horizontal: return .horizontal
            case .vertical, .grid: return .vertical
            }
        }
    }
    
    init(
        buttons: [ActionButton],
        layout: ButtonLayout = .horizontal,
        spacing: CGFloat = AppSpacing.medium,
        isEnabled: Bool = true
    ) {
        self.buttons = buttons
        self.layout = layout
        self.spacing = spacing
        self.isEnabled = isEnabled
    }
    
    var body: some View {
        Group {
            switch layout {
            case .horizontal:
                horizontalLayout
            case .vertical:
                verticalLayout
            case .grid(let columns):
                gridLayout(columns: columns)
            }
        }
    }
    
    // MARK: - Layout Implementations
    
    private var horizontalLayout: some View {
        HStack(spacing: spacing) {
            ForEach(buttons.indices, id: \.self) { index in
                ActionButtonView(button: buttons[index], groupIsEnabled: isEnabled)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var verticalLayout: some View {
        VStack(spacing: spacing) {
            ForEach(buttons.indices, id: \.self) { index in
                ActionButtonView(button: buttons[index], groupIsEnabled: isEnabled)
            }
        }
    }
    
    private func gridLayout(columns: Int) -> some View {
        let gridItems = Array(repeating: GridItem(.flexible()), count: columns)
        
        return LazyVGrid(columns: gridItems, spacing: spacing) {
            ForEach(buttons.indices, id: \.self) { index in
                ActionButtonView(button: buttons[index], groupIsEnabled: isEnabled)
            }
        }
    }
}

// MARK: - Action Button View

private struct ActionButtonView: View {
    let button: ActionButtonGroup.ActionButton
    let groupIsEnabled: Bool
    
    private var isEnabled: Bool {
        return groupIsEnabled && button.isEnabled
    }
    
    var body: some View {
        Button(action: button.action) {
            VStack(spacing: 4) {
                Text(button.title)
                    .font(AppFont.headline)
                
                if let subtitle = button.subtitle {
                    Text(subtitle)
                        .font(AppFont.caption)
                }
            }
            .foregroundColor(isEnabled ? button.style.foregroundColor : Color.designTextTertiary)
            .frame(maxWidth: .infinity)
            .padding(AppSpacing.medium)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.large)
                    .fill(isEnabled ? button.style.backgroundColor : Color.designTextTertiary)
                    .if(button.style.borderColor != nil) { shape in
                        shape.stroke(button.style.borderColor!, lineWidth: 1)
                    }
                    .appShadow(.light)
            )
        }
        .disabled(!isEnabled)
        .scaleEffect(isEnabled ? 1.0 : 0.95)
        .animation(AppAnimation.quick, value: isEnabled)
    }
}

// MARK: - Predefined Button Groups

extension ActionButtonGroup {
    // MARK: - Music Matcher Actions
    
    static func musicMatcherActions(
        canPerformActions: Bool,
        onMatch: @escaping () -> Void,
        onAdd: @escaping () -> Void
    ) -> ActionButtonGroup {
        ActionButtonGroup(
            buttons: [
                ActionButton(
                    title: "Match",
                    style: .primary,
                    isEnabled: canPerformActions,
                    action: onMatch
                ),
                ActionButton(
                    title: "Add",
                    style: .secondary,
                    isEnabled: canPerformActions,
                    action: onAdd
                )
            ],
            layout: .horizontal
        )
    }
    
    // MARK: - Playback Controls
    
    static func playbackControls(
        isPlaying: Bool,
        isProcessing: Bool,
        onPlayPause: @escaping () -> Void,
        onStop: @escaping () -> Void
    ) -> ActionButtonGroup {
        ActionButtonGroup(
            buttons: [
                ActionButton(
                    title: isPlaying ? "Pause" : "Resume",
                    style: .primary,
                    isEnabled: isProcessing,
                    action: onPlayPause
                ),
                ActionButton(
                    title: "Stop",
                    style: .destructive,
                    isEnabled: isProcessing,
                    action: onStop
                )
            ],
            layout: .horizontal
        )
    }
    
    // MARK: - Scan Actions
    
    static func scanActions(
        onStartScan: @escaping () -> Void,
        onViewIgnored: (() -> Void)? = nil
    ) -> ActionButtonGroup {
        var buttons = [
            ActionButton(
                title: "Start Scan",
                subtitle: "Find duplicate songs",
                style: .primary,
                action: onStartScan
            )
        ]
        
        if let onViewIgnored = onViewIgnored {
            buttons.append(
                ActionButton(
                    title: "View Ignored",
                    subtitle: "Manage ignored items",
                    style: .outline,
                    action: onViewIgnored
                )
            )
        }
        
        return ActionButtonGroup(
            buttons: buttons,
            layout: .vertical
        )
    }
    
    // MARK: - Selection Actions
    
    static func selectionActions(
        onSelectAsSource: @escaping () -> Void,
        onSelectAsTarget: @escaping () -> Void,
        onRemove: (() -> Void)? = nil
    ) -> ActionButtonGroup {
        var buttons = [
            ActionButton(
                title: "Source",
                style: .primary,
                action: onSelectAsSource
            ),
            ActionButton(
                title: "Target",
                style: .secondary,
                action: onSelectAsTarget
            )
        ]
        
        if let onRemove = onRemove {
            buttons.append(
                ActionButton(
                    title: "Remove",
                    style: .destructive,
                    action: onRemove
                )
            )
        }
        
        return ActionButtonGroup(
            buttons: buttons,
            layout: .horizontal
        )
    }
    
    // MARK: - Management Actions
    
    static func managementActions(
        onIgnore: @escaping () -> Void,
        onRestore: (() -> Void)? = nil,
        onDelete: (() -> Void)? = nil
    ) -> ActionButtonGroup {
        var buttons = [
            ActionButton(
                title: "Ignore",
                style: .outline,
                action: onIgnore
            )
        ]
        
        if let onRestore = onRestore {
            buttons.append(
                ActionButton(
                    title: "Restore",
                    style: .secondary,
                    action: onRestore
                )
            )
        }
        
        if let onDelete = onDelete {
            buttons.append(
                ActionButton(
                    title: "Delete",
                    style: .destructive,
                    action: onDelete
                )
            )
        }
        
        return ActionButtonGroup(
            buttons: buttons,
            layout: .horizontal
        )
    }
}

// MARK: - Fixed Action Buttons Container

struct FixedActionButtonsContainer<Content: View>: View {
    let content: Content
    let buttons: ActionButtonGroup
    let showDivider: Bool
    
    init(
        buttons: ActionButtonGroup,
        showDivider: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.buttons = buttons
        self.showDivider = showDivider
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Main content
            content
            
            // Fixed buttons section
            VStack(spacing: AppSpacing.small) {
                if showDivider {
                    Divider()
                        .background(Color.designTextTertiary)
                }
                
                buttons
                    .padding(.horizontal, AppSpacing.medium)
            }
            .padding(.bottom, AppSpacing.medium)
            .background(
                Color.designBackground
                    .ignoresSafeArea(edges: .bottom)
            )
        }
    }
}

// MARK: - Floating Action Button

struct FloatingActionButton: View {
    let icon: String
    let title: String?
    let color: Color
    let position: FloatingPosition
    let action: () -> Void
    
    enum FloatingPosition {
        case bottomTrailing
        case bottomLeading
        case bottomCenter
        
        var alignment: Alignment {
            switch self {
            case .bottomTrailing: return .bottomTrailing
            case .bottomLeading: return .bottomLeading
            case .bottomCenter: return .bottom
            }
        }
    }
    
    init(
        icon: String,
        title: String? = nil,
        color: Color = Color.designPrimary,
        position: FloatingPosition = .bottomTrailing,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.color = color
        self.position = position
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.small) {
                Image(systemName: icon)
                    .font(AppFont.iconMedium)
                
                if let title = title {
                    Text(title)
                        .font(AppFont.subheadline)
                        .fontWeight(.medium)
                }
            }
            .foregroundColor(.white)
            .padding(title != nil ? AppSpacing.medium : AppSpacing.small)
            .background(
                Capsule()
                    .fill(color)
                    .appShadow(.medium)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#if DEBUG
struct ActionButtonGroup_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            // Horizontal layout
            ActionButtonGroup.musicMatcherActions(
                canPerformActions: true,
                onMatch: {},
                onAdd: {}
            )
            
            // Vertical layout
            ActionButtonGroup.scanActions(
                onStartScan: {},
                onViewIgnored: {}
            )
            
            // Grid layout
            ActionButtonGroup(
                buttons: [
                    ActionButtonGroup.ActionButton(title: "Option 1", action: {}),
                    ActionButtonGroup.ActionButton(title: "Option 2", action: {}),
                    ActionButtonGroup.ActionButton(title: "Option 3", action: {}),
                    ActionButtonGroup.ActionButton(title: "Option 4", action: {})
                ],
                layout: .grid(columns: 2)
            )
            
            // Floating action button
            HStack {
                Spacer()
                FloatingActionButton(
                    icon: "plus",
                    title: "Add",
                    action: {}
                )
            }
        }
        .padding()
        .background(Color.designBackground)
    }
}
#endif
