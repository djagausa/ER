//
//  EditEventTableViewCell.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 4/25/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditEventTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *eventDate;
@property (weak, nonatomic) IBOutlet UILabel *eventL1;
@property (weak, nonatomic) IBOutlet UILabel *eventL2;
@property (weak, nonatomic) IBOutlet UILabel *eventL3;
@property (weak, nonatomic) IBOutlet UILabel *eventNote;
@end
