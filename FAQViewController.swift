//
//  FAQViewController.swift
//  ExerciseRecording
//
//  Created by Douglas Alexander on 12/2/15.
//  Copyright © 2015 Douglas Alexander. All rights reserved.
//

import UIKit


@objc public class FAQViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var faqDescriptions: NSMutableArray!
    let shareData = ShareData.sharedInstance
    
    @IBOutlet weak var faqTable: UITableView!
    @IBAction func viewTutorialButton(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tutorialView = storyboard.instantiateViewControllerWithIdentifier("Tutorial")
        self.navigationController?.pushViewController(tutorialView, animated: true)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        configureTableView()
        loadFAQDescription()
    }
    
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: Custom Functions
    
    func configureTableView() {
        faqTable.delegate = self
        faqTable.dataSource = self
        faqTable.tableFooterView = UIView(frame: CGRectZero)
        
    }
    
    func loadFAQDescription() {
        if let path = NSBundle.mainBundle().pathForResource("FAQList", ofType: "plist") {
            faqDescriptions = NSMutableArray(contentsOfFile: path)
            faqTable.reloadData()
        }
    }
    
    // MARK: UITableView Delegate and Datasource Functions
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if faqDescriptions != nil {
            return faqDescriptions.count
        }
        else {
            return 0
        }
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let currentFAQDescription = faqDescriptions[indexPath.row] as! [String: AnyObject]
        let cell = tableView.dequeueReusableCellWithIdentifier("FAQCell", forIndexPath: indexPath)
        cell.textLabel?.text = currentFAQDescription["Question"] as? String
        return cell
    }
    
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44.0
    }
    
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let faqAnswersViewController = storyboard.instantiateViewControllerWithIdentifier("FAQAnswersVC")
        shareData.selectedRow = indexPath.row
        self.navigationController?.pushViewController(faqAnswersViewController, animated: true)
    }

}