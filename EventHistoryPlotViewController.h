//
//  EventHistoryPlotViewController.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 4/30/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "corePlot-CocoaTouch.h"
#import "AbstractEventDataViewController.h"

@interface EventHistoryPlotViewController : AbstractEventDataViewController <CPTPlotDataSource>

@property (nonatomic,strong) CPTGraphHostingView *hostView;

@end
