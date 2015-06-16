//
//  AerobicEvent.m
//  ExerciseRecording
//
//  Created by Douglas Alexander on 3/26/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import "AerobicEvent.h"
#import "DefaultAerobic.h"

@interface AerobicEvent ()

@property (nonatomic) NSDate *primitiveDate;
@property (nonatomic) NSString *primitiveSectionIdentifier;

@end

@implementation AerobicEvent

@dynamic name;
@dynamic date;
@dynamic duration;
@dynamic distance;
@dynamic heartRate;
@dynamic cadenace;
@dynamic mode;
@dynamic category;
@dynamic section;
@dynamic defaultEvent;
@dynamic note;
@dynamic primitiveSectionIdentifier;
@dynamic primitiveDate;
@dynamic performed;

- (NSString *)sectionIdentifier
{
    // Create and cache the section identifier on demand.
    [self willAccessValueForKey:@"sectionIdentifier"];
    NSString *tmp = [self primitiveSectionIdentifier];
    [self didAccessValueForKey:@"sectionIdentifier"];
    
    if (!tmp)
    {
        /*
         Sections are organized by month and year. Create the section identifier as a string representing the number (year * 1000) + month; this way they will be correctly ordered chronologically regardless of the actual name of the month.
         */
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)  fromDate:[self date]];
        //        NSLog(@"SectionIdentifier date components: %@", components);
        tmp = [NSString stringWithFormat:@"%ld", ([components year] * 1000) + ([components month] * 100) + [components day]];
        [self setPrimitiveSectionIdentifier:tmp];
    }
    return tmp;
}

#pragma mark - Date setter

- (void)setDate:(NSDate *)newDate
{
    // If the time stamp changes, the section identifier become invalid.
    [self willChangeValueForKey:@"date"];
    [self setPrimitiveDate:newDate];
    [self didChangeValueForKey:@"date"];
    
    [self setPrimitiveSectionIdentifier:nil];
}


#pragma mark - Key path dependencies

+ (NSSet *)keyPathsForValuesAffectingSectionIdentifier
{
    // If the value of date changes, the section identifier may change as well.
    return [NSSet setWithObject:@"date"];
}

@end
