//
//  EditStoredEventData.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 4/27/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeightLiftingEvent.h"
#import "AerobicEvent.h"
#import "Support.h"

@interface EditStoredEventData : NSObject

@property (nonatomic, strong) WeightLiftingEvent    *weightEvent;
@property (nonatomic, strong) AerobicEvent          *aerobicEvent;
@property (nonatomic, assign) ExerciseCategory exerciseCategory;

@end


