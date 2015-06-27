//
//  ScheduleStatus.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 6/10/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScheduleStatus : NSObject

@property (nonatomic, copy) NSString *scheduleName;
@property (nonatomic, strong) NSNumber *day;
@property (nonatomic, strong) NSNumber *week;
@property (nonatomic, strong) NSNumber *repeat;
@property (nonatomic, strong) NSDate *lastUpdateDate;
@property (assign, getter=isActive) BOOL active;

- (instancetype)initWithScheduleName:(NSString *)scheduleName day:(NSNumber *)day week:(NSNumber *)week lastUpdateDate:(NSDate *)lastUpdateDate active:(BOOL)active;
- (instancetype)init;

@end
