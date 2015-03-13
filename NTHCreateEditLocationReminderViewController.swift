//
//  NTHCreateEditLocationReminderViewController.swift
//  Nothing
//
//  Created by Tomasz Szulc on 15/02/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit
import CoreData

class NTHCreateEditLocationReminderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {


    @IBOutlet private weak var doneButton: UIBarButtonItem!
    @IBOutlet private weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var useOpenHoursSwitch: UISwitch!
    
    
    private enum SegueIdentifier: String {
        case SelectPlace = "SelectPlace"
        case EditRegion = "EditRegion"
    }
    
    private enum CellType: Int {
        case Place = 0
        case Region
    }

    var context: NSManagedObjectContext!
    var completionBlock: ((newReminder: LocationReminder) -> Void)?
    var reminder: LocationReminder!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerNib("NTHTwoLineLeftLabelCell")
        self.tableView.separatorColor = UIColor.NTHTableViewSeparatorColor()
        
        /// Check if reminder exists, if not create new one
        if self.reminder == nil {
            self.reminder = LocationReminder.create(self.context) as LocationReminder
            self.reminder.distance = 100.0
            self.reminder.onArrive = true
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        self.useOpenHoursSwitch.setOn(self.reminder.useOpenHours.boolValue, animated: false)
        self._validateDoneButton()
    }
    
    @IBAction func cancelPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func donePressed(sender: AnyObject) {
        self.reminder.useOpenHours = self.useOpenHoursSwitch.on
        self.context.save(nil) /// save temporary context and pass object from this context along
        self.completionBlock?(newReminder: reminder)
    
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func openHoursSwitchChanged(sender: UISwitch) {

    }
    
    private func _validateDoneButton() {
        self.doneButton.enabled = self.reminder.place != nil
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch SegueIdentifier(rawValue: segue.identifier!)! {
        case .SelectPlace:
            let vc = segue.destinationViewController as! NTHSimpleSelectLinkViewController
            vc.linkType = LinkType.Place
            vc.context = self.context
            vc.links = ModelController().allPlaces(self.context)
            vc.selectedLink = self.reminder.place
            vc.completionBlock = { selected in
                self.reminder.place = (selected as! Place)
                self.tableView.reloadData()
            }
            
        case .EditRegion:
            let vc = segue.destinationViewController as! NTHSelectRegionViewController
            vc.settings = RegionAndDistance(onArrive: self.reminder.onArrive.boolValue, distance: self.reminder.distance.floatValue)
            vc.completionBlock = { settings in
                self.reminder.onArrive = settings.onArrive
                self.reminder.distance = settings.distance
                self.tableView.reloadData()
                return
            }
        }
    }
    
    /// Mark: Table View
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch CellType(rawValue: indexPath.row)! {
        case .Place:
            let cell = NTHTwoLineLeftLabelCell.create(tableView, title: "Place", subtitle: "Select")
            cell.accessoryType = .DisclosureIndicator
            if let place = self.reminder.place {
                cell.bottomLabel.text = place.name
            }
            return cell
            
        case .Region:
            let prefix = self.reminder.onArrive.boolValue ? "Arrive" : "Leave"
            let description = prefix + ", " + self.reminder.distance.floatValue.metersOrKilometers()
            let cell = NTHTwoLineLeftLabelCell.create(tableView, title: "Region and distance", subtitle: description)
            cell.accessoryType = .DisclosureIndicator
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch CellType(rawValue: indexPath.row)! {
        case .Place:
            self.performSegueWithIdentifier(SegueIdentifier.SelectPlace.rawValue, sender: nil)

        case .Region:
            self.performSegueWithIdentifier(SegueIdentifier.EditRegion.rawValue, sender: nil)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 62
    }
}
