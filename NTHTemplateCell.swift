//
//  NTHTrashCell.swift
//  Nothing
//
//  Created by Tomasz Szulc on 23/02/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit

protocol NTHTemplateCellDelegate {
    func cellDidPressUse(cell: NTHInboxCell)
    func cellDidPressDelete(cell: NTHInboxCell)
}

class NTHTemplateCell: NTHInboxCell {

    var delegate: NTHTemplateCellDelegate?
    
    @IBAction private func restorePressed(sender: AnyObject) {
        self.delegate?.cellDidPressUse(self)
    }
    
    @IBAction private func deletePressed(sender: AnyObject) {
        self.delegate?.cellDidPressDelete(self)
    }
}
