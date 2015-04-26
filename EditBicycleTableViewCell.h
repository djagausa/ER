//
//  EditBicycleTableViewCell.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 4/25/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditBicycleTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *bicyclingDate;
@property (weak, nonatomic) IBOutlet UILabel *bicyclingMiles;
@property (weak, nonatomic) IBOutlet UILabel *bicyclingHR;
@property (weak, nonatomic) IBOutlet UILabel *bicyclingCad;
@property (weak, nonatomic) IBOutlet UILabel *bicyclingNote;

@end
