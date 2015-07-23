//
//  MotivationalQuoteHelper.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 7/11/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MotivationalQuoteInfo.h"

@interface MotivationalQuoteHelper : NSObject

- (instancetype)init;
- (MotivationalQuoteInfo *)provideMotivationQuoteInfo;
- (void)clearUsedQuotesList;

@end
