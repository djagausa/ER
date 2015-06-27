//
//  ScheduledEventInfo.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 5/26/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Schedule.h"
#import "ScheduledEvent.h"

@interface ScheduledEventInfo : NSObject
@property (nonatomic, strong) NSString *scheduleName;
@property (nonatomic, assign) NSInteger week;
@property (nonatomic, assign) NSInteger day;
@property (nonatomic, assign) NSInteger numberOfWeeks;
@property (nonatomic, assign) NSInteger repeatCount;
@property (nonatomic, assign) NSInteger colorIndex;
@property (nonatomic, assign) NSInteger scheduleEditMode;

- (instancetype) init;

@end
