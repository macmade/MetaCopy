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
import UniformTypeIdentifiers

public class Helper
{
    private init()
    {}

    public class func isImage( url: URL ) -> Bool
    {
        UTType( filenameExtension: url.pathExtension )?.conforms( to: .image ) ?? false
    }

    public class func isRawImage( url: URL ) -> Bool
    {
        UTType( filenameExtension: url.pathExtension )?.conforms( to: .rawImage ) ?? false
    }

    public class func images( in pasteboard: NSPasteboard, allowRaw: Bool ) -> [ URL ]
    {
        guard let urls = pasteboard.readObjects( forClasses: [ NSURL.self ], options: nil ) as? [ NSURL ]
        else
        {
            return []
        }

        return self.images( in: urls.map { $0 as URL }, allowRaw: allowRaw )
    }

    public class func images( in urls: [ URL ], allowRaw: Bool ) -> [ URL ]
    {
        let images: [ [ URL ] ] = urls.map
        {
            url in

            var isDir = ObjCBool( booleanLiteral: false )

            guard FileManager.default.fileExists( atPath: url.path( percentEncoded: false ), isDirectory: &isDir )
            else
            {
                return []
            }

            if isDir.boolValue
            {
                return FileManager.default.enumerator( atPath: url.path( percentEncoded: false ) )?.compactMap
                {
                    if let component = $0 as? String
                    {
                        let url = url.appendingPathComponent( component )

                        if self.isImage( url: url ), ( allowRaw == true || self.isRawImage( url: url ) == false )
                        {
                            return url
                        }
                    }

                    return nil
                }
                ?? []
            }
            else if self.isImage( url: url ), ( allowRaw == true || self.isRawImage( url: url ) == false )
            {
                return [ url ]
            }
            else
            {
                return []
            }
        }

        return images.flatMap { $0 }
    }

    public class func copyMetadata( from source: ImageFile, to destination: [ ImageFile ] ) throws
    {
        guard let originalMetadata = source.metadata
        else
        {
            throw NSError( message: "No metadata found in source image." )
        }

        guard let metadata = CGImageMetadataCreateMutableCopy( originalMetadata )
        else
        {
            throw NSError( message: "Cannot create a valid metadata container." )
        }

        source.tags.forEach
        {
            if $0.selected == false, let id = $0.id
            {
                CGImageMetadataRemoveTagWithPath( metadata, nil, id as NSString )
            }
        }

        try destination.forEach
        {
            guard let destination = CGImageDestinationCreateWithURL( $0.url as NSURL, $0.type as NSString, 1, nil )
            else
            {
                throw NSError( message: "Cannot open file for writing: \( $0.url.lastPathComponent )" )
            }

            guard let image = CGImageSourceCreateImageAtIndex( $0.source, 0, nil )
            else
            {
                throw NSError( message: "Cannot read destination image: \( $0.url.lastPathComponent )" )
            }

            CGImageDestinationAddImageAndMetadata( destination, image, metadata, nil )

            if CGImageDestinationFinalize( destination ) == false
            {
                throw NSError( message: "Cannot write file: \( $0.url.lastPathComponent )" )
            }
        }
    }
}
