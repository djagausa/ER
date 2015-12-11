//
//  FAQAnswerVewController.swift
//  ExerciseRecording
//
//  Created by Douglas Alexander on 12/6/15.
//  Copyright © 2015 Douglas Alexander. All rights reserved.
//

import UIKit


@objc public class FAQAnswerViewController: UIViewController {

    var selectedRow: Int!
    let shareData = ShareData.sharedInstance
    var faqDescriptions: NSMutableArray!
    
    
    @IBOutlet weak var downArrowOutlet: UIButton!
    @IBOutlet weak var upArrowOutlet: UIButton!
    @IBOutlet weak var answerOutlet: UITextView!
    @IBOutlet weak var questionOutlet: UITextView!
    @IBOutlet weak var questionNumber: UILabel!
    
    @IBAction func upArrowAction(sender: AnyObject) {
        handleUpArrow()
    }
    @IBAction func downArrowAction(sender: AnyObject) {
        handleDownArrow()
    }
    override public func viewDidLoad() {
        super.viewDidLoad()
        selectedRow = shareData.selectedRow
        loadFAQDescription()
        setupViews()
        handleArrows()
        upArrowOutlet.adjustsImageWhenHighlighted = false
        downArrowOutlet.adjustsImageWhenHighlighted = false
    }
    
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func handleUpArrow() {
        if (selectedRow > 0) {
            selectedRow = selectedRow - 1
        }
        handleArrows()
        setupViews()
    }
    
    func handleDownArrow() {
        if (selectedRow < faqDescriptions.count) {
            selectedRow = selectedRow + 1
        }
        handleArrows()
        setupViews()
    }
    
    func handleArrows() {
        if (selectedRow == 0) {
            upArrowOutlet.enabled = false
        } else {
            upArrowOutlet.enabled = true
        }
        
        if (selectedRow == faqDescriptions.count - 1) {
            downArrowOutlet.enabled = false
        } else {
            downArrowOutlet.enabled = true
        }
    }
    
    func loadFAQDescription() {
        if let path = NSBundle.mainBundle().pathForResource("FAQList", ofType: "plist") {
            faqDescriptions = NSMutableArray(contentsOfFile: path)
        }
    }
    
    func setupViews() {
        let currentFAQDescription = faqDescriptions[self.selectedRow]
        questionOutlet.text = currentFAQDescription["Question"] as? String
        
        answerOutlet.text = currentFAQDescription["Answer"] as? String
        questionNumber.text = String(format: "Question \(selectedRow + 1) of \(faqDescriptions.count).")
    }
}