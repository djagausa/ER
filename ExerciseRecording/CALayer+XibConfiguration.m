//
//  CALayer+XibConfiguration.m
//  ExerciseRecording
//
//  Created by Douglas Alexander on 11/30/15.
//  Copyright © 2015 Douglas Alexander. All rights reserved.
//
#import "CALayer+XibConfiguration.h"

@implementation CALayer(XibConfiguration)

-(void)setBorderUIColor:(UIColor*)color
{
    self.borderColor = color.CGColor;
}

-(UIColor*)borderUIColor
{
    return [UIColor colorWithCGColor:self.borderColor];
}

@end
