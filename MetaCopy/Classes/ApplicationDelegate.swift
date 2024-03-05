/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2023, Jean-David Gadina - www.xs-labs.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the Software), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 ******************************************************************************/

import Cocoa

@main
class ApplicationDelegate: NSObject, NSApplicationDelegate
{
    private var controllers: [ MainWindowController ] = []

    @objc public private( set ) dynamic var aboutController = AboutWindowController()

    func applicationDidFinishLaunching( _ notification: Notification )
    {
        self.openNewWindow( restore: true )

        NotificationCenter.default.addObserver( forName: NSWindow.willCloseNotification, object: nil, queue: nil )
        {
            notification in self.controllers.removeAll
            {
                $0.window === notification.object as? NSWindow
            }
        }
    }

    func applicationWillTerminate( _ notification: Notification )
    {}

    func applicationSupportsSecureRestorableState( _ app: NSApplication ) -> Bool
    {
        false
    }

    @IBAction
    public func showAboutWindow( _ sender: Any? )
    {
        guard let window = self.aboutController.window
        else
        {
            return
        }

        if window.isVisible == false
        {
            window.center()
        }

        window.makeKeyAndOrderFront( sender )
    }

    @IBAction
    public func invertAppearance( _ sender: Any? )
    {
        switch NSApp.effectiveAppearance.name
        {
            case .accessibilityHighContrastAqua:         NSApp.appearance = NSAppearance( named: .accessibilityHighContrastDarkAqua )
            case .accessibilityHighContrastDarkAqua:     NSApp.appearance = NSAppearance( named: .accessibilityHighContrastAqua )
            case .accessibilityHighContrastVibrantLight: NSApp.appearance = NSAppearance( named: .accessibilityHighContrastVibrantDark )
            case .accessibilityHighContrastVibrantDark:  NSApp.appearance = NSAppearance( named: .accessibilityHighContrastVibrantLight )
            case .aqua:                                  NSApp.appearance = NSAppearance( named: .darkAqua )
            case .darkAqua:                              NSApp.appearance = NSAppearance( named: .aqua )
            case .vibrantLight:                          NSApp.appearance = NSAppearance( named: .vibrantDark )
            case .vibrantDark:                           NSApp.appearance = NSAppearance( named: .vibrantLight )

            default: break
        }
    }

    @IBAction
    public func newDocument( _ sender: Any? )
    {
        self.openNewWindow( restore: false )
    }

    private func openNewWindow( restore: Bool )
    {
        let controller = MainWindowController( restore: restore )

        controller.window?.makeKeyAndOrderFront( nil )
        self.controllers.append( controller )
    }
}
