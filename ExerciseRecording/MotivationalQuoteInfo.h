//
//  MotivationalQuote.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 7/11/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MotivationalQuoteInfo : NSObject

@property (nonatomic, copy)   NSString *author;
@property (nonatomic, copy)   NSString *motivtionalQuote;

- (instancetype) init;
- (instancetype) initWithAuthor:(NSString *)author andQuote:(NSString *)quote;

@end
