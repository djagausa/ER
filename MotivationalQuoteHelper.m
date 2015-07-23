//
//  MotivationalQuoteHelper.m
//  ExerciseRecording
//
//  Created by Douglas Alexander on 7/11/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import "MotivationalQuoteHelper.h"
#import "Support.h"

@interface MotivationalQuoteHelper()
@property (nonatomic, strong) NSArray       *sortedQuotes;
@property (nonatomic, strong) NSMutableArray       *usedQuotes;
@end

static NSInteger upperBound = 118;
static NSInteger lowerBound = 0;

@implementation MotivationalQuoteHelper

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _usedQuotes = [[NSMutableArray alloc] initWithCapacity:20];
        [self readMotivationQuoteInfo];
    }
    return self;
}

- (void)readMotivationQuoteInfo
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Quotes" ofType:@"plist"];
    NSDictionary *motivationalQuoteDic = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    NSArray *quotes = [motivationalQuoteDic objectForKey:@"Quotes"];
    
    // sort by author
    NSSortDescriptor *sortByAuthor = [NSSortDescriptor sortDescriptorWithKey:@"Author" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortByAuthor];
    self.sortedQuotes = [quotes sortedArrayUsingDescriptors:sortDescriptors];
}

- (MotivationalQuoteInfo *)provideMotivationQuoteInfo
{
    MotivationalQuoteInfo *motivationalQuote = [[MotivationalQuoteInfo alloc] init];
    BOOL quoteFound = NO;
    NSInteger randNumber = 0;
    
    while (quoteFound == NO) {
        randNumber = lowerBound + arc4random() %(upperBound - lowerBound);
        if ([self.usedQuotes containsObject:[NSNumber numberWithInteger:randNumber]] == NO) {
            [self.usedQuotes addObject:@(randNumber)];
            quoteFound = YES;
            // clear used quote list if all quotes have been used
            [self clearUsedQuotesList];
        }
    }
    motivationalQuote.author = [[self.sortedQuotes objectAtIndex:randNumber] objectForKey:@"Author"];
    motivationalQuote.motivtionalQuote = [[self.sortedQuotes objectAtIndex:randNumber] objectForKey:@"Quote"];

    return motivationalQuote;
}

- (void)clearUsedQuotesList
{
    if ([self.usedQuotes count] >= [self.sortedQuotes count]) {
        [self.usedQuotes removeAllObjects];

    }
}

@end
