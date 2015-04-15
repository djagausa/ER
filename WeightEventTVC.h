//
//  WeightEventTVC.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 4/4/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeightEventTVC : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *setCount;
@property (weak, nonatomic) IBOutlet UILabel *repsCount;
@property (weak, nonatomic) IBOutlet UILabel *weight;
@property (weak, nonatomic) IBOutlet UILabel *note;
@end
