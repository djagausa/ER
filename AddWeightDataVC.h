//
//  AddWeightDataVC.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 3/23/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractWeightDataViewController.h"
#import <CoreData/CoreData.h>
#import "DefaultWeightLifting.h"
#import "WeightLiftingEvent.h"

@interface AddWeightDataVC : AbstractWeightDataViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UITextField *setInput;
@property (weak, nonatomic) IBOutlet UITextField *repsInput;
@property (weak, nonatomic) IBOutlet UITextField *weightInput;
@property (weak, nonatomic) IBOutlet UITableView *weightEventsTable;
@property (weak, nonatomic) IBOutlet UITextView *note;
@property (weak, nonatomic) IBOutlet UISwitch *noteSwitch;

- (IBAction)noteSwitchChanged:(id)sender;
- (IBAction)setCountField:(id)sender;
- (IBAction)repCountField:(id)sender;
- (IBAction)weightField:(id)sender;
- (IBAction)addData:(id)sender;
@end
