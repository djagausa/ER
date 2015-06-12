//
//  NewScheduledWorkoutTableViewController.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 6/9/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractEventDataTableViewController.h"
#import "WorkoutScheduledEventViewController.h"

@interface NewScheduledWorkoutTableViewController : AbstractEventDataTableViewController <WorkoutScheduledEventViewControllerDelegate>

@end
