//
//  SelectEventToAddTableViewController.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 4/15/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectedEvent.h"
#import "SetupExerciseInfoViewController.h"
#import "AbstractEventDataTableViewController.h"
#import "SelectedEvent.h"

@protocol SelectEventToAddTableViewControllerDelegate <NSObject>
- (void)selectedEventAdded:(SelectedEvent *)event;
@end

@interface SelectEventToAddTableViewController : UITableViewController <AbstractEventDataDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) SetupExrciseInfoViewController *setupExerciseInfo;

@end
