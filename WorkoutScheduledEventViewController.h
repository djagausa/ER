//
//  WorkoutSchuledEventViewController.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 6/9/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractScheduleEventViewController.h"
#import "AbstractEventDataViewController.h"
#import "ScheduledEventInfo.h"

@protocol WorkoutScheduledEventViewControllerDelegate <NSObject>

- (ScheduledEventInfo *)scheduleInfoIs;

@end

@interface WorkoutScheduledEventViewController : AbstractScheduleEventViewController <AbstractEventDataDelegate>

@property (nonatomic, weak) id<WorkoutScheduledEventViewControllerDelegate> workoutScheduleDelegate;

@end
