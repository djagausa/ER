//
//  EventViewController.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 3/7/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractEventDataViewController.h"
#import "SelectEventToAddTableViewController.h"
#import "AddEventDataTVC.h"

@interface EventViewController : AbstractEventDataViewController <SelectEventToAddTableViewControllerDelegate, AddEventDataTVCDelegate>

@end

