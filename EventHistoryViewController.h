//
//  EventHistoryViewController.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 5/1/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractEventDataViewController.h"

@interface EventHistoryViewController : AbstractEventDataViewController <AbstractEventDataDelegate>
@property (weak, nonatomic) IBOutlet UITableView *eventHistoryTable;

@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;
@end
