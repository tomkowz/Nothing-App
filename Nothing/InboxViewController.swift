//
//  InboxViewController.swift
//  Nothing
//
//  Created by Tomasz Szulc on 27/10/14.
//  Copyright (c) 2014 Tomasz Szulc. All rights reserved.
//

import UIKit
import CoreLocation

class InboxViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DetailViewControllerDelegate {
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet weak var quickInsertView: QuickInsertView!
    @IBOutlet private weak var bottomGuide: NSLayoutConstraint!
    
    enum Identifiers: String {
        case InboxCell = "InboxCell"
        case TaskDetailSegue = "TaskDetail"
        case CreateTask = "CreateTask"
    }
    
    private var tasks = [Task]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.observeKeyboard()
        self.configureTableView()
        self.configureInsertContainer()
        self.navigationItem.title = "Inbox"
    }
    
    private func configureTableView() {
        self.tableView.registerNib(UINib(nibName: "NTHInboxCell", bundle: nil), forCellReuseIdentifier: "NTHInboxCell")
        self.tableView.tableFooterView = UIView()
    }
    
    private func configureInsertContainer() {
        self.quickInsertView.submitButton.enabled = false
        self.quickInsertView.backgroundColor = UIColor.appWhite250()
        self.quickInsertView.textField.placeholder = "What's in your mind"
        self.quickInsertView.submitButton.setTitle("Add", forState: .Normal)
        self.quickInsertView.didSubmitBlock = { title in [self]
            /// create new task
            let task: Task = Task.create(CDHelper.mainContext)
            task.title = title
            
            self.tasks = ModelController().allTasks()
            
            /// refresh ui
            dispatch_async(dispatch_get_main_queue(), { [self, task]
                self.quickInsertView.finish()
                self.tableView.reloadData()

                let index = (self.tasks as NSArray).indexOfObject(task)
                if (index != NSNotFound) {
                    self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
                }
            })
        }
        
        self.quickInsertView.didTapMoreBlock = { [self]
            self.performSegueWithIdentifier(Identifiers.CreateTask.rawValue, sender: self.quickInsertView.text)
            self.quickInsertView.finish()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.stopObservingKeyboard()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tasks = ModelController().allTasks()
        self.tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if segue.identifier! == Identifiers.TaskDetailSegue.rawValue {
            let navVC = segue.destinationViewController as UINavigationController
            let vc = navVC.topViewController as DetailViewController
            vc.task = sender as Task
            vc.delegate = self
        } else if segue.identifier! == Identifiers.CreateTask.rawValue {
            let navVC = segue.destinationViewController as UINavigationController
            let vc = navVC.topViewController as CreateEditViewController
            vc.taskTitle = sender as? String
        }
    }

    @IBAction func searchPressed(sender: AnyObject) {
//        self.performSegueWithIdentifier(Identifiers.SearchSegue.rawValue, sender: nil)
    }
    
    /// Mark: UITableViewDelegate & UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tasks.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let task = self.tasks[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("NTHInboxCell", forIndexPath: indexPath) as NTHInboxCell
        cell.fill(NTHInboxCellViewModel(task: task))

        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.performSegueWithIdentifier(Identifiers.TaskDetailSegue.rawValue, sender: self.tasks[indexPath.row])
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.quickInsertView.finish()
    }
    
    /// Mark: DetailViewControllerDelegate
    func viewControllerDidSelectHashtag(viewController: DetailViewController, hashtag: String) {
//        viewController.dismissViewControllerAnimated(true, completion: { () -> Void in
//            self.performSegueWithIdentifier(Identifiers.SearchSegue.rawValue, sender: hashtag)
//        })
    }
    
    /// Mark: Keyboard Notification
    private func observeKeyboard() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    private func stopObservingKeyboard() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let info = notification.userInfo {
            let kbFrame = info[UIKeyboardFrameEndUserInfoKey]!.CGRectValue()
            let animDuration = info[UIKeyboardAnimationDurationUserInfoKey]!.doubleValue
            
            self.bottomGuide.constant = kbFrame.height
            UIView.animateWithDuration(animDuration, animations: {
                self.quickInsertView.layoutIfNeeded()
                self.tableView.layoutIfNeeded()
            })
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let info = notification.userInfo {
            let animDuration = info[UIKeyboardAnimationDurationUserInfoKey]!.doubleValue
            self.bottomGuide.constant = 0
            UIView.animateWithDuration(animDuration, animations: {
                self.quickInsertView.layoutIfNeeded()
                self.tableView.layoutIfNeeded()
            })
        }
    }
}

