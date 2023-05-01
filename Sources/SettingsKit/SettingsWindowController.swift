import Cocoa

public final class SettingsWindowController: NSWindowController {
    private let items: [SettingsPane]
    private var initialTabSelection = true

    init(items: [SettingsPane]) {
        self.items = items
        let window = NSWindow(contentRect: .zero, styleMask: [.closable, .titled], backing: .buffered, defer: false)
        window.setFrameAutosaveName(.settings)
        super.init(window: window)
        configureToolbar()

        window.center()
    }

    public convenience init(panes: [SettingsPaneConvertible]) {
        self.init(items: panes.map { $0.asSettingsPane() })
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func configureToolbar() {
        guard let window = window else { return }
        let toolbar = NSToolbar(identifier: .init("software.micropixels.SettingsKit.Settings.Toolbar"))
        toolbar.allowsUserCustomization = false
        toolbar.displayMode = .iconAndLabel
        toolbar.delegate = self
        window.toolbar = toolbar
        window.toolbarStyle = .preference
    }

    public func show(pane identifier: NSToolbarItem.Identifier? = nil) {
        NSApp.activate(ignoringOtherApps: true)
        showWindow(self)
        if let identifier, let item = items.first(where: { $0.paneIdentifier == identifier }) {
            self.setContentViewForItem(item, animate: !initialTabSelection)
        } else if let item = items.first {
            self.setContentViewForItem(item, animate: false)
            window?.toolbar?.selectedItemIdentifier = item.paneIdentifier
        }
        initialTabSelection = false
    }

    private func setContentViewForItem(_ item: SettingsPane, animate: Bool = true) {
        guard let window = window else { return }
        window.title = item.paneTitle
        window.contentView = nil
        let size = item.view.fittingSize
        let contentRect = NSRect(x: 0, y: 0, width: size.width, height: size.height)
        let contentFrame = window.frameRect(forContentRect: contentRect)
        let toolbarHeight = window.frame.size.height - contentFrame.size.height

        window.setFrameUsingName(.settings)

        let newOrigin = NSPoint(x: window.frame.origin.x, y: window.frame.origin.y + toolbarHeight)
        let newFrame = NSRect(origin: newOrigin, size: contentFrame.size)
        window.setFrame(newFrame, display: true, animate: animate)
        window.contentView = item.view
        window.setFrameAutosaveName(.settings)
    }
}

extension SettingsWindowController: NSToolbarDelegate {
    public func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        items.map { $0.paneIdentifier }
    }

    public func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        guard let item = items.first(where: { $0.paneIdentifier == itemIdentifier }) else { return nil }
        return nsToolbarItemFor(item)
    }

    public func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        items.map { $0.paneIdentifier }
    }

    public func toolbarSelectableItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        items.map { $0.paneIdentifier }
    }

    private func nsToolbarItemFor(_ item: SettingsPane) -> NSToolbarItem {
        let toolbarItem = NSToolbarItem(itemIdentifier: item.paneIdentifier)
        toolbarItem.image = item.toolbarItemIcon
        toolbarItem.label = item.paneTitle
        toolbarItem.toolTip = item.tooltip
        toolbarItem.autovalidates = false
        toolbarItem.target = self
        toolbarItem.action = #selector(changeContentView(_:))
        return toolbarItem
    }

    @objc func changeContentView(_ sender: NSToolbarItem) {
        guard let item = items.first(where: { $0.paneIdentifier == sender.itemIdentifier }) else { return }
        setContentViewForItem(item)
    }
}
