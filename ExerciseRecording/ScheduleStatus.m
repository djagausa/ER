//
//  ScheduleStatus.m
//  ExerciseRecording
//
//  Created by Douglas Alexander on 6/10/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import "ScheduleStatus.h"

@implementation ScheduleStatus

- (instancetype)initWithScheduleName:(NSString *)scheduleName day:(NSNumber *)day week:(NSNumber *)week lastUpdateDate:(NSDate *)lastUpdateDate active:(BOOL)active;
{
    self = [super init];
    
    if (self) {
        _scheduleName = scheduleName;
        _day = day;
        _week = week;
        _lastUpdateDate = lastUpdateDate;
        _active = active;
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    
    return self;
}

@end
