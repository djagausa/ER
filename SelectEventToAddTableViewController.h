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
#import "CreateSheduleViewController.h"


@protocol SelectEventToAddTableViewControllerDelegate <NSObject>
- (void)eventAdded;
@end

@interface SelectEventToAddTableViewController : UITableViewController <AbstractEventDataDelegate, SetupExrciseInfoViewControllerDelegate, CreateSheduleViewControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) SetupExrciseInfoViewController *setupExerciseInfo;
@property (nonatomic, weak) id<SelectEventToAddTableViewControllerDelegate> eventAddedDelegate;

@end
