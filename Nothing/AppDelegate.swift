//
//  AppDelegate.swift
//  Nothing
//
//  Created by Tomasz Szulc on 27/10/14.
//  Copyright (c) 2014 Tomasz Szulc. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, TSRegionManagerDelegate {

    static let ApplicationDidUpdatePlaceSettingsNotification = "ApplicationDidUpdatePlaceSettingsNotification"
    
    var w: UIWindow?
    
    var window: UIWindow?
    private var locationManager: CLLocationManager!
    var regionManager = TSRegionManager()

    func applicationDidFinishLaunching(application: UIApplication) {
        self.regionManager.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "_refreshRegionManager", name: AppDelegate.ApplicationDidUpdatePlaceSettingsNotification, object: nil)
        
        self.setupUI()
        
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: UIUserNotificationType.Sound | UIUserNotificationType.Alert | UIUserNotificationType.Badge, categories: nil))
        self.startLocationService()
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        CDHelper.mainContext.save(nil)
    }
    
    func _refreshRegionManager() {
        self.regionManager.refresh()
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        println("log")
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        if let uniqueIdentifier = notification.userInfo?["uniqueIdentifier"] as! String? {
            if let task = ModelController().findTask(uniqueIdentifier) {
                println("Received notification about task: [\(task.title)]")
                NotificationPresenter.sharedInstance.enqueue(task)
            }
        }
    }
}

extension AppDelegate {
    func setupUI() {
        /// UINavigationBar
        UINavigationBar.appearance().barTintColor = UIColor.NTHAppBackgroundColor()
        UINavigationBar.appearance().translucent = true

        UINavigationBar.appearance().titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.NTHNavigationBarColor(),
            NSFontAttributeName: /*UIFont.NTHNavigationBarTitleFont()*/UIFont(name: "GeezaPro-Bold", size: 20.0)!
        ]

        UINavigationBar.appearance().tintColor = UIColor.NTHNavigationBarColor()

        /// UITableView
        UITableView.appearance().separatorColor = UIColor.NTHTableViewSeparatorColor()
    }
}

extension AppDelegate {
    
    func startLocationService() {
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        let status = CLLocationManager.authorizationStatus()
        if status == CLAuthorizationStatus.AuthorizedWhenInUse || status == CLAuthorizationStatus.Denied {
            let title = (status == CLAuthorizationStatus.Denied) ? "Location services are off" : "Background location is not enabled"
            let message = "To use background location you must turn on 'Always' in the Location Services Settings"
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            
            /// Settings
            alertController.addAction(UIAlertAction.normalAction("Settings", handler: { _ in
                UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
                return
            }))
            
            /// Cancel
            alertController.addAction(UIAlertAction.cancelAction(String.cancelString(), handler: nil))
            
            self.window?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
        } else if status == CLAuthorizationStatus.NotDetermined {
            /// nothing
        }
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        self.locationManager.startUpdatingLocation()
    }
    
    
    
    /// Mark: CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let location = locations.first as? CLLocation {
            self.regionManager.update(location)
        }
    }

    
    
    /// Mark: RegionManagerDelegate
    func regionManager(manager: TSRegionManager, didNotify regions: [TSRegion]) {
        for region in regions {
            if let task = ModelController().findTask(region.identifier) {
                var notification = UILocalNotification()
                notification.fireDate = NSDate()
                
                if notification.respondsToSelector("setAlertTitle") {
                    notification.alertTitle = task.title
                }
                notification.alertBody = "You're in close distance to do - \(task.title)"
                notification.userInfo = ["uniqueIdentifier": task.uniqueIdentifier]
                UIApplication.sharedApplication().scheduleLocalNotification(notification)
            }
        }
    }
    
    func regionManagerNeedRegions(manager: TSRegionManager) -> [TSRegion] {
        var regions = [TSRegion]()
        
        let tasks = ModelController().allTasksNotDoneAndNotTrashed()
        for task in tasks {
            for reminder in task.locationReminders {
                regions.append(reminder.TSRegionRepresentation())
            }
        }
        
        return regions
    }
}
