//
//  ContentViewController.swift
//  Announcer
//
//  Created by JiaChen(: on 27/11/19.
//  Copyright © 2019 SST Inc. All rights reserved.
//

import UIKit
import SafariServices

class ContentViewController: UIViewController {
    
    var onDismiss: (() -> Void)?
    var defaultFontSize: CGFloat = 15
    
    var currentScale: CGFloat = 15 {
        didSet {
            if currentScale < 5 {
                currentScale = 5
            } else if currentScale > 50 {
                currentScale = 50
            }
        }
    }
    
    let borderColor = UIColor.systemBlue.withAlphaComponent(0.3).cgColor
    
    var playedHaptic = 0
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentTextField: UITextView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    // Accessibility Increase Text Size
    @IBOutlet weak var defaultFontSizeButton: UIButton!
    @IBOutlet var increaseTextSizeGestureRecognizer: UIPinchGestureRecognizer!
    
    // Header Buttons
    @IBOutlet weak var safariButton: UIButton!
    @IBOutlet weak var pinButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    
    var post: Post!
    var isPinned = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        currentScale = UserDefaults.standard.float(forKey: "textScale") == 0 ? defaultFontSize : CGFloat(UserDefaults.standard.float(forKey: "textScale"))
        
        UserDefaults.standard.set(currentScale, forKey: "textScale")
        
        // Update labels/textview with data
        let attrTitle = NSMutableAttributedString(string: post.title)
        // Find the [] and just make it like red or something
        
        // Make square brackets colored
        let indicesStart = attrTitle.string.indicesOf(string: "[")
        let indicesEnd = attrTitle.string.indicesOf(string: "]")
        
        // Determine which one is smaller (start indices or end indices)
        if (indicesStart.count >= (indicesEnd.count) ? indicesStart.count : indicesEnd.count) > 0 {
            for i in 1...(indicesStart.count >= indicesEnd.count ? indicesStart.count : indicesEnd.count) {
                
                let start = indicesStart[i - 1]
                let end = indicesEnd[i - 1]
                
                // [] colors will be Carl and Shannen
                // @shannen why these color names man
                let bracketStyle : [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor: UIColor.systemBlue, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22, weight: .semibold)]
                
                attrTitle.addAttributes(bracketStyle, range: NSRange(location: start, length: end - start + 2))
            }
        }
        
        titleLabel.attributedText = attrTitle
        
        // Format date as "1 Jan 2019"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        
        dateLabel.text = "Posted on \(dateFormatter.string(from: post.date))"
        
        // Render HTML from String
        // Handle JavaScript
        if post.content.contains("webkitallowfullscreen=\"true\"") {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Unable to Open Post", message: "An error occured when opening this post. Open this post in Safari to view its contents.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Open in Safari", style: .default, handler: { (_) in
                    self.openPostInSafari(UILabel())
                }))
                self.present(alert, animated: true)
            }
            
        } else {
            let content = post.content
            
            let attr = content.htmlToAttributedString
            
            attr?.addAttribute(.font, value: UIFont.systemFont(ofSize: currentScale, weight: .medium), range: NSRange.init(location: 0, length: (attr?.length)!))
            attr?.addAttribute(.backgroundColor, value: UIColor.clear, range: NSRange(location: 0, length: (attr?.length)!))
            
            // Optimising for iOS 13 dark mode
            if #available(iOS 13.0, *) {
                attr?.addAttribute(.foregroundColor, value: UIColor.label, range: NSRange(location: 0, length: (attr?.length)!))
            } else {
                
            }
            
            contentTextField.attributedText = attr
        }
        
        // Check if item is pinned
        // Update the button to show
        //If is in pinnned
        let pinnedItems = PinnedAnnouncements.loadFromFile() ?? []
        
        // Fill/Don't fill pin
        if #available(iOS 13, *) {
            if pinnedItems.contains(post) {
                isPinned = true
                pinButton.setImage(UIImage(systemName: "pin.fill")!, for: .normal)
            } else {
                isPinned = false
                pinButton.setImage(UIImage(systemName: "pin")!, for: .normal)
            }
        }
        
        // Set textField delegate
        contentTextField.delegate = self
        
        // Hide the tags if there are none
        if post.categories.count == 0 {
            collectionViewHeightConstraint.constant = 0
        }
        
        // Styling default font size button
        defaultFontSizeButton.layer.cornerRadius = 20
        defaultFontSizeButton.clipsToBounds = true
        defaultFontSizeButton.isHidden = true
        
        safariButton.layer.cornerRadius = 25 / 2
        backButton.layer.cornerRadius = 25 / 2
        shareButton.layer.cornerRadius = 25 / 2
        pinButton.layer.cornerRadius = 25 / 2
    }
    
    @IBAction func sharePost(_ sender: Any) {
        
        //Create Activity View Controller (Share screen)
        let shareViewController = UIActivityViewController.init(activityItems: [getShareURL(with: post)], applicationActivities: [])
        
        //Remove unneeded actions
        shareViewController.excludedActivityTypes = [.addToReadingList]
        
        //Present share sheet
        shareViewController.popoverPresentationController?.sourceView = self.view
        self.present(shareViewController, animated: true, completion: nil)
    }
    
    @IBAction func dismiss(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func pinnedItem(_ sender: Any) {
        //Toggle pin based on context
        var pinnedItems = PinnedAnnouncements.loadFromFile() ?? []
        
        if isPinned {
            pinnedItems.remove(at: pinnedItems.firstIndex(of: post)!)
        } else {
            pinnedItems.append(post)
        }
        
        PinnedAnnouncements.saveToFile(posts: pinnedItems)
        
        if #available(iOS 13.0, *) {
            if pinnedItems.contains(post) {
                isPinned = true
                
                pinButton.setImage(UIImage(systemName: "pin.fill")!, for: .normal)
            } else {
                isPinned = false
                pinButton.setImage(UIImage(systemName: "pin")!, for: .normal)
            }
        }
        
        // Create pop-up to say pinned or unpinned
        let popUpView = UILabel()
        popUpView.textAlignment = .center
        popUpView.frame = CGRect(x: 50, y: 50, width: UIScreen.main.bounds.width - 100, height: 30)
        
        popUpView.layer.cornerRadius = 30 / 2
        popUpView.clipsToBounds = true
        
        popUpView.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        popUpView.text = "Post \(isPinned ? "Pinned" : "Unpinned")"
        
        popUpView.backgroundColor = UIColor(named: "Guan Yellow")
        popUpView.alpha = 0
        
        view.addSubview(popUpView)
        
        UIView.animate(withDuration: 0.5, animations: {
            popUpView.alpha = 1
        }) { (_) in
            UIView.animate(withDuration: 0.5, delay: 3, options: .curveEaseOut, animations: {
                popUpView.alpha = 0
            }) { (_) in
                popUpView.removeFromSuperview()
            }
        }
        
        onDismiss?()
    }
    
    @IBAction func openPostInSafari(_ sender: Any) {
        let vc = SFSafariViewController(url: getShareURL(with: post))
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func pinchedTextField(_ sender: UIPinchGestureRecognizer) {
        print(sender.scale)
        
        let attr = NSMutableAttributedString(attributedString: contentTextField.attributedText)
        
        currentScale = currentScale * sender.scale
        
        attr.addAttribute(.font, value: UIFont.systemFont(ofSize: currentScale, weight: .medium), range: NSRange.init(location: 0, length: attr.length))
        
        contentTextField.attributedText = attr
        
        UserDefaults.standard.set(currentScale, forKey: "textScale")
        
        if sender.state == .ended || sender.state == .cancelled && sender.scale != 1 {
            
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (_) in
                self.defaultFontSizeButton.isHidden = true
            }
        } else {
            if sender.scale != 1 {
                defaultFontSizeButton.isHidden = false
            } else {
                defaultFontSizeButton.isHidden = true
            }
            
        }
    }
    
    @IBAction func resetToDefaultFontSize(_ sender: Any) {
        let attr = NSMutableAttributedString(attributedString: contentTextField.attributedText)
        
        attr.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .medium), range: NSRange(location: 0, length: attr.length))
        
        currentScale = 15
        
        UserDefaults.standard.set(currentScale, forKey: "textScale")
        
        contentTextField.attributedText = attr
        
        defaultFontSizeButton.isHidden = true
    }
}
