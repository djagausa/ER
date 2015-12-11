//
//  ShareData.swift
//  ExerciseRecording
//
//  Created by Douglas Alexander on 12/7/15.
//  Copyright © 2015 Douglas Alexander. All rights reserved.
//

import Foundation

class ShareData: NSObject {
    class var sharedInstance: ShareData {
        struct Static {
            static var instance: ShareData?
            static var token: dispatch_once_t = 0
        }
        dispatch_once(&Static.token) {
            Static.instance = ShareData()
        }
        
        return Static.instance!
    }
    var selectedRow: Int!
}

