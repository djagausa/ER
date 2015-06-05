//
//  ScheduledEvent.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 6/2/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DefaultAerobic, DefaultWeightLifting, Schedule;

@interface ScheduledEvent : NSManagedObject

@property (nonatomic, retain) NSNumber * week;
@property (nonatomic, retain) NSNumber * day;
@property (nonatomic, retain) NSNumber * performed;
@property (nonatomic, retain) NSNumber * totalEvents;
@property (nonatomic, retain) id repeatedDays;
@property (nonatomic, retain) NSNumber * cellColor;
@property (nonatomic, retain) NSSet *aerobicEvent;
@property (nonatomic, retain) NSSet *weightEvent;
@property (nonatomic, retain) Schedule *schedule;
@end

@interface ScheduledEvent (CoreDataGeneratedAccessors)

- (void)addAerobicEventObject:(DefaultAerobic *)value;
- (void)removeAerobicEventObject:(DefaultAerobic *)value;
- (void)addAerobicEvent:(NSSet *)values;
- (void)removeAerobicEvent:(NSSet *)values;

- (void)addWeightEventObject:(DefaultWeightLifting *)value;
- (void)removeWeightEventObject:(DefaultWeightLifting *)value;
- (void)addWeightEvent:(NSSet *)values;
- (void)removeWeightEvent:(NSSet *)values;

@end

@interface RepeatedDays : NSValueTransformer
@end

