//
//  EditRunningTableViewCell.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 4/25/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditRunningTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *runningDate;
@property (weak, nonatomic) IBOutlet UILabel *runningMiles;
@property (weak, nonatomic) IBOutlet UILabel *runningTime;
@property (weak, nonatomic) IBOutlet UILabel *runningHR;
@property (weak, nonatomic) IBOutlet UILabel *runningNote;

@end
