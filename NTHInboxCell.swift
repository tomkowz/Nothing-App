//
//  NTHInboxCell.swift
//  Nothing
//
//  Created by Tomasz Szulc on 07/12/14.
//  Copyright (c) 2014 Tomasz Szulc. All rights reserved.
//

import UIKit

class NTHInboxCellViewModel {
    private var _task: Task
    
    init(task: Task) {
        self._task = task
    }
    
    var title: String {
        return self._task.title
    }
    
    var longDescription: String {
       return self._task.longDescription ?? ""
    }
}

class NTHInboxCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var stateIndicatorView: UIView!
    @IBOutlet weak var actionsButton: UIButton!
    @IBOutlet weak var spaceToCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleBottomToCenterYConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.setup()
    }
    
    private func setup() {
        self.separatorInset = UIEdgeInsetsMake(0, 20, 0, 0)
        
        self.titleLabel.font = UIFont.NTHInboxCellTitleFont()
        self.titleLabel.textColor = UIColor.NTHCadetGrayColor()
        
        self.descriptionLabel.font = UIFont.NTHInboxCellDescriptionFont()
        self.descriptionLabel.textColor = UIColor.NTHLinkWaterColor()
    }
    
    func fill(model: NTHInboxCellViewModel) {
        self.titleLabel.text = model.title
        self.descriptionLabel.text = model.longDescription
        
        if model.longDescription == ""  {
            self.titleBottomToCenterYConstraint.constant = CGRectGetHeight(self.stateIndicatorView.bounds) - 1
            self.titleLabel.updateConstraintsIfNeeded()
        } else {
            self.titleBottomToCenterYConstraint.constant = 0
        }
    }
}
