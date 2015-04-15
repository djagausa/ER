//
//  WeightEventTableCellNoNote.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 4/14/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeightEventTableCellNoNote : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *weight;
@property (weak, nonatomic) IBOutlet UILabel *setCount;
@property (weak, nonatomic) IBOutlet UILabel *repsCount;
@end
