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

@objc( TagValue )
public class TagValue: ValueTransformer
{
    public override class func transformedValueClass() -> AnyClass
    {
        NSString.self
    }

    public override class func allowsReverseTransformation() -> Bool
    {
        false
    }

    public override func transformedValue( _ value: Any? ) -> Any?
    {
        guard let tag = value as? MetadataTag
        else
        {
            return nil
        }

        return self.description( for: tag.value )
    }

    private func description( for value: Any? ) -> String
    {
        if let value = value as? String, value.isEmpty == false
        {
            return value
        }
        else if let value = value as? NSNumber
        {
            return value.description
        }
        else if let value = value as? [ Any ], value.isEmpty == false
        {
            let description = value.map { self.description( for: $0 ) }.joined( separator: ", " )

            return "[ \( description ) ]"
        }
        else if let value = value as? [ AnyHashable: Any ], value.isEmpty == false
        {
            let description = value.map
            {
                let key   = self.description( for: $0.key )
                let value = self.description( for: $0.value )

                return "\( key ): \( value )"
            }
            .joined( separator: ", " )

            return "[ \( description ) ]"
        }
        else if let value = value as? CFTypeRef
        {
            if CFGetTypeID( value ) == CGImageMetadataTagGetTypeID()
            {
                return self.transformedValue( MetadataTag( tag: value as! CGImageMetadataTag ) ) as? String ?? "--"
            }
        }

        return "--"
    }
}
