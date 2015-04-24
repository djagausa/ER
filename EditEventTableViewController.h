//
//  EditEventTableViewController.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 4/23/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditSelectedEventTableViewController.h"

@interface EditEventTableViewController : UITableViewController <EditSelectedEventTableViewControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
