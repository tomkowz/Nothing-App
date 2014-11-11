//
//  InboxCell.swift
//  Nothing
//
//  Created by Tomasz Szulc on 11/11/14.
//  Copyright (c) 2014 Tomasz Szulc. All rights reserved.
//

import UIKit

class InboxCell: UITableViewCell, UIGestureRecognizerDelegate {
    @IBOutlet private weak var thumbnail: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var longDescriptionTextView: UITextView!
    @IBOutlet private weak var datePlaceLabel: UILabel!
    
    @IBOutlet private weak var longDescriptionHeight: NSLayoutConstraint!
    @IBOutlet private weak var datePlaceHeight: NSLayoutConstraint!
    @IBOutlet private weak var topGuide: NSLayoutConstraint!
    
    private var initialTopGuideConstant: CGFloat = 0.0
    private var model: InboxCellVM?
    
    typealias HashtagSelectedBlock = (String) -> ()
    var hashtagSelectedBlock: HashtagSelectedBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureTapRecognizer()
        self.setup()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.setup()
    }

    private var tapRecognizer: UITapGestureRecognizer!
    private func configureTapRecognizer() {
        self.tapRecognizer = UITapGestureRecognizer(target: self, action:"handleTapGesture:")
        self.tapRecognizer.delegate = self
        self.addGestureRecognizer(self.tapRecognizer)
    }
    
    func handleTapGesture(recognizer: UITapGestureRecognizer) {
        /// do nothing here, all action is taken in delegate method
    }
    
    private func setup() {
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor.appBlueColorAlpha50()
        self.selectedBackgroundView = selectedBackgroundView
        
        if self.initialTopGuideConstant == 0.0 {
            self.initialTopGuideConstant = self.topGuide.constant
        }

        self.thumbnail.animationImages = nil
        
        self.titleLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 17.0)
        self.titleLabel.textColor = UIColor.appBlack()
        
        self.longDescriptionTextView.layoutMargins = UIEdgeInsetsZero
        self.longDescriptionTextView.contentInset = UIEdgeInsetsMake(0, -4, 0, -20)
        self.longDescriptionTextView.textContainerInset = UIEdgeInsetsZero
        self.longDescriptionTextView.font = UIFont(name: "HelveticaNeue-Light", size: 17.0)
        self.longDescriptionTextView.textColor = UIColor.appBlack()
        self.longDescriptionTextView.opaque = true
        
        self.datePlaceLabel.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)
        self.datePlaceLabel.textColor = UIColor.appWhite186()
        
        self.layoutMargins = UIEdgeInsetsZero
        
        self.configureThumbnailView()
    }
    
    private func configureThumbnailView() {
        let radius = 0.5 * (CGRectGetWidth(self.thumbnail.bounds) - 1)
        self.thumbnail.backgroundColor = UIColor.clearColor()
        self.thumbnail.layer.cornerRadius = radius
        self.thumbnail.layer.masksToBounds = true
        self.thumbnail.layer.borderColor = UIColor.appWhite216().CGColor
        self.thumbnail.layer.borderWidth = 1
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            self.didSelect()
        }
    }
    
    func didSelect() {
        self.animatePushViewInside()
        self.setSelected(false, animated: true)
    }
    
    func update(model: InboxCellVM) {
        self.model = model
        
        self.titleLabel.text = model.title()
        self.longDescriptionTextView.attributedText = model.longDescription(self.longDescriptionTextView.font)
        self.datePlaceLabel.text = model.dateAndPlace()
        
        self.longDescriptionHeight.constant = self.longDescriptionTextView.proposedHeight
        self.datePlaceHeight.constant = self.datePlaceLabel.proposedHeight
        
        // do only if cell is added to the table view
        if self.superview != nil {
            /*
            var images = model.connectionsImages()
            if images.count > 0 {
                self.thumbnail.layer.borderWidth = 0
                self.thumbnail.animationImages = images
                self.thumbnail.animationDuration = NSTimeInterval(images.count)
                self.thumbnail.startAnimating()
            } else {
                self.thumbnail.layer.borderWidth = 1.0
            }
            */
            if self.longDescriptionHeight.constant == 0 && self.datePlaceHeight.constant == 0 {
                self.topGuide.constant = self.bounds.midY - self.titleLabel.bounds.midY
            } else {
                self.topGuide.constant = self.initialTopGuideConstant
            }
            
            self.layoutSubviews()
        }
    }
    
    func update(backgroundColor: UIColor) {
        self.backgroundColor = backgroundColor
        self.titleLabel.backgroundColor = backgroundColor
        self.longDescriptionTextView.backgroundColor = backgroundColor
        self.datePlaceLabel.backgroundColor = backgroundColor
    }
    
    var estimatedHeight: CGFloat {
        let titleHeight = self.titleLabel.proposedHeight
        let longDescriptionHeight = self.longDescriptionHeight.constant
        let datePlaceHeight = self.datePlaceHeight.constant
        
        var margins = (2 * self.initialTopGuideConstant)
        var proposed = titleHeight + longDescriptionHeight + datePlaceHeight + margins
        
        if longDescriptionHeight == 0 && datePlaceHeight == 0 {
            proposed = margins + self.thumbnail.bounds.height
        }
        
        return proposed
    }
    
    func handleTap(point: CGPoint) -> Bool {
        var string: String? = nil

        if !CGRectContainsPoint(self.longDescriptionTextView.bounds, point) {
            return false
        }
        
        var index = self.longDescriptionTextView.layoutManager.characterIndexForPoint(point, inTextContainer: self.longDescriptionTextView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

        if index < self.longDescriptionTextView.textStorage.length {
            for (text, range) in self.model!.hashtags {
                if NSLocationInRange(index, range) {
                    string = text
                    break
                }
            }
        }
        
        if let hashtag = string {
            self.hashtagSelectedBlock?(hashtag)
        }
        
        return string != nil
    }
    
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if !(gestureRecognizer is UITapGestureRecognizer) {
            return false
        }
        
        if self.handleTap(touch.locationInView(self.longDescriptionTextView)) {
            return true
        }
        
        return false
    }
}

extension InboxCell {
    class func nib() -> UINib {
        return UINib(nibName: "InboxCell", bundle: NSBundle.mainBundle())
    }
}
