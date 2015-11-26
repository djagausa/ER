//
//  WorkoutTableViewCell.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 11/17/15.
//  Copyright © 2015 Douglas Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WorkoutTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end
