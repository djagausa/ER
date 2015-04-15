//
//  DefaultAerobic.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 3/24/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AerobicEvent;

@interface DefaultAerobic : NSManagedObject

@property (nonatomic, retain) NSNumber * cadence;
@property (nonatomic, retain) NSNumber * desiredHR;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSString * eventName;
@property (nonatomic, retain) NSNumber * totalTime;
@property (nonatomic, retain) NSNumber * category;
@property (nonatomic, retain) NSNumber * enabled;
@property (nonatomic, retain) NSSet *areobicEvents;
@end

@interface DefaultAerobic (CoreDataGeneratedAccessors)

- (void)addAreobicEventsObject:(AerobicEvent *)value;
- (void)removeAreobicEventsObject:(AerobicEvent *)value;
- (void)addAreobicEvents:(NSSet *)values;
- (void)removeAreobicEvents:(NSSet *)values;

@end
