//
//  ScheduleStatusFileHelper.m
//  ExerciseRecording
//
//  Created by Douglas Alexander on 6/14/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import "ScheduleStatusFileHelper.h"
#import "Support.h"

@interface ScheduleStatusFileHelper()
@property (nonatomic, strong) NSMutableDictionary *scheduledStatus;
@end

@implementation ScheduleStatusFileHelper

#pragma mark - Schedule status

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.scheduledStatus = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"", scheduleNameKey, @(0), dayKey, @(0),weekKey, @"", lastUpdateDateKey, @(0), activeKey, @(0), repeatCountKey, nil ];
    }
    
    return self;
}

// get scheduled status file if it exists
- (NSMutableDictionary *)readScheduleStatusFile
{
    NSString *scheduleStatusFile;     // path to schedule status file
    NSMutableDictionary *scheduledFile;
    
    // get path to documents dirsctory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    if ([paths count] > 0) {
        // Path to schedlue status
        scheduleStatusFile = [[paths objectAtIndex:0] stringByAppendingPathComponent:scheduleStatusFileName];
        
        // if schedule status file exists
        if ([[NSFileManager defaultManager] fileExistsAtPath:scheduleStatusFile]) {
            
            // read the scheduled status file
            scheduledFile = [NSMutableDictionary dictionaryWithContentsOfFile:scheduleStatusFile];
            return scheduledFile;
        }
    }
    return nil;
}

// write scheduled status file
- (void)writeScheduleStatusFile:(ScheduleStatus *)currentScheduleStatus
{
    NSString *filePath;     // path to schedule status file
    
    [self.scheduledStatus setObject:currentScheduleStatus.scheduleName forKey:scheduleNameKey];
    [self.scheduledStatus setObject:currentScheduleStatus.week forKey:weekKey];
    [self.scheduledStatus setObject:currentScheduleStatus.day forKey:dayKey];
    [self.scheduledStatus setObject:currentScheduleStatus.lastUpdateDate forKey:lastUpdateDateKey];
    [self.scheduledStatus setObject:@(currentScheduleStatus.active) forKey:activeKey];
    [self.scheduledStatus setObject:currentScheduleStatus.repeat forKey:repeatCountKey];
 
    // get path to documents dirsctory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    if ([paths count] > 0) {
        // Path to schedlue status
        filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:scheduleStatusFileName];
        
        // write the scheduled status file
        if ([self.scheduledStatus writeToFile:filePath atomically:YES] == NO) {
            NSLog(@"Error writing schedule status file: %@",scheduleStatusFileName);
        }
    }
}


@end
