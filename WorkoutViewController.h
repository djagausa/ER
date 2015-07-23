//
//  WorkoutViewController.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 6/8/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractEventDataViewController.h"
#import "AddEventDataViewController.h"
#import "AbstractScheduleEventViewController.h"
#import "WorkoutScheduledEventViewController.h"
#import "CreateSheduleViewController.h"
#import "NewScheduledWorkoutTableViewController.h"

@interface WorkoutViewController : AbstractScheduleEventViewController <AbstractEventDataDelegate, WorkoutScheduledEventViewControllerDelegate, CreateSheduleViewControllerDelegate, NewScheduledWorkoutTableViewControllerDelegate>

@end
