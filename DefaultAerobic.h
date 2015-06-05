//
//  DefaultAerobic.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 6/2/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AerobicEvent, ScheduledEvent;

@interface DefaultAerobic : NSManagedObject

@property (nonatomic, retain) NSNumber * cadence;
@property (nonatomic, retain) NSNumber * category;
@property (nonatomic, retain) NSNumber * desiredHR;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSNumber * enabled;
@property (nonatomic, retain) NSString * eventName;
@property (nonatomic, retain) NSNumber * totalTime;
@property (nonatomic, retain) NSSet *aerobicEvent;
@property (nonatomic, retain) NSSet *scheduledEvent;
@end

@interface DefaultAerobic (CoreDataGeneratedAccessors)

- (void)addAerobicEventObject:(AerobicEvent *)value;
- (void)removeAerobicEventObject:(AerobicEvent *)value;
- (void)addAerobicEvent:(NSSet *)values;
- (void)removeAerobicEvent:(NSSet *)values;

- (void)addScheduledEventObject:(ScheduledEvent *)value;
- (void)removeScheduledEventObject:(ScheduledEvent *)value;
- (void)addScheduledEvent:(NSSet *)values;
- (void)removeScheduledEvent:(NSSet *)values;

@end
