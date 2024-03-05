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

public class ImageFile: NSObject
{
    @objc public private( set ) dynamic var source:   CGImageSource
    @objc public private( set ) dynamic var metadata: CGImageMetadata?
    @objc public private( set ) dynamic var url:      URL
    @objc public private( set ) dynamic var type:     String
    @objc public private( set ) dynamic var name:     String
    @objc public private( set ) dynamic var image:    NSImage
    @objc public private( set ) dynamic var tags:     [ MetadataTag ] = []

    init?( url: URL, processInfo: Bool )
    {
        guard FileManager.default.fileExists( atPath: url.path( percentEncoded: false ) ),
              let image = NSImage( contentsOf: url )
        else
        {
            return nil
        }

        guard let source = CGImageSourceCreateWithURL( url as NSURL, nil ),
              CGImageSourceGetStatus( source ) == .statusComplete
        else
        {
            return nil
        }

        guard let type = CGImageSourceGetType( source )
        else
        {
            return nil
        }

        self.source   = source
        self.metadata = CGImageSourceCopyMetadataAtIndex( source, 0, nil )
        self.type     = type as String
        self.url      = url
        self.name     = url.lastPathComponent
        self.image    = image

        if processInfo, let metadata = self.metadata
        {
            self.tags = MetadataTag.tags( for: metadata )
        }
    }
}
