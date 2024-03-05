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

import Foundation
import ImageIO

@objc
public class MetadataTag: NSObject
{
    @objc public private( set ) var tag:       CGImageMetadataTag
    @objc public private( set ) var id:        String?
    @objc public private( set ) var namespace: String?
    @objc public private( set ) var prefix:    String?
    @objc public private( set ) var name:      String?
    @objc public private( set ) var value:     CFTypeRef

    @objc public dynamic var selected = true

    public class func tags( for metadata: CGImageMetadata ) -> [ MetadataTag ]
    {
        var info = [ MetadataTag ]()

        CGImageMetadataEnumerateTagsUsingBlock( metadata, nil, nil )
        {
            if let tag = MetadataTag( id: $0 as String, tag: $1 )
            {
                info.append( tag )
            }

            return true
        }

        return info
    }

    private init?( id: String, tag: CGImageMetadataTag )
    {
        guard let value = CGImageMetadataTagCopyValue( tag )
        else
        {
            return nil
        }

        self.tag       = tag
        self.id        = id
        self.prefix    = CGImageMetadataTagCopyPrefix( tag )    as String?
        self.namespace = CGImageMetadataTagCopyNamespace( tag ) as String?
        self.name      = CGImageMetadataTagCopyName( tag )      as String? ?? id
        self.value     = value
    }

    public init?( tag: CGImageMetadataTag )
    {
        guard let value = CGImageMetadataTagCopyValue( tag )
        else
        {
            return nil
        }

        self.tag       = tag
        self.id        = nil
        self.prefix    = CGImageMetadataTagCopyPrefix( tag )    as String?
        self.namespace = CGImageMetadataTagCopyNamespace( tag ) as String?
        self.name      = CGImageMetadataTagCopyName( tag )      as String?
        self.value     = value
    }
}
