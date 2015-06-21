//
//  WorkoutSchuledEventViewController.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 6/9/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractScheduleEventViewController.h"
#import "ScheduledEventInfo.h"
#import "CreateSheduleViewController.h"

@protocol WorkoutScheduledEventViewControllerDelegate <NSObject>

- (ScheduledEventInfo *)scheduleInfoIs;

@end

@interface WorkoutScheduledEventViewController : AbstractScheduleEventViewController <CreateSheduleViewControllerDelegate>

@property (nonatomic, weak) id<WorkoutScheduledEventViewControllerDelegate> workoutScheduleDelegate;

@end
