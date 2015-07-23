//
//  Schedule.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 5/26/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ScheduledEvent;

@interface Schedule : NSManagedObject

@property (nonatomic, retain) NSString * scheduleName;
@property (nonatomic, retain) NSNumber * numberOfWeeks;
@property (nonatomic, retain) NSNumber * repeatCount;
@property (nonatomic, retain) NSNumber * operationalMode;
@property (nonatomic, retain) NSSet *scheduledEvents;
@end

@interface Schedule (CoreDataGeneratedAccessors)

- (void)addScheduledEventsObject:(ScheduledEvent *)value;
- (void)removeScheduledEventsObject:(ScheduledEvent *)value;
- (void)addScheduledEvents:(NSSet *)values;
- (void)removeScheduledEvents:(NSSet *)values;

@end
