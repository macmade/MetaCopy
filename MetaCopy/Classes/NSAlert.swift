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

public extension NSAlert
{
    class func showError( _ error: NSError, window: NSWindow? = nil )
    {
        let title   = error.userInfo[ NSLocalizedDescriptionKey ]             as? String ?? "Error"
        let message = error.userInfo[ NSLocalizedRecoverySuggestionErrorKey ] as? String ?? "An unknown error occured."

        self.showError( title, message: message, window: window )
    }

    class func showError( message: String, window: NSWindow? = nil )
    {
        self.showError( "Error", message: message )
    }

    class func showError( _ title: String, message: String, window: NSWindow? = nil )
    {
        let alert             = NSAlert()
        alert.messageText     = title
        alert.informativeText = message

        alert.addButton( withTitle: "OK" )

        if let window = window
        {
            alert.beginSheetModal( for: window )
        }
        else
        {
            alert.runModal()
        }
    }
}
