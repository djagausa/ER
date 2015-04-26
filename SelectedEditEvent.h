//
//  SelectedEditEvent.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 4/24/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Support.h"

@interface SelectedEditEvent : NSObject

@property (nonatomic, assign) ExerciseCategory eventCategory;
@property (nonatomic, copy) NSString *eventName;

-(instancetype) init;

@end
