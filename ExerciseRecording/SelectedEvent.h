//
//  SelectAddEvent.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 4/29/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Support.h"
#import "DefaultAerobic.h"
#import "DefaultWeightLifting.h"
#import "WeightLiftingEvent.h"
#import "AerobicEvent.h"

@interface SelectedEvent : NSObject

@property (nonatomic, assign) ExerciseCategory      eventCategory;
@property (nonatomic, copy)   NSString              *eventName;
@property (nonatomic, strong) DefaultAerobic        *defaultAerobicData;
@property (nonatomic, strong) DefaultWeightLifting  *defaultWeightLiftingData;
@property (nonatomic, strong) WeightLiftingEvent    *weightLiftingEvent;
@property (nonatomic, strong) AerobicEvent          *aerobicEvent;

-(instancetype) init;

@end
