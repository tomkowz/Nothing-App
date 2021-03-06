//
//  NTHOldInboxCell.swift
//  Nothing
//
//  Created by Tomasz Szulc on 07/12/14.
//  Copyright (c) 2014 Tomasz Szulc. All rights reserved.
//

import UIKit

class NTHInboxCell: UITableViewCell {

    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var titleCenterYConstraint: NSLayoutConstraint!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var stateIndicatorView: NTHTaskStatusView!
    
    private var initialCenterYConstant: CGFloat!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if (self is NTHTemplateCell) == false {
            self.initialCenterYConstant = self.titleCenterYConstraint.constant
        }
        self.setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.setupUI()
    }
    
    private func setupUI() {
        self.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        self.titleLabel.textColor = UIColor.blackColor()
        
        if (self is NTHTemplateCell) == false {
            self.descriptionLabel.textColor = UIColor.NTHSubtitleTextColor()
            self.stateIndicatorView.backgroundColor = UIColor.clearColor()
            self.stateIndicatorView.state = .Active
        }
    }
    
    func update(task: Task) {
        self.titleLabel.text = task.title
        
        if (self is NTHTemplateCell) == false {
            self.descriptionLabel.text = task.longDescription ?? ""
            
            if task.longDescription == ""  {
                self.titleCenterYConstraint.constant = 0
                self.titleLabel.updateConstraintsIfNeeded()
            } else {
                self.titleCenterYConstraint.constant = self.initialCenterYConstant
            }
            
            stateIndicatorView.state = task.state
        }
    }
}
