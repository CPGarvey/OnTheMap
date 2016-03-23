//
//  TableViewController.swift
//  On The Map
//
//  Created by Chris Garvey on 1/7/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    // MARK: - Property
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor(red: 0.851, green: 0.851, blue: 0.835, alpha: 1.0)
        tableView.tableFooterView = UIView(frame:CGRectZero)
        tableView.separatorColor = UIColor.clearColor()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        ParseClient.sharedInstance().getStudentLocations() { (success, errorString) in
            if success == true {
                performUIUpdatesOnMain {
                    self.tableView.reloadData()
                }
            } else {
                performUIUpdatesOnMain {
                    self.presentViewController(alert(errorString!), animated: true, completion: nil)
                }
            }
        }
    }
    
    
    // MARK: - Table View Data Source Protocol Methods - Configuring Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentData.students.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Student", forIndexPath: indexPath)
        cell.backgroundColor = UIColor.clearColor()
        let nameLabel = cell.viewWithTag(1001) as! UILabel
        let linkLabel = cell.viewWithTag(1002) as! UILabel
        
        nameLabel.text = StudentData.students[indexPath.row].firstName + " " + StudentData.students[indexPath.row].lastName
        linkLabel.text = StudentData.students[indexPath.row].mediaURL
        
        return cell
    }
    
    
    // MARK: - Table View Delegate - Managing Selections
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let url = NSURL(string: StudentData.students[indexPath.row].mediaURL) {
            
            guard UIApplication.sharedApplication().openURL(url) else {
                
                if let url = NSURL(string: "http://" + StudentData.students[indexPath.row].mediaURL) {
                    
                    guard UIApplication.sharedApplication().openURL(url) else {
                        
                        self.presentViewController(alert("URL is invalid, please select another link."), animated: true, completion: nil)
                        
                        return
                    }
                    
                } else {
                    
                    self.presentViewController(alert("URL is invalid, please select another link."), animated: true, completion: nil)
                }
                
                return
            }
            
        } else {
            
            self.presentViewController(alert("URL is invalid, please select another link."), animated: true, completion: nil)
        }
    }

}
