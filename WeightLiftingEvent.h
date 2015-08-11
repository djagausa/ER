//
//  WeightLiftingEvent.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 3/28/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DefaultWeightLifting;

@interface WeightLiftingEvent : NSManagedObject

@property (nonatomic, retain) NSDate   * date;
@property (nonatomic, retain) NSString * eventName;
@property (nonatomic, retain) NSString * schedule;
@property (nonatomic, retain) NSNumber * day;
@property (nonatomic, retain) NSNumber * week;
@property (nonatomic, retain) NSNumber * weight;
@property (nonatomic, retain) NSNumber * category;
@property (nonatomic, retain) NSNumber * setNumber;
@property (nonatomic, retain) NSNumber * repCount;
@property (nonatomic, retain) NSNumber * performed;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * sectionIdentifier;
@property (nonatomic, retain) DefaultWeightLifting *defaultEvent;

@end
