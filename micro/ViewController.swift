//
//  ViewController.swift
//  micro
//
//  Created by Isom,Grant on 2/13/19.
//  Copyright © 2019 Grant Isom. All rights reserved.
//

import Cocoa
import SpotifyKit

class ViewController: NSViewController {

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var albumImageView: DestinationView!
    var items: [SpotifySearchItem]!
    let itemCellIdentifier = "itemCellView"
    let typeCellIdentifier = "typeCellView"
    let sharedByCellIdentifier = "sharedCellView"
    var displayName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        albumImageView.delegate = self
        items = [SpotifySearchItem]()
        tableView.delegate = self
        tableView.dataSource = self
        let spotifyManager = (NSApp.delegate as! AppDelegate).spotifyManager
        spotifyManager.myProfile { userProfile in
            self.displayName = userProfile.name
        }
        
        tableView.doubleAction = #selector(ViewController.openSpotify)
    }
    
    @objc func openSpotify() {
        NSWorkspace.shared.open(URL(string: "spotify://\(items[tableView.selectedRow].uri)")!)
    }

}

extension ViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: itemCellIdentifier), owner: nil) as? NSTableCellView, tableColumn == tableView.tableColumns[0] {
            let spotifyItem = items[row]
            cell.textField?.stringValue = SpotifyUtils.displayName(spotifyItem)
            return cell
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: typeCellIdentifier), owner: nil) as? NSTableCellView, tableColumn == tableView.tableColumns[1] {
            let spotifyItem = items[row]
            cell.textField?.stringValue = SpotifyUtils.displayType(spotifyItem)
            return cell
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: sharedByCellIdentifier), owner: nil) as? NSTableCellView, tableColumn == tableView.tableColumns[2] {
            cell.textField?.stringValue = self.displayName
            return cell
        }
        
        return nil
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        albumImageView.artUri = SpotifyUtils.artUri(items[row])
        albumImageView.updateView = true
        albumImageView.needsDisplay = true
        return true
    }
}

extension ViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return items.count
    }
}

extension ViewController: DestinationViewDelegate {
    func recievedSpotifyItem(_ item: SpotifySearchItem) {
        items.append(item)
        tableView.reloadData()
    }
}

class SpotifyUtils {
    static func displayType(_ item: SpotifySearchItem) -> String {
        if item is SpotifyTrack {
            return "Track"
        }
        
        if item is SpotifyAlbum {
            return "Album"
        }
        
        if item is SpotifyPlaylist {
            return "Playlist"
        }
        
        if item is SpotifyArtist {
            return "Artist"
        }
        return ""
    }
    
    static func displayName(_ item: SpotifySearchItem) -> String {
        if let item = item as? SpotifyTrack {
            return item.name + " by " + item.artist.name
        }
        
        if let item = item as? SpotifyAlbum {
            return item.name
        }
        
        if let item = item as? SpotifyPlaylist {
            return item.name + ", " + String(item.count) + " tracks"
        }
        
        if let item = item as? SpotifyArtist {
            return item.name
        }
        return ""
    }
    
    static func artUri(_ item: SpotifySearchItem) -> String {
        if let item = item as? SpotifyTrack {
            if let albumArt = item.album?.artUri {
                return albumArt
            }
        }
        
        if let item = item as? SpotifyAlbum {
            return item.artUri
        }
        
        if let item = item as? SpotifyPlaylist {
                return item.artUri
        }
        
        if let item = item as? SpotifyArtist {
            return item.artUri
        }
        return ""
    }
}

