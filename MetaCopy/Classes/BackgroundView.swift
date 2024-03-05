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

public class BackgroundView: NSView
{
    @objc private dynamic var dragging = false
    {
        didSet
        {
            self.needsDisplay = true
        }
    }

    public var onDrag: ( ( NSDraggingInfo ) -> NSDragOperation )?
    public var onDrop: ( ( NSDraggingInfo ) -> Bool )?

    public override init( frame: NSRect )
    {
        super.init( frame: frame )
        self.registerForDraggedTypes( [ .fileURL ] )
    }

    public required init?( coder: NSCoder )
    {
        super.init( coder: coder )
        self.registerForDraggedTypes( [ .fileURL ] )
    }

    public override func draggingEntered( _ sender: NSDraggingInfo ) -> NSDragOperation
    {
        let operation = self.onDrag?( sender ) ?? []
        self.dragging = operation.isEmpty == false

        return operation
    }

    public override func draggingExited( _ sender: NSDraggingInfo? )
    {
        self.dragging = false
    }

    public override func performDragOperation( _ sender: NSDraggingInfo ) -> Bool
    {
        self.dragging = false

        return self.onDrop?( sender ) ?? false
    }

    public override func draw( _ rect: NSRect )
    {
        let path = NSBezierPath( roundedRect: self.bounds, xRadius: 10, yRadius: 10 )

        if self.effectiveAppearance.isDark
        {
            NSColor.white.withAlphaComponent( 0.1 ).setFill()
        }
        else
        {
            NSColor.black.withAlphaComponent( 0.1 ).setFill()
        }

        path.fill()

        if self.dragging
        {
            path.lineWidth = 1

            NSColor.controlAccentColor.setStroke()
            path.stroke()
        }
    }
}
