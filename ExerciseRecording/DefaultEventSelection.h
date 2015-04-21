//
//  DefaultEventSelection.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 4/16/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DefaultEventSelection : NSObject

@property (nonatomic, strong) NSNumber *eventCategory;
@property (nonatomic, copy) NSString *eventName;

-(instancetype) init;

@end
