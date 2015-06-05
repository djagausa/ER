//
//  ScheduledEvent.m
//  ExerciseRecording
//
//  Created by Douglas Alexander on 6/2/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import "ScheduledEvent.h"
#import "DefaultAerobic.h"
#import "DefaultWeightLifting.h"
#import "Schedule.h"


@implementation ScheduledEvent

@dynamic week;
@dynamic day;
@dynamic performed;
@dynamic repeatedDays;
@dynamic aerobicEvent;
@dynamic weightEvent;
@dynamic schedule;
@dynamic cellColor;
@dynamic totalEvents;
@end


@implementation RepeatedDays

+(Class)transformedValueClass
{
    return [NSArray class];
}

+(BOOL)allowsReverseTransformation
{
    return YES;
}

-(id)transformedValue:(id)value
{
    return [NSKeyedArchiver archivedDataWithRootObject:value];
}

-(id)reverseTransformedValue:(id)value
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:value];
}

@end
