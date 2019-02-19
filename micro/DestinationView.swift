//
//  DestinationView.swift
//  micro
//
//  Created by Isom,Grant on 2/13/19.
//  Copyright © 2019 Grant Isom. All rights reserved.
//

import Cocoa
import SpotifyKit

protocol DestinationViewDelegate {
    func recievedSpotifyItem(_ item: SpotifySearchItem)
}

class DestinationView: NSImageView {
    
    var updateView = false
    var artUri = ""
    var imageView: NSImageView?
    var delegate: DestinationViewDelegate?
    
    override func draw(_ dirtyRect: NSRect) {
        registerForDraggedTypes([.URL, .fileURL, .html, .string])
        if updateView {
            if let url = URL(string: artUri) {
                getImage(from: url, completion: { image in
                    DispatchQueue.main.async {
                        self.imageView = nil
                        self.imageView = NSImageView.init(image: image!)
                        self.imageView?.imageScaling = NSImageScaling.scaleAxesIndependently
                        self.imageView?.frame = self.frame
                        self.addSubview(self.imageView!)
                        self.artUri = ""
                    }
                })
            }
            NSColor.selectedControlColor.set()
            let path = NSBezierPath(rect: bounds)
            path.lineWidth = 10.0
            path.stroke()
        }
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if sender.draggingPasteboard.types?.contains(.html) ?? false {
            self.updateView = true
            self.needsDisplay = true
            return .copy
        }
        return NSDragOperation()
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        if let data = sender.draggingPasteboard.readObjects(forClasses: [NSString.self, NSURL.self, NSAttributedString.self, NSImage.self], options: [NSPasteboard.ReadingOptionKey.urlReadingContentsConformToTypes: ["org.chromium.drag-dummy-type", "dyn.ah62d4rv4gu8yc6durvwwaznwmuuha2pxsvw0e55bsmwca7d3sbwu", "public.url-name", "public.html", "public.utf8-plain-text", "org.chromium.web-custom-data"]]) {
            if let urlString = data.first as? String {
                let spotifyManager = (NSApp.delegate as! AppDelegate).spotifyManager
                let url = URL(string: urlString)
                if let type = url?.pathComponents[1], let uri = url?.pathComponents.last {
                    switch type {
                    case "track":
                        spotifyManager.get(SpotifyTrack.self, id: uri) { track in
                            if let album = track.album {
                                self.artUri = album.artUri
                                self.updateView = true
                                self.needsDisplay = true
                                self.delegate?.recievedSpotifyItem(track)
                            }
                        }
                    case "album":
                        spotifyManager.get(SpotifyAlbum.self, id: uri) { album in
                            self.artUri = album.artUri
                            self.updateView = true
                            self.needsDisplay = true
                            self.delegate?.recievedSpotifyItem(album)
                        }
                    case "artist":
                        spotifyManager.get(SpotifyArtist.self, id: uri) { artist in
                            self.artUri = artist.artUri
                            self.updateView = true
                            self.needsDisplay = true
                            self.delegate?.recievedSpotifyItem(artist)
                        }
                    case "user":
                        spotifyManager.get(SpotifyPlaylist.self, id: uri) { playlist in
                            self.artUri = playlist.artUri
                            self.updateView = true
                            self.needsDisplay = true
                            self.delegate?.recievedSpotifyItem(playlist)
                        }
                    default:
                        return false
                    }
                }
            }
            
        } else {
            return false
        }
        return true
    }
    
    func getImage(from url: URL, completion: @escaping (NSImage?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            let httpResponse = response as! HTTPURLResponse
            if let data = data, error == nil, httpResponse.statusCode == 200 {
                completion(NSImage(data: data))
            }
        }.resume()
    }
    
    override func draggingEnded(_ sender: NSDraggingInfo) {
        updateView = false
        needsDisplay = true
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        updateView = false
        needsDisplay = true
    }
    
}
