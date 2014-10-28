//
//  TaskCellViewModel.swift
//  Nothing
//
//  Created by Tomasz Szulc on 27/10/14.
//  Copyright (c) 2014 Tomasz Szulc. All rights reserved.
//

import Foundation
import UIKit

func == (lhs: TaskCellVM, rhs: TaskCellVM) -> Bool {
    return lhs.task == rhs.task
}

class TaskCellVM: Equatable {
    let task: Task
    init (_ task: Task) {
        self.task = task
    }
    
    var title: String { return self.task.title }
    
    var description: NSAttributedString {
        let desc = self.task.longDescription ?? ""
        
        var attributedText = NSMutableAttributedString(string: desc)
        
        let hashtagAttributes = [NSForegroundColorAttributeName: UIColor.appBlueColor()]
        
        self.hashtags = HashtagParser(desc).parse() as [HashtagParser.Result]!
        for (text, range) in self.hashtags {
            attributedText.addAttributes(hashtagAttributes, range: range)
        }
        
        return attributedText
    }
    
    var hashtags: [HashtagParser.Result] = Array<HashtagParser.Result>()
    
    var datePlaceDescription: String {
        var value = ""
        if let reminder = self.task.dateReminderInfo {
            value += self.dateFormatter.stringFromDate(reminder.fireDate)
        }
        
        if let reminder = self.task.locationReminderInfo {
            if countElements(value) > 0 {
                value += " "
            }
            
            value += "@ \(reminder.place.customName)"
        }
        
        return value
    }
    
    lazy var dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd MMM yyyy hh:mm"
        return formatter
    }()
    
    lazy var titleLabelAttributes: UILabel.Attributes = {
        let attr = UILabel.Attributes()
        attr.font = UIFont(name: "HelveticaNeue-Medium", size: 17.0)!
        attr.textColor = UIColor.appBlack()
        return attr
    }()
    
    lazy var descriptionLabelAttributes: UILabel.Attributes = {
        let attr = UILabel.Attributes()
        attr.font = UIFont(name: "HelveticaNeue-Light", size: 16.0)!
        attr.textColor = UIColor.appBlack()
        attr.numberOfLines = 4
        return attr
    }()
    
    lazy var datePlaceLabelAttributes: UILabel.Attributes = {
        let attr = UILabel.Attributes()
        attr.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)!
        attr.textColor = UIColor.appWhite186()
        return attr
    }()
}