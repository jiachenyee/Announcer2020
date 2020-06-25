//
//  TodayWrongDay.swift
//  Timetable
//
//  Created by JiaChen(: on 20/6/20.
//  Copyright © 2020 SST Inc. All rights reserved.
//

import Foundation
import UIKit

extension TodayViewController {
    func setUpWeekendUI() {
        let view = UIView(frame: self.view.frame)
        
        let ongoingSubject = SubjectView("|weekend|", subtitle: "Tap to view your timetable.\n👋 See you on Monday.", vc: self)
        
        ongoingSubject.translatesAutoresizingMaskIntoConstraints = false
        
        let ongoingSubjectConstraints = [NSLayoutConstraint(item: ongoingSubject,
                                                            attribute: .top,
                                                            relatedBy: .equal,
                                                            toItem: view,
                                                            attribute: .top,
                                                            multiplier: 1,
                                                            constant: 0),
                                         NSLayoutConstraint(item: ongoingSubject,
                                                            attribute: .leading,
                                                            relatedBy: .equal,
                                                            toItem: view,
                                                            attribute: .leading,
                                                            multiplier: 1,
                                                            constant: 8),
                                         NSLayoutConstraint(item: ongoingSubject,
                                                            attribute: .trailing,
                                                            relatedBy: .equal,
                                                            toItem: view,
                                                            attribute: .trailing,
                                                            multiplier: 1,
                                                            constant: 8)]
        
        view.addSubview(ongoingSubject)
        
        view.addConstraints(ongoingSubjectConstraints)
        
        self.view = view
    }
}