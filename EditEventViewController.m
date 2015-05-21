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
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setCalendar:[NSCalendar currentCalendar]];
    
    NSString *formatTemplate = [NSDateFormatter dateFormatFromTemplate:@"MM/dd/yyyy" options:0 locale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:formatTemplate];

    self.lineFourLabel.text = @"Note:";
    self.noteInput.text = self.selectedEvent.aerobicEvent.note;
    [self.lineFourLabel setHidden:NO];
    [self.noteInput setHidden:NO];
    [self.noteInput setEditable:YES];

    switch (exerciseCatergory) {
        case kWeights:
            {
                self.navigationItem.title = self.selectedEvent.weightLiftingEvent.defaultEvent.eventName;
                NSString *convertedDate = [dateFormatter stringFromDate:self.selectedEvent.weightLiftingEvent.date];

                [self setupLine:self.eventDateLabel labelText:@"Date:" inputLine:self.eventDateInputText originalValue:convertedDate];
                [self setupLine:self.lineOneLabel labelText:@"Set:" inputLine:self.lineOneInputText originalValue:[NSString stringWithFormat:@"%@", self.selectedEvent.weightLiftingEvent.setNumber]];
                [self setupLine:self.lineTwoLabel labelText:@"Reps:" inputLine:self.lineTwoInputText originalValue:[NSString stringWithFormat:@"%@", self.selectedEvent.weightLiftingEvent.repCount]];
                [self setupLine:self.lineThreeLabel labelText:@"Weight:" inputLine:self.lineThreeInputText originalValue:[NSString stringWithFormat:@"%@", self.selectedEvent.weightLiftingEvent.weight]];
            }
            break;
            
        default:
        {
            self.navigationItem.title = self.selectedEvent.aerobicEvent.defaultEvent.eventName;
            NSString *convertedDate = [dateFormatter stringFromDate:self.selectedEvent.aerobicEvent.date];
            
            [self setupLine:self.eventDateLabel labelText:@"Date:" inputLine:self.eventDateInputText originalValue:convertedDate];
        
            switch (exerciseCatergory) {
                case kRunning:
                case kWalking:
                {
                    [self setupLine:self.lineOneLabel labelText:@"Time:" inputLine:self.lineOneInputText originalValue:[NSString stringWithFormat:@"%ld:%02ld", [self.selectedEvent.aerobicEvent.duration integerValue]/ 60, [self.selectedEvent.aerobicEvent.duration integerValue] % 60]];
                    self.lineOneInputText.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
                    [self setupLine:self.lineTwoLabel labelText:@"Avg HR:" inputLine:self.lineTwoInputText originalValue:[NSString stringWithFormat:@"%@", self.selectedEvent.aerobicEvent.heartRate]];
                    [self setupLine:self.lineThreeLabel labelText:@"Distance:" inputLine:self.lineThreeInputText originalValue:[NSString stringWithFormat:@"%@", self.selectedEvent.aerobicEvent.distance]];
                }
                    break;
                case kBicycling:
                {
                    [self setupLine:self.lineOneLabel labelText:@"Time:" inputLine:self.lineOneInputText originalValue:[NSString stringWithFormat:@"%ld:%02ld", [self.selectedEvent.aerobicEvent.duration integerValue]/ 60, [self.selectedEvent.aerobicEvent.duration integerValue] % 60]];
                    self.lineOneInputText.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
                    [self setupLine:self.lineTwoLabel labelText:@"Avg HR:" inputLine:self.lineTwoInputText originalValue:[NSString stringWithFormat:@"%@", self.selectedEvent.aerobicEvent.heartRate]];
                    [self setupLine:self.lineThreeLabel labelText:@"CAD:" inputLine:self.lineThreeInputText originalValue:[NSString stringWithFormat:@"%@", self.selectedEvent.aerobicEvent.cadenace]];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    [textView  resignFirstResponder];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
    }
    
    return YES;
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

- (NSNumber *)convertTimeToNumber:(NSString *)timeString{
    
    NSArray* tokens = [timeString componentsSeparatedByString:@":"];
    NSInteger lengthInMinutes = 0;
    for (int i = 0 ; i != tokens.count ; i++) {
        lengthInMinutes = 60*lengthInMinutes + [[tokens objectAtIndex:i] integerValue];
    }
    return @(lengthInMinutes);
}

- (IBAction)updateButton:(id)sender {
    switch (self.selectedEvent.eventCategory) {
        case kWeights:
            self.selectedEvent.weightLiftingEvent.setNumber = [NSNumber numberWithInt: [self.lineOneInputText.text intValue]];
            self.selectedEvent.weightLiftingEvent.repCount = [NSNumber numberWithInt:[self.lineTwoInputText.text intValue]];
            self.selectedEvent.weightLiftingEvent.weight = [NSNumber numberWithInt:[self.lineThreeInputText.text intValue]];
            if ([self.noteInput.text length] > 0 )
            {
                self.selectedEvent.weightLiftingEvent.notes = self.noteInput.text;
            }
            break;
            
        default:
            if ([self.noteInput.text length] > 0 )
            {
                self.selectedEvent.aerobicEvent.note = self.noteInput.text;
            }

            switch (self.selectedEvent.eventCategory) {
                case kRunning:
                case kWalking:
                    {
                        self.selectedEvent.aerobicEvent.duration = [self convertTimeToNumber: self.lineOneInputText.text];
                        self.selectedEvent.aerobicEvent.heartRate = [NSNumber numberWithInt: [self.lineTwoInputText.text intValue]];
                        self.selectedEvent.aerobicEvent.distance =[NSNumber numberWithInt: [self.lineThreeInputText.text intValue]];
                    }
                    break;
                case kBicycling:
                    {
                        self.selectedEvent.aerobicEvent.duration = [self convertTimeToNumber: self.lineOneInputText.text];
                        self.selectedEvent.aerobicEvent.heartRate = [NSNumber numberWithInt: [self.lineTwoInputText.text intValue]];
                        self.selectedEvent.aerobicEvent.cadenace =[NSNumber numberWithInt: [self.lineThreeInputText.text intValue]];
                    }
                    break;
                case kEliptical:
                {
                    
                }
                    break;
                    
                default:
                    break;
            }

            break;
    }

    [self.coreDataHelper save];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
