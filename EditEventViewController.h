//
//  EditEventViewController.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 4/27/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractEventDataViewController.h"
#import "SelectedEvent.h"

@interface EditEventViewController : AbstractEventDataViewController

@property (weak, nonatomic) IBOutlet UILabel *lineOneLabel;
@property (weak, nonatomic) IBOutlet UILabel *lineTwoLabel;
@property (weak, nonatomic) IBOutlet UILabel *lineThreeLabel;
@property (weak, nonatomic) IBOutlet UILabel *lineFourLabel;
@property (weak, nonatomic) IBOutlet UITextField *lineOneInputText;
@property (weak, nonatomic) IBOutlet UITextField *lineTwoInputText;
@property (weak, nonatomic) IBOutlet UITextField *lineThreeInputText;
@property (weak, nonatomic) IBOutlet UITextField *eventDateInputText;
@property (weak, nonatomic) IBOutlet UILabel *eventDateLabel;

- (IBAction)eventDate:(id)sender;
- (IBAction)lineOneInput:(id)sender;
- (IBAction)lineTwoInput:(id)sender;
- (IBAction)lineThreeInput:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *noteInput;
- (IBAction)updateButton:(id)sender;

@end
