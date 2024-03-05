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

public class MainWindowController: NSWindowController, NSTableViewDelegate, NSTableViewDataSource
{
    @objc private dynamic var sourceFile: ImageFile?
    {
        didSet
        {
            UserDefaults.standard.setValue( self.sourceFile?.url.path( percentEncoded: false ), forKey: "source" )
            self.updateSelection()

            self.tagSelectionObservers = self.sourceFile?.tags.map
            {
                $0.observe( \.selected )
                {
                    [ weak self ] _, _ in self?.updateSelection()
                }
            }
            ?? []
        }
    }

    @objc private dynamic var destinationFiles: [ ImageFile ] = []
    {
        didSet
        {
            UserDefaults.standard.setValue( self.destinationFiles.map { $0.url.path( percentEncoded: false ) }, forKey: "destination" )
        }
    }

    @objc private dynamic var allTagsSelected = false
    @objc private dynamic var processing      = false

    private var restore:               Bool
    private var tagSelectionObservers: [ NSKeyValueObservation ] = []

    @IBOutlet private var destinationFilesController: NSArrayController?
    @IBOutlet private var tagsController:             NSArrayController?
    @IBOutlet private var destinationFilesTableView:  NSTableView?
    @IBOutlet private var tagsTableView:              NSTableView?
    @IBOutlet private var destinationView:            BackgroundView?
    @IBOutlet private var sourceView:                 BackgroundView?

    public init( restore: Bool )
    {
        self.restore = restore

        super.init( window: nil )
    }

    required init?( coder: NSCoder )
    {
        nil
    }

    public override var windowNibName: NSNib.Name?
    {
        "MainWindowController"
    }

    public override func windowDidLoad()
    {
        super.windowDidLoad()

        if self.restore
        {
            if let source = UserDefaults.standard.string( forKey: "source" )
            {
                self.sourceFile = ImageFile( url: URL( filePath: source ), processInfo: true )
            }

            if let destination = UserDefaults.standard.value( forKey: "destination" ) as? [ String ]
            {
                self.destinationFiles = destination.compactMap { ImageFile( url: URL( filePath: $0 ), processInfo: false ) }
            }
        }

        self.destinationFilesController?.sortDescriptors = [ NSSortDescriptor( key: "name", ascending: true ) ]
        self.tagsController?.sortDescriptors             =
            [
                NSSortDescriptor( key: "prefix", ascending: true, selector: #selector( NSString.localizedCaseInsensitiveCompare( _: ) ) ),
                NSSortDescriptor( key: "name",   ascending: true, selector: #selector( NSString.localizedCaseInsensitiveCompare( _: ) ) ),
            ]

        self.destinationFilesTableView?.sizeLastColumnToFit()
        self.tagsTableView?.sizeLastColumnToFit()
        self.updateSelection()

        self.sourceView?.onDrag      = { [ weak self ] in self?.onSourceDrag( info: $0 ) ?? .copy }
        self.destinationView?.onDrag = { [ weak self ] in self?.onDestinationDrag( info: $0 ) ?? .copy }
        self.sourceView?.onDrop      = { [ weak self ] in self?.onSourceDrop( info: $0 ) ?? false }
        self.destinationView?.onDrop = { [ weak self ] in self?.onDestinationDrop( info: $0 ) ?? false }
    }

    public func tableView( _ tableView: NSTableView, shouldSelectRow row: Int ) -> Bool
    {
        false
    }

    private func onSourceDrag( info: NSDraggingInfo ) -> NSDragOperation
    {
        Helper.images( in: info.draggingPasteboard, allowRaw: true ).count == 1 ? .copy : []
    }

    private func onDestinationDrag( info: NSDraggingInfo ) -> NSDragOperation
    {
        Helper.images( in: info.draggingPasteboard, allowRaw: false ).count > 0 ? .copy : []
    }

    private func onSourceDrop( info: NSDraggingInfo ) -> Bool
    {
        self.window?.makeKeyAndOrderFront( nil )

        let images = Helper.images( in: info.draggingPasteboard, allowRaw: true )

        if images.count == 1, let image = images.first
        {
            self.setSourceFile( url: image )

            return true
        }

        return false
    }

    private func onDestinationDrop( info: NSDraggingInfo ) -> Bool
    {
        self.window?.makeKeyAndOrderFront( nil )

        let images = Helper.images( in: info.draggingPasteboard, allowRaw: false )

        if images.count > 0
        {
            self.setDestinationFiles( urls: images )

            return true
        }

        return false
    }

    private func setSourceFile( url: URL )
    {
        self.processing = true

        DispatchQueue.global( qos: .userInitiated ).async
        {
            let source = ImageFile( url: url, processInfo: true )

            DispatchQueue.main.async
            {
                if source == nil
                {
                    NSAlert.showError( message: "Cannot read the source image. Please make sure it is in a supported image format.", window: self.window )
                }
                else if let source = source, source.tags.isEmpty
                {
                    NSAlert.showError( message: "The source image does not appear to contain any metadata.", window: self.window )
                }

                self.processing = false
                self.sourceFile = source
            }
        }
    }

    private func setDestinationFiles( urls: [ URL ] )
    {
        self.processing = true

        DispatchQueue.global( qos: .userInitiated ).async
        {
            let files = Helper.images( in: urls, allowRaw: false ).compactMap { ImageFile( url: $0, processInfo: false ) }

            DispatchQueue.main.async
            {
                if files.isEmpty
                {
                    NSAlert.showError( message: "No destination image was read.", window: self.window )
                }

                self.processing       = false
                self.destinationFiles = files
            }
        }
    }

    @IBAction
    public func selectSource( _ sender: Any? )
    {
        guard let window = self.window
        else
        {
            NSSound.beep()

            return
        }

        let panel                           = NSOpenPanel()
        panel.canChooseFiles                = true
        panel.canChooseDirectories          = false
        panel.canDownloadUbiquitousContents = true
        panel.allowsMultipleSelection       = false
        panel.allowedContentTypes           = [ .image ]

        panel.beginSheetModal( for: window )
        {
            if $0 == .OK, let url = panel.url
            {
                self.setSourceFile( url: url )
            }
        }
    }

    @IBAction
    public func selectDestination( _ sender: Any? )
    {
        guard let window = self.window
        else
        {
            NSSound.beep()

            return
        }

        let panel                           = NSOpenPanel()
        panel.canChooseFiles                = true
        panel.canChooseDirectories          = true
        panel.canDownloadUbiquitousContents = true
        panel.allowsMultipleSelection       = true
        panel.allowedContentTypes           = [ .image ]

        panel.beginSheetModal( for: window )
        {
            if $0 == .OK
            {
                self.setDestinationFiles( urls: panel.urls )
            }
        }
    }

    @IBAction
    private func selectAllTags( _ sender: Any? )
    {
        let select = self.allTagsSelected ? true : false

        self.sourceFile?.tags.forEach
        {
            $0.selected = select
        }
    }

    @IBAction
    private func clearSource( _ sender: Any? )
    {
        self.sourceFile = nil
    }

    @IBAction
    private func clearDestination( _ sender: Any? )
    {
        self.destinationFiles = []
    }

    private func updateSelection()
    {
        guard let source = self.sourceFile
        else
        {
            self.allTagsSelected = false

            return
        }

        let selected = source.tags.reduce( 0 )
        {
            $0 + ( $1.selected ? 1 : 0 )
        }

        if selected == source.tags.count
        {
            self.allTagsSelected = true
        }
        else
        {
            self.allTagsSelected = false
        }
    }

    @IBAction
    private func processImages( _ sender: Any? )
    {
        guard let source = self.sourceFile, self.destinationFiles.isEmpty == false
        else
        {
            NSSound.beep()

            return
        }

        self.processing = true

        DispatchQueue.global( qos: .userInitiated ).async
        {
            defer
            {
                DispatchQueue.main.async
                {
                    self.processing = false
                }
            }

            do
            {
                try Helper.copyMetadata( from: source, to: self.destinationFiles )
            }
            catch let error
            {
                DispatchQueue.main.async
                {
                    NSAlert.showError( error as NSError )
                }
            }
        }
    }
}
