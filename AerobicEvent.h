//
//  AerobicEvent.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 3/26/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DefaultAerobic;

@interface AerobicEvent : NSManagedObject

@property (nonatomic, retain) NSString * eventName;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSString * schedule;
@property (nonatomic, retain) NSDate   * date;
@property (nonatomic, retain) NSNumber * day;
@property (nonatomic, retain) NSNumber * week;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSNumber * heartRate;
@property (nonatomic, retain) NSNumber * cadenace;
@property (nonatomic, retain) NSNumber * mode;
@property (nonatomic, retain) NSNumber * category;
@property (nonatomic, retain) NSNumber * section;
@property (nonatomic, retain) NSNumber * performed;
@property (nonatomic, retain) DefaultAerobic *defaultEvent;

@end
