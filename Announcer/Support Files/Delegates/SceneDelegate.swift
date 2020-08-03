//
//  SceneDelegate.swift
//  Announcer
//
//  Created by JiaChen(: on 25/11/19.
//  Copyright © 2019 SST Inc. All rights reserved.
//

import UIKit
import CoreSpotlight
import MobileCoreServices
import SafariServices

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window`
        // to the provided UIWindowScene `scene`.
        //
        // If using a storyboard, the `window` property will automatically be
        // initialized and attached to the scene.
        //
        // This delegate does not imply the connecting scene or session are
        // new (see `application:configurationForConnectingSceneSession` instead).
        if scene as? UIWindowScene == nil { return }
        
        if !I.phone {
            window?.rootViewController = Storyboards.main.instantiateViewController(withIdentifier: "master")
        }
        
        // Determine who sent the URL.
        if let urlContext = connectionOptions.urlContexts.first {
            
            let sendingAppID = urlContext.options.sourceApplication
            
            let url = urlContext.url
            print("source application = \(sendingAppID ?? "Unknown")")
            print("url = \(url)")
            
            print(urlContext.options)
            debugPrint(urlContext.options)
            
            var announcementVC: AnnouncementsViewController!
            
            if let splitVC = window?.rootViewController as? SplitViewController {
                announcementVC = splitVC.announcementVC
            } else {
                announcementVC = window?.rootViewController as? AnnouncementsViewController
            }
            
            DispatchQueue.main.async {
                if #available(iOS 14, *) {
                    announcementVC.openTimetable(self)
                }
            }
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        let timetableVC = Storyboards.timetable.instantiateInitialViewController()
        
        if let urlContext = URLContexts.first {
            let sendingAppID = urlContext.options.sourceApplication
            let url = urlContext.url
            print("source application = \(sendingAppID ?? "Unknown")")
            print("url = \(url)")
            
            let rootVC = UIApplication.shared.windows.first?.rootViewController
            
            switch url.absoluteString {
            case "sstannouncer://launchwidget":
                // User launched from widget, handle from widget
                rootVC?.present(timetableVC!,
                                animated: true,
                                completion: nil)
                
            case "sstannouncer://diagnostics":
                let vc = Storyboards.diagnostics.instantiateInitialViewController()
                
                window?.rootViewController = vc
            default:
                // I have the best error messages.
                
                // Never gonna give you up
                let svc = SFSafariViewController(url: URL(string: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")!)
                
                // easter egg
                rootVC?.present(svc, animated: true, completion: nil)
            }
        }
        
    }
    
    // Handling when user opens from spotlight search
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        continueFromCoreSpotlight(with: userActivity)
    }
}
