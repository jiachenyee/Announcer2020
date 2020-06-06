//
//  AnnouncementsTableViewController.swift
//  Announcer
//
//  Created by JiaChen(: on 27/11/19.
//  Copyright © 2019 SST Inc. All rights reserved.
//

import UIKit
import CoreSpotlight
import MobileCoreServices

class AnnouncementsViewController: UIViewController {
    
    /// Store the selected post found on didSelect
    var selectedItem: Post!
    
    /// Stores all post for this viewcontroller
    var posts: [Post]! {
        didSet {
            DispatchQueue.main.async {
                self.announcementTableView.reloadData()
                
                if self.posts != nil {
                    self.addItemsToCoreSpotlight()
                    
                    if let splitVC = self.splitViewController as? SplitViewController {
                        let cell = self.tableView(self.announcementTableView, cellForRowAt: self.selectedPath) as? AnnouncementTableViewCell
                        splitVC.contentViewController.post = cell?.post
                        splitVC.show(splitVC.contentViewController, sender: nil)
                    }
                }
            }
        }
    }
    
    /// Stores search results in the title
    var searchFoundInTitle = [Post]()
    
    /// Stores search results in body of post
    var searchFoundInBody = [Post]()
    
    /// Stores search results if searched with labels
    var searchLabels = [Post]() {
        didSet {
            if searchLabels.count == 0 {
                DispatchQueue.main.async {
                    self.filterButton.setImage(Assets.filter, for: .normal)
                }
                
            } else {
                DispatchQueue.main.async {
                    self.filterButton.setImage(Assets.filterFill, for: .normal)
                }
                
            }
        }
    }
    
    /// Haptics play at each segment when scrolling up
    var playedHaptic = 0
    
    /// Stores pinned posts
    var pinned = [Post]()
    
    /// Scroll selection multiplier used to control scroll height
    let scrollSelectionMultiplier: CGFloat = 50
    
    /// Selected Path
    var selectedPath = IndexPath(row: 0, section: 0)
    
    @IBOutlet weak var announcementTableView: UITableView!
    @IBOutlet weak var searchField: UISearchBar!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var reloadButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Hide navigation controller
        // Navigation controller is only used for segue animations
        self.navigationController?.navigationBar.isHidden = true
        
        // Fetch Blog Posts
        DispatchQueue.global(qos: .background).async {
            self.posts = Fetch.posts(with: self)
        }
        
        // Load Pinned Comments
        pinned = PinnedAnnouncements.loadFromFile() ?? []
        
        // Setting the searhField's text field color
        searchField.setTextField(color: GlobalColors.background)
        
        // Corner radius for top buttons
        // This is for the scroll selection
        filterButton.layer.cornerRadius = 25 / 2
        reloadButton.layer.cornerRadius = 27.5 / 2
        
        // Pointer support
        // Add a circle when they hover over button
        if #available(iOS 13.4, *) {
            filterButton.addInteraction(UIPointerInteraction(delegate: self))
            reloadButton.addInteraction(UIPointerInteraction(delegate: self))
        }
    }
    
    // Handles changing from dark to light or vice-versa
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        searchField.setTextField(color: GlobalColors.background)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        reloadFilter()
    }
    
    // Open Filter with Labels
    @IBAction func sortWithLabels(_ sender: Any) {
        // Resetting scroll selection
        // Handles when a user selects this button through scroll selection
        resetScroll()
        
        // Open up the filter view controller
        openFilter()
    }

    // Reload announcements
    @IBAction func reload(_ sender: Any) {
        self.posts = nil
        loadingIndicator.startAnimating()
        reloadButton.isHidden = true
        
        DispatchQueue.global(qos: .background).async {
            self.pinned = PinnedAnnouncements.loadFromFile() ?? []
            self.posts = Fetch.posts(with: self)
            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()
                self.reloadButton.isHidden = false
            }
        }
    }
    
    /// Receiving post from push notifications
    func receivePost(with post: Post) {
        selectedItem = post
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            let vc = (splitViewController as? SplitViewController)?.contentViewController
            
            vc!.post = post
        } else {
            let vc = getContentViewController(for: IndexPath(row: 0, section: 0))
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    /// Get filter view controller and open it up
    func openFilter() {
        let nvc = Storyboards.filter.instantiateInitialViewController() as! UINavigationController
        
        let vc = nvc.children.first as! FilterTableViewController
        
        // Set onDismiss actions that will run when we dismiss the other vc
        // this void should reload tableview etc.
        vc.onDismiss = {
            // Set search bar text
            self.searchField.text = "[\(filter)]"
            
            // Reload table view with new content
            self.announcementTableView.reloadData()
            
            // Run search function
            self.searchBar(self.searchField, textDidChange: "[\(filter)]")
            
            // Reset filters
            filter = ""
        }
        
        self.present(nvc, animated: true)
    }
    
    // Save items to spotlight search
    func addItemsToCoreSpotlight() {
        
        /// So that it does not crash when `posts` gets forced unwrapped
        /// Handles instances when `posts` is `nil`, for instance, when reloading
        if posts == nil {
            return
        }
        
        /// `posts` converted to `CSSearchableItems`
        let items: [CSSearchableItem] = posts.map({ post in
            let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeHTML as String)
            
            /// Setting the title of the post
            attributeSet.title = post.title
            
            /// Set the keywords for the `CSSearchableItem` to make it easier to find on Spotlight Search
            attributeSet.keywords = post.categories
            
            /// Setting the content description so when the user previews the announcement through spotlight search, they can see the content description
            attributeSet.contentDescription = post.content.condenseLinebreaks().htmlToString
            
            let item = CSSearchableItem(uniqueIdentifier: "\(post.title)", domainIdentifier: Bundle.main.bundleIdentifier!, attributeSet: attributeSet)
            
            item.expirationDate = Date.distantFuture
            
            return item
        })
        
        // Index the items
        CSSearchableIndex.default().indexSearchableItems(items) { error in
            // Make sure there is no error indexing everything
            if let error = error {
                print("Indexing error: \(error.localizedDescription)")
            } else {
                print("Search items successfully indexed!")
            }
        }
    }
    
    func reloadFilter() {
        // Handling when a tag is selected from the ContentViewController
        if filter != "" {
            // Setting search bar text
            self.searchField.text = "[\(filter)]"
            
            // Reloading announcementTableView with the new search field tet
            self.announcementTableView.reloadData()
            
            // Updating search bar
            self.searchBar(self.searchField, textDidChange: "[\(filter)]")
            
            // Reset filter
            filter = ""
        } else {
            self.announcementTableView.reloadData()
        }

    }
    
    @objc func startSearching() {
        searchField.becomeFirstResponder()
    }
}
