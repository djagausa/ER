//
//  EditSelectedEventTableViewController.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 4/23/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectedEvent.h"
#import "EditEventViewController.h"
#import "SetupExerciseInfoViewController.h"


@protocol EditSelectedEventTableViewControllerDelegate <NSObject>
- (SelectedEvent *)selectEventDataIs;
@end

@interface EditSelectedEventTableViewController : UITableViewController <AbstractEventDataDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, weak) id <EditSelectedEventTableViewControllerDelegate> delegate;

@end
