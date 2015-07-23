//
//  MotivationalQuote.m
//  ExerciseRecording
//
//  Created by Douglas Alexander on 7/11/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import "MotivationalQuoteInfo.h"

@implementation MotivationalQuoteInfo

- (instancetype)initWithAuthor:(NSString *)author andQuote:(NSString *)quote
{
    self = [super init];
    
    if (self) {
        _author = author;
        _motivtionalQuote = quote;
    }
    return self;

}

- (instancetype)init
{
    self = [super init];
    
    return self;
}

@end
