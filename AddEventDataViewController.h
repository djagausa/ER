//
//  AddWeightDataVC.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 3/23/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractEventDataViewController.h"
#import <CoreData/CoreData.h>
#import "DefaultWeightLifting.h"
#import "WeightLiftingEvent.h"
#import "ScheduledEventInfo.h"

@protocol AddEventDataViewControllerDelegate <NSObject>
- (ScheduledEventInfo *)scheduleInfoIs;
@optional
- (void)exerciseDataAdded:(SelectedEvent *)eventAdded;
@end

@interface AddEventDataViewController : AbstractEventDataViewController

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UITextView *note;
@property (weak, nonatomic) IBOutlet UISwitch *noteSwitch;
@property (weak, nonatomic) IBOutlet UITextField *in1Label;
@property (weak, nonatomic) IBOutlet UITextField *in2Label;
@property (weak, nonatomic) IBOutlet UITextField *in3Label;
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;
@property (weak, nonatomic) IBOutlet UITableView *eventTable;
@property (weak, nonatomic) IBOutlet UILabel *hrdLab1;
@property (weak, nonatomic) IBOutlet UILabel *hdrLab2;
@property (weak, nonatomic) IBOutlet UILabel *hdrLab3;
@property (strong, nonatomic) id<AddEventDataViewControllerDelegate>addEventDataDelegate;

- (IBAction)noteSwitchChanged:(id)sender;
- (IBAction)addData:(id)sender;
- (IBAction)in1Input:(id)sender;
- (IBAction)in2Input:(id)sender;
- (IBAction)in3Input:(id)sender;

@end
