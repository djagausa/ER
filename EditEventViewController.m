//
//  EditEventViewController.m
//  ExerciseRecording
//
//  Created by Douglas Alexander on 4/27/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import "EditEventViewController.h"

@interface EditEventViewController ()

@end

@implementation EditEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self hideEntries];
    [self setupDisplayfor:self.selectedEvent.eventCategory];
}

- (void)hideEntries
{
    [self.lineOneLabel setHidden:YES];
    [self.lineTwoLabel setHidden:YES];
    [self.lineThreeLabel setHidden:YES];
    [self.lineFourLabel setHidden:YES];
    
    [self.lineOneInputText setHidden:YES];
    [self.lineTwoInputText setHidden:YES];
    [self.lineThreeInputText setHidden:YES];
    [self.noteInput setHidden:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupDisplayfor:(ExerciseCategory)exerciseCatergory
{
    switch (exerciseCatergory) {
        case kWeights:
            {
                self.navigationItem.title = self.selectedEvent.weightLiftingEvent.defaultEvent.eventName;
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setCalendar:[NSCalendar currentCalendar]];
                
                NSString *formatTemplate = [NSDateFormatter dateFormatFromTemplate:@"MM/dd/yyyy" options:0 locale:[NSLocale currentLocale]];
                [dateFormatter setDateFormat:formatTemplate];
                NSString *convertedDate = [dateFormatter stringFromDate:self.selectedEvent.weightLiftingEvent.date];

                [self setupLine:self.eventDateLabel labelText:@"Date:" inputLine:self.eventDateInputText originalValue:convertedDate];
                [self setupLine:self.lineOneLabel labelText:@"Set:" inputLine:self.lineOneInputText originalValue:[NSString stringWithFormat:@"%@", self.selectedEvent.weightLiftingEvent.setNumber]];
                [self setupLine:self.lineTwoLabel labelText:@"Reps:" inputLine:self.lineTwoInputText originalValue:[NSString stringWithFormat:@"%@", self.selectedEvent.weightLiftingEvent.repCount]];
                [self setupLine:self.lineThreeLabel labelText:@"Weight:" inputLine:self.lineThreeInputText originalValue:[NSString stringWithFormat:@"%@", self.selectedEvent.weightLiftingEvent.weight]];

                if ([self.selectedEvent.weightLiftingEvent.notes length] > 0) {
                    self.lineFourLabel.text = @"Note:";
                    self.noteInput.text = self.selectedEvent.weightLiftingEvent.notes;
                    [self.lineFourLabel setHidden:NO];
                    [self.noteInput setHidden:NO];
                    [self.noteInput setEditable:YES];
                }
            }
            break;
        case kRunning:
        case kWalking:
            {
                
            }
            break;
        case kBicycling:
            {
                
            }
            break;
        case kEliptical:
            {
                
            }
            break;
            
        default:
            break;
    }
}

- (void)setupLine:(UILabel *)lineToSet labelText:(NSString *)labelText inputLine:(UITextField *)inputTextField originalValue:(NSString *)originalValue
{
    lineToSet.text = labelText;
    inputTextField.text = originalValue;
    
    [lineToSet setEnabled:YES];
    [lineToSet setHidden:NO];
    [inputTextField setEnabled:YES];
    [inputTextField setHidden:NO];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)eventDate:(id)sender {
}

- (IBAction)lineOneInput:(id)sender {
}

- (IBAction)lineTwoInput:(id)sender {
}

- (IBAction)lineThreeInput:(id)sender {
}

- (IBAction)updateButton:(id)sender {
    self.selectedEvent.weightLiftingEvent.setNumber = [NSNumber numberWithInt: [self.lineOneInputText.text intValue]];
    self.selectedEvent.weightLiftingEvent.repCount = [NSNumber numberWithInt:[self.lineTwoInputText.text intValue]];
    self.selectedEvent.weightLiftingEvent.weight = [NSNumber numberWithInt:[self.lineThreeInputText.text intValue]];
    if ([self.noteInput.text length] > 0 ) {
        self.selectedEvent.weightLiftingEvent.notes = self.noteInput.text;
    }
    [self.coreDataHelper save];
}
@end
