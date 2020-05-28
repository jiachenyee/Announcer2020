//
//  Functions.swift
//  Announcer
//
//  Created by JiaChen(: on 28/5/20.
//  Copyright © 2020 SST Inc. All rights reserved.
//

import Foundation
import SystemConfiguration
import UserNotifications
import UIKit
import BackgroundTasks
import SafariServices

/**
 Get the labels, tags or categories from the posts.
 
 - returns: An array of labels or tags from the post
 
 This method gets labels, tags or categories, from blog posts and removes duplicates.
 */
func fetchLabels() -> [String] {
    
    let parser = FeedParser(URL: GlobalLinks.rssURL)
    let result = parser.parse()
    
    switch result {
    case .success(let feed):
        var labels: [String] = []
        
        let entries = feed.atomFeed?.entries ?? []
        
        for i in entries {
            for item in i.categories ?? [] {
                labels.append(item.attributes?.term ?? "")
            }
            
        }
        
        labels.removeDuplicates()
        
        return labels
        
    case .failure(let error):
        print(error.localizedDescription)
        // Present alert
    }
    return []
}

/**
 Fetch blog post from the blogURL
 
 - returns: An array of Announcements stored as Post
 
 - parameters:
    - vc: Takes in Announcement View Controller to present an alert in a case of an error
  
 This method fetches the blog post from the blogURL and will alert the user if an error occurs and it is unable to get the announcements
 */
func fetchBlogPosts(_ vc: AnnouncementsViewController) -> [Post] {
    let parser = FeedParser(URL: GlobalLinks.rssURL)
    let result = parser.parse()
    
    switch result {
    case .success(let feed):
        let feed = feed.atomFeed
        let posts = convertFromEntries(feed: (feed?.entries!)!)
        
        UserDefaults.standard.set(posts[0].title, forKey: "recent-title")
        UserDefaults.standard.set(posts[0].content, forKey: "recent-content")
        
        return posts
    case .failure(let error):
        print(error.localizedDescription)
        // Present alert
        DispatchQueue.main.async {
            // No internet error
            let alert = UIAlertController(title: ErrorMessages.unableToLoadPost.title,
                                          message: ErrorMessages.unableToLoadPost.description,
                                          preferredStyle: .alert)
            
            // Try to reload and hopefully it works
            alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { action in
                vc.reload(UILabel())
            }))
            
            // Open the settings app
            alert.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { action in
                let url = URL(string: "App-Prefs:root=")!
                UIApplication.shared.open(url, options: [:]) { (success) in
                    print(success)
                }
            }))
            
            // Just dismiss it
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
                
            }))
            
            vc.present(alert, animated: true, completion: nil)
        }
    }
    
    return []
}

/**
 Fetches latest blog post for notifications
 
 - returns: A tuple with the title and content of the post or `nil` if no new content has been posted
 
 This method will fetch the latest posts from the RSS feed and if it is a new post, it will return the title and content for notifications, otherwise, it will return nil.
 */
func fetchNotificationsTitle() -> (title: String, content: String)? {
    let parser = FeedParser(URL: GlobalLinks.rssURL)
    let result = parser.parse()
    
    switch result {
    case .success(let feed):
        let feed = feed.atomFeed
        
        let posts = convertFromEntries(feed: (feed?.entries)!)
        
        if posts[0].title != UserDefaults.standard.string(forKey: "recent-title") && posts[0].content != UserDefaults.standard.string(forKey: "recent-content") {
            
            UserDefaults.standard.set(posts[0].title, forKey: "recent-title")
            UserDefaults.standard.set(posts[0].content, forKey: "recent-content")
            
            return (title: convertFromEntries(feed: (feed?.entries!)!).first!.title, content: convertFromEntries(feed: (feed?.entries!)!).first!.content.htmlToString)
        }
        
    default:
        break
    }
    
    return nil
}

/**
Fetches the blog posts from the blogURL

- returns: An array of `Post` from the blog
- important: This method will handle errors it receives by returning an empty array

 This method will fetch the posts from the blog and return it as [Post]
*/
func fetchValues() -> [Post] {
    let parser = FeedParser(URL: GlobalLinks.rssURL)
    let result = parser.parse()
    
    switch result {
    case .success(let feed):
        let feed = feed.atomFeed
        
        return convertFromEntries(feed: (feed?.entries)!)
    default:
        break
    }
    
    return []
}

/**
 Converts an array of `AtomFeedEntry` to an array of `Post`
 
 - returns: An array of `Post`
 
 - parameters:
    - feed: An array of `AtomFeedEntry`
  
 This method will convert the array of `AtomFeedEntry` from `FeedKit` to an array of `Post`.
*/
func convertFromEntries(feed: [AtomFeedEntry]) -> [Post] {
    var posts = [Post]()
    for entry in feed {
        let cat = entry.categories ?? []
        
        posts.append(Post(title: entry.title ?? "",
                          content: (entry.content?.value) ?? "",
                          date: entry.published ?? Date(),
                          pinned: false,
                          read: false,
                          reminderDate: nil,
                          categories: {
                            var categories: [String] = []
                            for i in cat {
                                categories.append((i.attributes?.term!)!)
                            }
                            return categories
        }()))
        
    }
    return posts
}

/**
 Gets the labels from search queries
 
 - returns: Label within the search query
 
 - parameters:
    - query: A String containing the search query
  
 This method locates the squared brackets `[]` in search queries and returns the Label within the query.
*/
func getLabelsFromSearch(with query: String) -> String {
    // Labels in search are a mess to deal with
    if query.first == "[" {
        let split = query.split(separator: "]")
        var result = split[0]
        result.removeFirst()
        
        return String(result.lowercased())
    }
    return ""
}

/**
 Gets the share URL from a `Post`
 
 - returns: The URL of the blog post
 
 - parameters:
    - post: The post to be shared
  
 - important: This method handles error 404 by simply returning the `blogURL`
 
 - note: Versions of SST Announcer before 11.0 shared the full content of the post instead of the URL
 
 This method generates a URL for the post by merging the date and the post title.
*/
func getShareURL(with post: Post) -> URL {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "/yyyy/MM/"
    
    var shareLink = ""
    
    let formatted = post.title.filter { (a) -> Bool in
        a.isLetter || a.isNumber || a.isWhitespace
    }.lowercased()
    let split = formatted.split(separator: " ")
    
    for i in split {
        if shareLink.count + i.count < 40 {
            shareLink += i + "-"
        } else {
            break
        }
    }
    shareLink.removeLast()
    
    // 40 chars
    shareLink = GlobalLinks.blogURL + dateFormatter.string(from: post.date) + shareLink + ".html"
    
    let shareURL = URL(string: shareLink) ?? URL(string: GlobalLinks.blogURL)!
    
    // Checking if the URL brings up a 404 page
    let isURLValid: Bool = {
        let str = try? String(contentsOf: shareURL)
        if let str = str {
            return !str.contains("Sorry, the page you were looking for in this blog does not exist.")
        } else {
            return false
        }
    }()
    
    if isURLValid {
        return shareURL
    }
    
    return URL(string: GlobalLinks.blogURL)!
}

/**
 Gets the links within the `Post`
 
 - returns: An array of `URL`s which are in the post.
 
 - parameters:
    - post: The selected post
 
 - important: This process takes a bit so it is better to do it asyncronously so the app will not freeze while searching for URLs.
 
 This method gets the URLs found within the blog post and filters out images from blogger's content delivery network because no one wants those URLs.
*/
func getLinksFromPost(post: Post) -> [URL] {
    let items = post.content.components(separatedBy: "href=\"")
    
    var links: [URL] = []
    
    for item in items {
        var newItem = ""
        
        for character in item {
            if character != "\"" {
                newItem += String(character)
            } else {
                break
            }
        }
        
        if let url = URL(string: newItem) {
            links.append(url)
        }
    }
    
    links.removeDuplicates()
    
    links = links.filter { (link) -> Bool in
        !link.absoluteString.contains("bp.blogspot.com/")
    }
    
    return links
}

/**
 Launches post using the post title
 
 - parameters:
    - postTitle: The title of the post to be found
 
 - note: This method is generally for search and notifications
 
 This method launches post using the post title and will show an open in safari button if there is an error.
*/
func launchPost(withTitle postTitle: String) {
    let posts = fetchValues()
    
    var post: Post?
    
    // Finding the post to present
    for item in posts {
        if item.title == postTitle {
            
            post = item
            
            break
        }
    }
    
    let navigationController = UIApplication.shared.windows.first?.rootViewController as! UINavigationController
    let announcementVC = navigationController.topViewController as! AnnouncementsViewController
    
    if let post = post {
        // Handles when post is found
        announcementVC.receivePost(with: post)
        
    } else {
        // Handle when unable to get post
        // Show an alert to the user to tell them that the post was unable to be found :(

        print("failed to get post :(")

        let alert = UIAlertController(title: ErrorMessages.unableToLaunchPost.title,
                                      message: ErrorMessages.unableToLaunchPost.description,
                                      preferredStyle: .alert)

        // If user opens post in Safari, it will simply bring them to student blog home page
        alert.addAction(UIAlertAction(title: "Open in Safari", style: .default, handler: { (_) in
            let svc = SFSafariViewController(url: URL(string: GlobalLinks.blogURL)!)
            
            announcementVC.present(svc, animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        announcementVC.present(alert, animated: true)
        
    }

}
