//
//  EditWeightTableViewCell.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 4/25/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditWeightTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *weightDate;
@property (weak, nonatomic) IBOutlet UILabel *weightSet;
@property (weak, nonatomic) IBOutlet UILabel *weightReps;
@property (weak, nonatomic) IBOutlet UILabel *weightWeight;
@property (weak, nonatomic) IBOutlet UILabel *weightNote;
@end
