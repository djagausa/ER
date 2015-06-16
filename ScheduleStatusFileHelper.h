//
//  ScheduleStatusFileHelper.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 6/14/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ScheduleStatus.h"

@interface ScheduleStatusFileHelper : NSObject

- (NSMutableDictionary *)readScheduleStatusFile;
- (void)writeScheduleStatusFile:(ScheduleStatus *)currentScheduleStatus;

@end
