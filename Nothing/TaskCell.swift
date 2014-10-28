//
//  TaskCell.swift
//  Nothing
//
//  Created by Tomasz Szulc on 27/10/14.
//  Copyright (c) 2014 Tomasz Szulc. All rights reserved.
//

import UIKit

class TaskCell: UITableViewCell {
    @IBOutlet private (set) weak var thumbnailView: UIImageView!
    @IBOutlet private (set) weak var titleLabel: UILabel!
    @IBOutlet private (set) weak var descriptionLabel: UILabel!
    @IBOutlet private (set) weak var datePlaceLabel: UILabel!
    @IBOutlet weak var descriptionLabelHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //        self.enableDebug()
        self.configureThumbnailView()
        self.configureGestureRecognizer()
    }
    
    private func configureThumbnailView() {
        let radius = 0.5 * (CGRectGetWidth(self.thumbnailView.bounds) - 1)
        self.thumbnailView.backgroundColor = UIColor.clearColor()
        self.thumbnailView.layer.cornerRadius = radius
        self.thumbnailView.layer.masksToBounds = true
        self.thumbnailView.layer.borderColor = UIColor.appWhite216().CGColor
        self.thumbnailView.layer.borderWidth = 1
    }
    
    private func configureGestureRecognizer() {
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap:"))
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        let point = recognizer.locationInView(self)
        if (recognizer.state == .Ended) {

        }
    }
}

extension TaskCell {
    class func nib() -> UINib {
        return UINib(nibName: "TaskCell", bundle: NSBundle.mainBundle())
    }
}

extension TaskCell {
    
    func update(model: TaskCellVM) {
        self.titleLabel.text = model.title
        self.titleLabel.update(model.titleLabelAttributes)
        
        self.descriptionLabel.update(model.descriptionLabelAttributes)
        self.descriptionLabel.attributedText = model.description

        self.descriptionLabelHeight.constant = self.descriptionLabel.proposedHeight

        self.datePlaceLabel.text = model.datePlaceDescription
        self.datePlaceLabel.update(model.datePlaceLabelAttributes)
        
        self.layoutSubviews()
    }
    
    var estimatedHeight: CGFloat {
        return 2 * CGRectGetMinY(self.titleLabel.frame) + self.titleLabel.proposedHeight + self.descriptionLabel.proposedHeight + self.datePlaceLabel.proposedHeight
    }
}

extension TaskCell {

    func enableDebug() {
        self.contentView.backgroundColor = UIColor.yellowColor()
        self.titleLabel.backgroundColor = UIColor.redColor()
        self.descriptionLabel.backgroundColor = UIColor.greenColor()
        self.datePlaceLabel.backgroundColor = UIColor.blueColor()
    }
}