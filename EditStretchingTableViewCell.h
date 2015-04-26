//
//  EditStretchingTableViewCell.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 4/25/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditStretchingTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *stretchingDate;
@property (weak, nonatomic) IBOutlet UILabel *stretchingNote;
@property (weak, nonatomic) IBOutlet UILabel *stretchingTime;
@end
