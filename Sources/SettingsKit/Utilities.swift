import Cocoa
import SwiftUI

extension View {
    /**
    Equivalent to `.eraseToAnyPublisher()` from the Combine framework.
    */
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}

extension NSWindow.FrameAutosaveName {
    static let settings: NSWindow.FrameAutosaveName = "software.micropixels.SettingsKit.Settings"
}

extension View {
    /**
    Applies font and color for a label used for describing a setting.
    */
    public func settingDescription() -> some View {
        font(.system(size: 11.0))
            .foregroundStyle(.secondary)
    }

}
