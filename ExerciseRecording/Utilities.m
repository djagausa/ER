//
//  utilities.m
//  ExerciseRecording
//
//  Created by Douglas Alexander on 6/14/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

+ (NSDate *)dateWithoutTime:(NSDate *)fullDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [dateFormatter setCalendar:calendar];
    
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:fullDate];
    
    NSDate *date = [calendar dateFromComponents:dateComponents];
    
    return date;
}

+ (NSString *)dateToFormatMMddyyy:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSString *convertedDate = [dateFormatter stringFromDate:date];
    NSString *formattedDate = [[NSString alloc] initWithFormat:@"Date: %@", convertedDate];
    
    return formattedDate;
}


+ (NSNumber *)convertTimeToNumber:(NSString *)timeString{
    
    NSArray* tokens = [timeString componentsSeparatedByString:@":"];
    NSInteger lengthInMinutes = 0;
    for (int i = 0 ; i != tokens.count ; i++) {
        lengthInMinutes = 60*lengthInMinutes + [[tokens objectAtIndex:i] integerValue];
    }
    return @(lengthInMinutes);
}

@end
