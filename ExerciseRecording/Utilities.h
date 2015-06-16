//
//  Utilities.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 6/14/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utilities : NSObject

+ (NSString *)dateToFormatMMddyyy:(NSDate *)date;
+ (NSNumber *)convertTimeToNumber:(NSString *)timeString;
+ (NSDate *)dateWithoutTime:(NSDate *)fullDate;

- (instancetype)init;

@end
