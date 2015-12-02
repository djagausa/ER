//
//  CALayer+XibConfiguration.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 11/30/15.
//  Copyright © 2015 Douglas Alexander. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface CALayer(XibConfiguration)

// This assigns a CGColor to borderColor.
@property(nonatomic, assign) UIColor* borderUIColor;

@end
