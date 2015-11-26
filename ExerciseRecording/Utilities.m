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

+ (NSString *)returnDateForSection:(id)theSection
{
    /*
     Section information derives from an event's sectionIdentifier, which is a string representing the number (year * 1000) + month.
     To display the section title, convert the year, month and day components to a string representation.
     */
    static NSDateFormatter *formatter = nil;
    
    if (!formatter)
    {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setCalendar:[NSCalendar currentCalendar]];
        
        NSString *formatTemplate = [NSDateFormatter dateFormatFromTemplate:@"MM/dd/yyyy" options:0 locale:[NSLocale currentLocale]];
        [formatter setDateFormat:formatTemplate];
    }
    
    NSInteger numericSection = [[theSection name] integerValue];
    NSInteger year = numericSection / 10000;
    NSInteger month = (numericSection - (year * 10000)) /100;
    NSInteger day = (numericSection - (year * 10000)) - (month * 100);
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.year = year;
    dateComponents.month = month;
    dateComponents.day = day;
    
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
    
     NSString *titleString = [formatter stringFromDate:date];
    return titleString;
}

@end
