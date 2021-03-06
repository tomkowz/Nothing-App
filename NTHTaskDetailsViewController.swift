//
//  NTHTaskDetailsViewController.swift
//  Nothing
//
//  Created by Tomasz Szulc on 19/02/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class NTHTaskDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet private weak var scrollViewBottomGuide: NSLayoutConstraint!
    @IBOutlet private weak var titleTextField: NTHTextField!
    
    @IBOutlet private weak var locationsTableView: UITableView!
    @IBOutlet private weak var locationsTableViewHeight: NSLayoutConstraint!
    
    @IBOutlet private weak var datesTableView: UITableView!
    @IBOutlet private weak var datesTableViewHeight: NSLayoutConstraint!
    
    @IBOutlet private weak var linksTableView: UITableView!
    @IBOutlet private weak var linksTableViewHeight: NSLayoutConstraint!
    
    @IBOutlet private weak var notesTextView: NTHPlaceholderTextView!
    
    @IBOutlet private var tapGesture: UITapGestureRecognizer!
    
    @IBOutlet private weak var locationRemindersLabel: UILabel!
    @IBOutlet private weak var dateRemindersLabel: UILabel!
    @IBOutlet private weak var linksLabel: UILabel!
    @IBOutlet private weak var separator1: UIView!
    @IBOutlet private weak var separator2: UIView!
    @IBOutlet private weak var separator3: UIView!
    @IBOutlet private weak var separator4: UIView!
    
    @IBOutlet weak var taskStatusView: NTHTaskStatusView!

    var task: Task!
    var context: NSManagedObjectContext!
    
    private enum TableViewType: Int {
        case Locations, Dates, Links
    }
    
    private enum SegueIdentifier: String {
        case EditTask = "EditTask"
    }
    
    private func _configureColors() {
        self.locationRemindersLabel.textColor = UIColor.NTHHeaderTextColor()
        self.dateRemindersLabel.textColor = UIColor.NTHHeaderTextColor()
        self.linksLabel.textColor = UIColor.NTHHeaderTextColor()
        
        self.separator1.backgroundColor = UIColor.NTHTableViewSeparatorColor()
        self.separator2.backgroundColor = UIColor.NTHTableViewSeparatorColor()
        self.separator3.backgroundColor = UIColor.NTHTableViewSeparatorColor()
        self.separator4.backgroundColor = UIColor.NTHTableViewSeparatorColor()
        
        self.notesTextView.placeholderColor = UIColor.NTHPlaceholderTextColor()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self._configureColors()
        
        
        let notSetCellIdentifier = "NTHCenterLabelCell"
        let twoLineLeftLabelCellIdentifier = "NTHTwoLineLeftLabelCell"
        self.locationsTableView.tag = TableViewType.Locations.rawValue
        self.locationsTableView.registerNib(notSetCellIdentifier)
        self.locationsTableView.registerNib(twoLineLeftLabelCellIdentifier)
        
        self.datesTableView.tag = TableViewType.Dates.rawValue
        self.datesTableView.registerNib(notSetCellIdentifier)
        self.datesTableView.registerNib(twoLineLeftLabelCellIdentifier)

        self.linksTableView.tag = TableViewType.Links.rawValue
        self.linksTableView.registerNib(notSetCellIdentifier)
        self.linksTableView.registerNib("NTHLeftLabelCell")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self._fillView()
        self.taskStatusView.state = self.task.state
    }
    

    private func _fillView() {
        self.titleTextField.text = self.task.title
        if count(self.task.longDescription ?? "") > 0 {
            self.notesTextView.text = self.task.longDescription!
        }
        
        self.locationsTableView.refreshTableView(self.locationsTableViewHeight, height: self._locationRemindersTableViewHeight())
        self.datesTableView.refreshTableView(self.datesTableViewHeight, height: self._datesRemindersTableViewHeight())
        self.linksTableView.refreshTableView(self.linksTableViewHeight, height: self._linksTableViewHeight())
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifier.EditTask.rawValue {
            let vc = segue.topOfNavigationController as! NTHCreateEditTaskViewController
            vc.context = CDHelper.temporaryContext
            if let task = sender as? Task {
                var registeredObject = vc.context.objectWithID(task.objectID)
                vc.task = (registeredObject as? Task)!
                vc.completionBlock = { task in
                    self.context.refreshObject(self.task, mergeChanges: true)
                    self.context.save(nil)
                    
                    for reminder in self.task.reminders.allObjects as! [Reminder] {
                        self.context.refreshObject(reminder, mergeChanges: true)
                    }
                    
                    self._fillView()
                }
            }

        }
    }
    
    @IBAction func tamplatePressed(sender: AnyObject) {
        let template: Task = Task.create(self.context)
        template.createdAt = NSDate()
        template.links = self.task.links
        template.longDescription = self.task.longDescription
        template.uniqueIdentifier = NSUUID().UUIDString
        template.title = self.task.title
        
        var copiedReminders = Set<Reminder>()
        for reminder in self.task.reminders {
            if reminder is DateReminder {
                let reminder = reminder as! DateReminder
                var r: DateReminder = DateReminder.create(self.context)
                r.fireDate = reminder.fireDate
                r.repeatInterval = reminder.repeatInterval
                template.addReminder(r)
            } else if reminder is LocationReminder {
                let reminder = reminder as! LocationReminder
                var r: LocationReminder = LocationReminder.create(self.context)
                r.distance = reminder.distance
                r.onArrive = reminder.onArrive
                r.place = reminder.place
                r.useOpenHours = reminder.useOpenHours
                template.addReminder(r)
            }
        }
        
        template.isTemplate = true
        
        self.context.save(nil)
        
        let alert = UIAlertController.alert("Success", message: "Saved as template.")
        alert.addAction(UIAlertAction.cancelAction("OK", handler: { (action) -> Void in
            /// Do nothing
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func changeStatusPressed(sender: AnyObject) {
        self.task.changeState()
        self.taskStatusView.state = self.task.state
        self.context.save(nil)
        self.context.parentContext?.save(nil)
        
        /// Notify TSRegionManager that place changed
        NSNotificationCenter.defaultCenter().postNotificationName(AppDelegate.ApplicationDidUpdatePlaceSettingsNotification, object: nil)
    }
    
    /// Mark: UITableView
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch TableViewType(rawValue:tableView.tag)! {
        case .Locations: return max(1, self.task.locationReminders.count)
        case .Dates: return max(1, self.task.dateReminders.count)
        case .Links: return max(1, self.task.links.allObjects.count)
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        func _createNotSetCell(title: String) -> NTHCenterLabelCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("NTHCenterLabelCell") as! NTHCenterLabelCell
            cell.label.font = UIFont.NTHAddNewCellFont()
            cell.label.text = title
            cell.label.textColor = UIColor.NTHSubtitleTextColor()
            cell.selectedBackgroundView = UIView()
            return cell
        }
        
        func _createTwoLabelCell(topText: String, bottomText: String) -> NTHTwoLineLeftLabelCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("NTHTwoLineLeftLabelCell") as! NTHTwoLineLeftLabelCell
            cell.topLabel.font = UIFont.NTHNormalTextFont()
            cell.topLabel.text = topText
            
            cell.bottomLabel.font = UIFont.NTHAddNewCellFont()
            cell.bottomLabel.text = bottomText
            
            cell.selectedBackgroundView = UIView()
            return cell
        }
        
        func _createRegularCell(title: String) -> NTHLeftLabelCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("NTHLeftLabelCell") as! NTHLeftLabelCell
            cell.label.font = UIFont.NTHNormalTextFont()
            cell.label.text = title
            cell.selectedBackgroundView = UIView()
            return cell
        }
        
        switch TableViewType(rawValue:tableView.tag)! {
        case .Locations:
            let reminders = self.task.locationReminders
            if indexPath.row != reminders.count {
                let reminder = reminders[indexPath.row]
                let topText = reminder.place.name
                let prefix = reminder.onArrive.boolValue ? "Arrive" : "Leave"
                let bottomText = prefix + ", " + reminder.distance.floatValue.metersOrKilometers()
                
                return _createTwoLabelCell(topText, bottomText)
            } else {
                return _createNotSetCell("No reminders")
            }
            
        case .Dates:
            let reminders = self.task.dateReminders
            if reminders.count > 0 {
                let reminder = reminders[indexPath.row]
                let topText = NSDateFormatter.NTHStringFromDate(reminder.fireDate)
                let bottomText = RepeatInterval.descriptionForInterval(interval: reminder.repeatInterval)
                return _createTwoLabelCell(topText, bottomText)
            } else {
                return _createNotSetCell("No reminders")
            }
            
        case .Links:
            if self.task.links.allObjects.count > 0 {
                let link = self.task.links.allObjects[indexPath.row] as! Link
                
                let name: String!
                if link is Contact {
                    name = (link as! Contact).name
                } else {
                    name = (link as! Place).name
                }
                
                return _createRegularCell(name)
            } else {
                return _createNotSetCell("No links")
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch TableViewType(rawValue:tableView.tag)! {
        case .Locations:
            let reminders = self.task.locationReminders
            if reminders.count > 0 {
                let reminder = reminders[indexPath.row]
                let alert = UIAlertController.actionSheetForPlace(reminder.place)
                self.presentViewController(alert, animated: true, completion: nil)
            }
            break
            
        case .Dates:
            break
            
        case .Links:
            if self.task.links.allObjects.count > 0 {
                let link = self.task.links.allObjects[indexPath.row] as! Link
                if link is Place {
                    let alert = UIAlertController.actionSheetForPlace(link as! Place)
                    self.presentViewController(alert, animated: true, completion: nil)
                } else if link is Contact {
                    let alert = UIAlertController.actionSheetForContact(link as! Contact)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
            break
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch TableViewType(rawValue:tableView.tag)! {
        case .Locations:
            return self.task.locationReminders.count > 0 ? self._twoLineCellHeight() : self._oneLineCellHeight()
        case .Dates:
            return (self.task.dateReminders.count > 0) ? self._twoLineCellHeight() : self._oneLineCellHeight()
            
        case .Links:
            return self._oneLineCellHeight()
        }
    }
    
    
    private func _oneLineCellHeight() -> CGFloat {
        return 50.0
    }
    
    private func _twoLineCellHeight() -> CGFloat {
        return 69.0
    }
        
    private func _locationRemindersTableViewHeight() -> CGFloat {
        let count = self.task.locationReminders.count
        return count > 0 ? CGFloat(count) * self._twoLineCellHeight() : self._oneLineCellHeight()
    }
    
    private func _datesRemindersTableViewHeight() -> CGFloat {
        let count = self.task.dateReminders.count
        return (count > 0) ? self._twoLineCellHeight() * CGFloat(count) : self._oneLineCellHeight()
    }
    
    private func _linksTableViewHeight() -> CGFloat {
        return self._oneLineCellHeight() * CGFloat(max(1, self.task.links.count))
    }
    
    /// Actions
    
    @IBAction func editPressed(sender: AnyObject) {
        self.performSegueWithIdentifier(SegueIdentifier.EditTask.rawValue, sender: self.task)
    }
    
    @IBAction func deletePressed(sender: AnyObject) {
        let alert = UIAlertController(title: "Delete", message: "Do you want to delete \"\(self.task.title)\"?", preferredStyle: UIAlertControllerStyle.Alert)
        
        /// YES
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
            self.task.trashed = true.toNSNumber()
            self.context.save(nil)
            self.context.parentContext?.save(nil)
            self.navigationController?.popViewControllerAnimated(true)
        }))
        
        /// NO
        alert.addAction(UIAlertAction.cancelAction("No", handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

extension UIAlertController {
    class func actionSheetForPlace(place: Place) -> UIAlertController {
        let alert = UIAlertController.actionSheet(place.name, message: nil)
        alert.addAction(UIAlertAction.normalAction("Show on map", handler: { (action) -> Void in
            let coordinate = place.coordinate
            let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = place.name
            mapItem.openInMapsWithLaunchOptions(nil)
        }))
        
        alert.addAction(UIAlertAction.cancelAction("Cancel", handler: nil))
        
        return alert
    }
    
    class func actionSheetForContact(contact: Contact) -> UIAlertController {
        let alert = UIAlertController.actionSheet(contact.name, message: nil)
        
        if let phone = contact.phone {
            alert.addAction(UIAlertAction.normalAction("Call " + phone, handler: { (action) -> Void in
                UIApplication.sharedApplication().openURL(NSURL(string: "tel:" + phone)!)
            }))
        }
        
        if let email = contact.email {
            alert.addAction(UIAlertAction.normalAction("Email " + email, handler: { (action) -> Void in
                UIApplication.sharedApplication().openURL(NSURL(string: "mailto:" + email)!)
            }))
        }
        
        alert.addAction(UIAlertAction.cancelAction("Cancel", handler: nil))
        
        return alert
    }
}
