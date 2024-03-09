#if canImport(AppKit)
import Foundation
import SwiftUI

public protocol SettingsPaneConvertible {
    func asSettingsPane() -> SettingsPane
}

public struct Pane<Content: View>: View, SettingsPaneConvertible {
    let identifier: NSToolbarItem.Identifier
    let title: String
    let toolbarIcon: NSImage
    let tooltip: String?
    let content: Content

    public init(
        identifier: NSToolbarItem.Identifier,
        title: String,
        toolbarIcon: NSImage,
        tooltip: String? = nil,
        contentView: () -> Content
    ) {
        self.identifier = identifier
        self.title = title
        self.toolbarIcon = toolbarIcon
        self.tooltip = tooltip
        self.content = contentView()
    }

    public var body: some View { content }

    public func asSettingsPane() -> SettingsPane {
        PaneHostingController(pane: self)
    }
}


public protocol SettingsPane: NSViewController {
    var paneIdentifier: NSToolbarItem.Identifier { get }
    var paneTitle: String { get }
    var toolbarItemIcon: NSImage { get }
    var tooltip: String? { get }
}

internal final class PaneHostingController<Content: View>: NSHostingController<Content>, SettingsPane {
    let paneIdentifier: NSToolbarItem.Identifier
    let paneTitle: String
    let toolbarItemIcon: NSImage
    let tooltip: String?

    private init(
        identifier: NSToolbarItem.Identifier,
        title: String,
        toolbarIcon: NSImage,
        tooltip: String?,
        content: Content
    ) {
        self.paneIdentifier = identifier
        self.paneTitle = title
        self.toolbarItemIcon = toolbarIcon
        self.tooltip = tooltip
        super.init(rootView: content)
    }

    convenience init(pane: Pane<Content>) {
        self.init(
            identifier: pane.identifier,
            title: pane.title,
            toolbarIcon: pane.toolbarIcon,
            tooltip: pane.tooltip,
            content: pane.content
        )
    }

    @available(*, unavailable)
    @objc
    dynamic required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
#endif
