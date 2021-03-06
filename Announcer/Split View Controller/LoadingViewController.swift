//
//  LoadingViewController.swift
//  Announcer
//
//  Created by JiaChen(: on 4/6/20.
//  Copyright © 2020 SST Inc. All rights reserved.
//

import UIKit

// The only purpose of this View Controller is to show a loading indicator
// Other than styling the indicator, nothing else is done here, no interaction whatsoever
class LoadingViewController: UIViewController {

    var loadingIndicator: UIActivityIndicatorView!
    
    override func loadView() {
        super.loadView()
        
        // Create an activity indicator programmetically (because Storyboards crashed)
        let loadingIndicator = UIActivityIndicatorView()
        
        // Set the style to large (because iPad)
        loadingIndicator.style = .large
        
        // Ensure that indicator will be hidden when stopped
        loadingIndicator.hidesWhenStopped = true
        
        // Start animating loading indicator to make it spin
        loadingIndicator.startAnimating()
        
        // Programmetic Constraints
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        // Align to center x and y, width and height are 40
        view.addConstraints([NSLayoutConstraint(item: loadingIndicator,
                                                attribute: .centerX,
                                                relatedBy: .equal,
                                                toItem: view,
                                                attribute: .centerX,
                                                multiplier: 1,
                                                constant: 0),
                             NSLayoutConstraint(item: loadingIndicator,
                                                attribute: .centerY,
                                                relatedBy: .equal,
                                                toItem: view,
                                                attribute: .centerY,
                                                multiplier: 1,
                                                constant: 0)
        ])
        
        // Hide navigation
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Add as a subview
        view.addSubview(loadingIndicator)
        
        // Set view's background color
        view.backgroundColor = GlobalColors.background
        
        // Update self.loadingIndicator with the new indicator
        self.loadingIndicator = loadingIndicator
    }
}
