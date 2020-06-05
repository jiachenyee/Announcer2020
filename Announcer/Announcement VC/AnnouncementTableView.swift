//
//  AnnouncementTableView.swift
//  Announcer
//
//  Created by JiaChen(: on 27/11/19.
//  Copyright © 2019 SST Inc. All rights reserved.
//

import Foundation
import UIKit

extension AnnouncementsViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if searchField.text != "" {
            // The user is searching, sections should be based on search
            // If no results, the section count will be 0
            var sections = 0
            
            // Check if searchLabels has anything, if so, add 1
            if searchLabels.count > 0 {
                sections += 1
            }
            
            // Check if search found in title has anything, if so, add 1
            if searchFoundInTitle.count > 0 {
                sections += 1
            }
            
            // Check if search found in body has anything, if so, add 1
            if searchFoundInBody.count > 0 {
                sections += 1
            }
            return sections
        }
        
        // If posts == nil, it is loading.
        // Return 1 segment for loading animations
        if pinned.count == 0 || posts == nil || posts.count == 0 {
            return 1
        } else if pinned.count == 0 && posts.count == 0 {
            // It gave up pulling data from the feed
            // There's probably no wifi
            return 0
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // If the searchfield text is not empty, show search results
        if searchField.text != "" {
            // if searchterm is found in title, it appears first
            switch section {
            case 0:
                if searchLabels.count > 0 {
                    return searchLabels.count
                } else if searchFoundInTitle.count >= 0 {
                    return searchFoundInTitle.count
                } else {
                    return searchFoundInBody.count
                }
            case 1:
                if searchLabels.count > 0 {
                    if searchFoundInTitle.count >= 0 {
                        return searchFoundInTitle.count
                    } else {
                        return searchFoundInBody.count
                    }
                } else {
                    return searchFoundInBody.count
                }
            default:
                return searchFoundInBody.count
            }
        } else {
            // Maximum of 5 pinned items
            if section == 0 && pinned.count != 0 {
                return pinned.count
            }
            
            // Loading screen
            if posts == nil {
                return 10
            }
            
            return posts.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GlobalIdentifier.announcementCell, for: indexPath) as! AnnouncementTableViewCell
        
        if posts == nil {
            cell.startLoader()
            tableView.isScrollEnabled = false
            tableView.allowsSelection = false
        } else {
            if searchField.text != "" {
                // Display Search Results
                switch indexPath.section {
                case 0:
                    if searchLabels.count > 0 {
                        cell.post = searchLabels[indexPath.row]
                    } else if searchFoundInTitle.count >= 0 {
                        cell.post = searchFoundInTitle[indexPath.row]
                    } else {
                        cell.post = searchFoundInBody[indexPath.row]
                    }
                case 1:
                    if searchLabels.count > 0 {
                        if searchFoundInTitle.count >= 0 {
                            cell.post = searchFoundInTitle[indexPath.row]
                        } else {
                            cell.post = searchFoundInBody[indexPath.row]
                        }
                    } else {
                        cell.post = searchFoundInBody[indexPath.row]
                    }
                default:
                    cell.post = searchFoundInBody[indexPath.row]
                }
                
            } else {
                if pinned.count != 0 && indexPath.section == 0 {
                    // Pinned items
                    cell.post = pinned[indexPath.row]
                } else if posts.count != 0  {
                    cell.post = posts[indexPath.row]
                }
            }
            
            if let _ = parent?.parent as? SplitViewController {
                cell.highlightPost = indexPath == selectedPath
            } else {
                
            }
            
            let interaction = UIContextMenuInteraction(delegate: self)
            cell.addInteraction(interaction)
            
            tableView.isScrollEnabled = true
            tableView.allowsSelection = true
        }
        
        return cell
    }
    
    // MARK: - TableView delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // When user selects row, perform segue and send the selected row's information to next VC.
        // Send the data over to the other VC
        // Deselect row after that to ensure highlighting goes away
        let cell = tableView.cellForRow(at: indexPath) as! AnnouncementTableViewCell
        
        selectedItem = cell.post
        
        cell.highlightPost = indexPath == selectedPath
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Appending posts to read posts
        var readAnnouncements = ReadAnnouncements.loadFromFile() ?? []
        readAnnouncements.append(cell.post)
        ReadAnnouncements.saveToFile(posts: readAnnouncements)
        
        if let parentVC = parent?.parent as? SplitViewController {
            parentVC.vc.post = cell.post
            cell.highlightPost = true
            
            if let previousCell = tableView.cellForRow(at: selectedPath) as? AnnouncementTableViewCell {
                previousCell.highlightPost = false
            }
            
            selectedPath = indexPath
            cell.handleRead()
        } else {
            let vc = getContentViewController(for: indexPath)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var headers = ["Pinned", "All Announcements"]
        if pinned.count == 0 {
            headers = ["All Announcements"]
        }
        
        if searchField.text != "" {
            headers = []
            
            if searchLabels.count > 0 {
                headers.append("Labels")
            }
            if searchFoundInTitle.count > 0 {
                headers.append("Title")
            }
            if searchFoundInBody.count > 0 {
                headers.append("Content")
            }
            
        }
        
        return headers[section]
    }
    
    //Swipe <-
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let swipeConfig = UISwipeActionsConfiguration(actions: [pinPost(forRowAtIndexPath: indexPath)])
        return swipeConfig
    }
    
    //Swipe Function Handlers
    //Pin Handlers
    func pinPost(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        // Register the cell
        let cell = announcementTableView.cellForRow(at: indexPath) as! AnnouncementTableViewCell
        
        let pinnedItems = PinnedAnnouncements.loadFromFile() ?? []
        
        let post = cell.post!
        
        var title = String()
        
        //If is in pinnned
        if pinnedItems.contains(post) {
            //Unpin post
            title = "Unpin"
        } else {
            //Pin post
            title = "Pin"
        }
        
        //Action Builder
        let action = UIContextualAction(style: .normal, title: title) { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
            
            //Toggle pin based on context
            if title == "Unpin" {
                var pinnedItems = PinnedAnnouncements.loadFromFile() ?? []
                
                pinnedItems.remove(at: pinnedItems.firstIndex(of: post)!)
                
                PinnedAnnouncements.saveToFile(posts: pinnedItems)
            } else {
                var pinnedItems = PinnedAnnouncements.loadFromFile() ?? []
                
                pinnedItems.append(post)
                
                PinnedAnnouncements.saveToFile(posts: pinnedItems)
            }
            
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (_) in
                self.pinned = PinnedAnnouncements.loadFromFile() ?? []
                self.announcementTableView.reloadData()
            }
            
            //Complete
            completionHandler(true)
        }
        action.backgroundColor = GlobalColors.greyTwo
        return action
    }
    
    
    // MARK: ScrollView
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Dismiss keyboard at for iPads because they do not auto dismiss
        view.endEditing(true)
        
        #if targetEnvironment(macCatalyst)
        #else
        if !searchField.isFirstResponder && !UserDefaults.standard.bool(forKey: UserDefaultsIdentifiers.scrollSelection.rawValue) {
            if scrollView.contentOffset.y <= -3 * scrollSelectionMultiplier {
                
                ScrollSelection.setNormalState(for: filterButton)
                ScrollSelection.setNormalState(for: searchField)
                
                ScrollSelection.setSelectedState(for: reloadButton,
                                                 withOffset: scrollView.contentOffset.y,
                                                 andConstant: 3 * scrollSelectionMultiplier)
                
                if playedHaptic != 1 {
                    let generator = UIImpactFeedbackGenerator(style: .heavy)
                    generator.impactOccurred()
                }
                playedHaptic = 1
            } else if scrollView.contentOffset.y <= -2 * scrollSelectionMultiplier {
                ScrollSelection.setNormalState(for: searchField)
                ScrollSelection.setNormalState(for: reloadButton)
                
                ScrollSelection.setSelectedState(for: filterButton,
                                                 withOffset: scrollView.contentOffset.y,
                                                 andConstant: 2 * scrollSelectionMultiplier)
                
                if playedHaptic != 2 {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                }
                
                playedHaptic = 2
            } else if scrollView.contentOffset.y <= -1 * scrollSelectionMultiplier {
                
                ScrollSelection.setNormalState(for: filterButton)
                ScrollSelection.setNormalState(for: reloadButton)
                
                ScrollSelection.setSelectedState(for: searchField,
                                                 withOffset: scrollView.contentOffset.y,
                                                 andConstant: scrollSelectionMultiplier)
                
                if playedHaptic != 3 {
                    
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                }
                playedHaptic = 3
            } else {
                resetScroll()
                playedHaptic = 0
            }
        }
        #endif
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        #if targetEnvironment(macCatalyst)
            print("oh")
        #else
            if !UserDefaults.standard.bool(forKey: UserDefaultsIdentifiers.scrollSelection.rawValue) {
                resetScroll()
                if scrollView.contentOffset.y <= -3 * scrollSelectionMultiplier {
                    // Reload view
                    reload(UILabel())
                    
                } else if scrollView.contentOffset.y <= -2 * scrollSelectionMultiplier {
                    // Show labels selection screen
                    sortWithLabels(UILabel())
                    
                } else if scrollView.contentOffset.y <= -1 * scrollSelectionMultiplier {
                    // Select search field
                    searchField.becomeFirstResponder()
                    
                    // Reset search field style
                    ScrollSelection.setNormalState(for: searchField)
                }
                
                filterButton.tintColor = GlobalColors.greyOne
                searchField.setTextField(color: GlobalColors.background)
                reloadButton.tintColor = GlobalColors.greyOne
                
                resetScroll()
            }
        #endif
    }
    
    func resetScroll() {
        filterButton.layer.borderWidth = 0
        searchField.getTextField()?.layer.borderWidth = 0
        reloadButton.layer.borderWidth = 0
    }
}
