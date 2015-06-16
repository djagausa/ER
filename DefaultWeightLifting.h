//
//  DefaultWeightLifting.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 6/2/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ScheduledEvent, WeightLiftingEvent;

@interface DefaultWeightLifting : NSManagedObject

@property (nonatomic, retain) NSNumber * category;
@property (nonatomic, retain) NSNumber * enabled;
@property (nonatomic, retain) NSString * eventName;
@property (nonatomic, retain) NSNumber * numOfReps;
@property (nonatomic, retain) NSNumber * weight;
@property (nonatomic, retain) NSNumber * performed;
@property (nonatomic, retain) NSSet *liftingEvents;
@property (nonatomic, retain) NSSet *scheduledEvent;
@end

@interface DefaultWeightLifting (CoreDataGeneratedAccessors)

- (void)addLiftingEventsObject:(WeightLiftingEvent *)value;
- (void)removeLiftingEventsObject:(WeightLiftingEvent *)value;
- (void)addLiftingEvents:(NSSet *)values;
- (void)removeLiftingEvents:(NSSet *)values;

- (void)addScheduledEventObject:(ScheduledEvent *)value;
- (void)removeScheduledEventObject:(ScheduledEvent *)value;
- (void)addScheduledEvent:(NSSet *)values;
- (void)removeScheduledEvent:(NSSet *)values;

@end
