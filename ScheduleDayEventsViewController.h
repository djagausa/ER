//
//  ScheduleDayEventsViewController.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 5/26/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractEventDataViewController.h"
#import "ScheduledEventInfo.h"

@protocol ScheduleDayEventsViewControllerDelegate <NSObject>

- (ScheduledEventInfo *)dayToBeScheduled;
- (void)daysConfigured:(NSInteger)week;

@end

@interface ScheduleDayEventsViewController : AbstractEventDataViewController

@property (nonatomic, weak) id<ScheduleDayEventsViewControllerDelegate> scheduleEventDelegate;

@end
