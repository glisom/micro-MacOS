//
//  AppDelegate.swift
//  micro
//
//  Created by Isom,Grant on 2/13/19.
//  Copyright © 2019 Grant Isom. All rights reserved.
//

import Cocoa
import SpotifyKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let spotifyManager = SpotifyManager(with:
        SpotifyManager.SpotifyDeveloperApplication(
            clientId:     Bundle.main.object(forInfoDictionaryKey: "SpotifyClientId") as! String,
            clientSecret: Bundle.main.object(forInfoDictionaryKey: "SpotifyClientSecret") as! String,
            redirectUri:  "com.isom.micro://callback"
        )
    )
    
    @objc func handleURLEvent(event: NSAppleEventDescriptor, replyEvent: NSAppleEventDescriptor) {
        if let descriptor = event.paramDescriptor(forKeyword: keyDirectObject), let urlString = descriptor.stringValue, let url = URL(string: urlString) {
            let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
            if let codeQueryItem = urlComponents?.queryItems?.first {
                if codeQueryItem.name == "code" {
                    spotifyManager.saveToken(from: url)
                }
            }
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSAppleEventManager.shared().setEventHandler(self,
                                                     andSelector: #selector(handleURLEvent),
                                                     forEventClass: AEEventClass(kInternetEventClass),
                                                     andEventID: AEEventID(kAEGetURL))
        spotifyManager.authorize()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

