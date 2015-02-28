//
//  NTHOpenHoursViewController.swift
//  Nothing
//
//  Created by Tomasz Szulc on 25/02/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit

class NTHOpenHoursViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NTHOpenHoursCellDelegate {

    @IBOutlet private weak var tableView: UITableView!
    
    var openHours = [OpenHour]()
    var completionBlock: ((openHours: [OpenHour]) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerNib("NTHOpenHoursCell")
        self.tableView.tableFooterView = UIView()
    }
    
    @IBAction func donePressed(sender: AnyObject) {
        self.completionBlock?(openHours: self.openHours)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    /// Mark: UITableView
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let openHour = self.openHours[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("NTHOpenHoursCell") as! NTHOpenHoursCell
        cell.delegate = self
        cell.selectedBackgroundView = UIView()
        cell.dayNameLabel.text = openHour.dayString.uppercaseString
        cell.hourLabel.text = NSDateFormatter.NTHStringTimeFromDate(openHour.openHourDate) + " - " + NSDateFormatter.NTHStringTimeFromDate(openHour.closeHourDate)
        cell.markEnabled(openHour.enabled)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    /// Mark: NTHOpenHoursCellDelegate
    
    func cellDidEnable(cell: NTHOpenHoursCell, enabled: Bool) {
        let indexPath = self.tableView.indexPathForCell(cell)!
        (self.openHours[indexPath.row] as OpenHour).enabled = enabled
    }
    
    func cellDidTapClock(cell: NTHOpenHoursCell) {
        let picker = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("NTHOpenHoursPickerViewController") as! NTHOpenHoursPickerViewController
        NTHSheetSegue(identifier: nil, source: self, destination: picker).perform()
    }
    
    func cellDidTapClose(cell: NTHOpenHoursCell, closed: Bool) {
        let indexPath = self.tableView.indexPathForCell(cell)!
        (self.openHours[indexPath.row] as OpenHour).closed = closed
    }
    
    
    func cellDidChangeSwitchValue(cell: NTHOpenHoursCell, value: Bool) {
        if let indexPath = self.tableView.indexPathForCell(cell) {
            self.openHours[indexPath.row].enabled = value
        }
    }
}
