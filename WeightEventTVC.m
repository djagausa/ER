//
//  WeightEventTVC.m
//  ExerciseRecording
//
//  Created by Douglas Alexander on 4/4/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import "WeightEventTVC.h"

@implementation WeightEventTVC

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    self.note.preferredMaxLayoutWidth = CGRectGetWidth(self.note.frame);
}
@end
