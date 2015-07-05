//
//  SetupExrciseInfoViewController.m
//  ExerciseRecording
//
//  Created by Douglas Alexander on 3/8/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import "SetupExerciseInfoViewController.h"
#import "AppDelegate.h"
#import "DefaultWeightLifting.h"
#import "DefaultAerobic.h"
#import "Support.h"
#import "SelectEventToAddTableViewController.h"
#import "Utilities.h"

@interface SetupExrciseInfoViewController ()

@property (nonatomic, strong) NSArray               *exerciseCategory;
@property (nonatomic, strong) NSMutableArray        *exerciseCategoryCopy;
@property (weak, nonatomic) IBOutlet UILabel        *label1;
@property (weak, nonatomic) IBOutlet UILabel        *label2;
@property (weak, nonatomic) IBOutlet UILabel        *label3;
@property (weak, nonatomic) IBOutlet UILabel        *label0;
@property (weak, nonatomic) IBOutlet UISwitch       *enableSwitchOutlet;
@property (weak, nonatomic) IBOutlet UIScrollView   *scrollView;
@property (nonatomic, weak) UIView                  *textField;
@property NSInteger                                 categoryCode;
- (IBAction)enableSwitchAction:(id)sender;
- (IBAction)eventNameInput:(id)sender;
@end

BOOL eventSelectedFromLAvailableList;
BOOL keyboardPresent;
UIEdgeInsets oldContentInset;
UIEdgeInsets oldIndicatorInset;

@implementation SetupExrciseInfoViewController

-(instancetype)init
{
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
        
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"ExerciseCategory" ofType:@"plist"];
    NSDictionary *categoryDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    self.exerciseCategory = categoryDictionary[@"ExerciseCategory"];
    self.exerciseCategoryCopy = [NSMutableArray arrayWithArray:self.exerciseCategory];

    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"Name" ascending:YES];
    [self.exerciseCategoryCopy sortedArrayUsingDescriptors: [NSArray arrayWithObjects:descriptor,nil]];
    
    self.categoryCode = self.exerciseCategoryCopy.count;
    self.selectedEvent = [[SelectedEvent alloc] init];
    
    NSShadow *shadow = [NSShadow new];
    [shadow setShadowColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
    [shadow setShadowOffset:CGSizeMake(0, 1)];
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor blueColor]};
    [[self saveButton] setTitleTextAttributes: attributes forState:UIControlStateNormal];
    
    attributes = @{NSForegroundColorAttributeName: [UIColor grayColor]};
    [[self saveButton] setTitleTextAttributes: attributes forState:UIControlStateDisabled];

    self.exerciseName.delegate = self;
    self.default1.delegate = self;
    self.default2.delegate = self;
    self.default3.delegate = self;
    
    if (self.editMode == YES) {
        [[self saveButton] setTitle:@"Update"];
        [[self saveButton] setEnabled:YES];
        [[self label0] setHidden:NO];
        [[self enableSwitchOutlet] setHidden:NO];
        [[self enableSwitchOutlet] setEnabled:YES];
        self.navigationItem.title = @"Edit Event Default Parameters";
    } else {
        [[self saveButton] setTitle:@"Save" ];
        [[self saveButton] setEnabled:NO];
        [[self label0] setHidden:YES];
        [[self enableSwitchOutlet] setHidden:YES];
        [[self enableSwitchOutlet] setEnabled:NO];
        self.navigationItem.title = @"Enter Event Default Parameters";
    }
    [self setContentInsetToZero];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.selectedEvent = [self.delegate selectedEventDataIs];
    
    if (self.editMode == YES) {
        NSArray *event;
        switch (self.selectedEvent.eventCategory) {
            case kWeights:
                event = [self.coreDataHelper fetchDataFor:@"DefaultWeightLifting"  withPredicate:@{@"propertyName" : @"eventName", @"value" : self.selectedEvent.eventName} sortKey:nil];
                self.selectedEvent.defaultWeightLiftingData = [event objectAtIndex:0];
                [self.enableSwitchOutlet setOn:(BOOL)[self.selectedEvent.defaultWeightLiftingData.enabled integerValue]];
                break;
                
            default:
                event = [self.coreDataHelper fetchDataFor:@"DefaultAerobic" withPredicate:@{@"propertyName" : @"eventName", @"value" : self.selectedEvent.eventName} sortKey:nil];
                self.selectedEvent.defaultAerobicData = [event objectAtIndex:0];
                [self.enableSwitchOutlet setOn:(BOOL)[self.selectedEvent.defaultAerobicData.enabled integerValue]];
                break;
        }
    }
    
    self.categoryCode = self.selectedEvent.eventCategory;
    self.exerciseName.text = self.selectedEvent.eventName;
    eventSelectedFromLAvailableList = NO;
    if (self.categoryCode != -1) {
        [self setupInputEntries:self.categoryCode];
        eventSelectedFromLAvailableList = YES;
    }
    
    [self verifyParametersReceived];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self verifyParametersReceived];
    self.textField = nil;
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.textField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {

}

- (void)setContentInsetToZero
{
    UIEdgeInsets contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    oldContentInset = contentInset;
    oldIndicatorInset = contentInset;
}

- (void)keyboardShow:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    if (keyboardPresent == NO) {
        oldIndicatorInset =self.scrollView.scrollIndicatorInsets;
        oldContentInset = self.scrollView.contentInset;
        keyboardPresent = YES;
    }

    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;

#ifdef DEBUG
    NSLog(@" Y point: %f; x point %f",self.textField.frame.origin.y + self.textField.frame.size.height, self.textField.frame.origin.x );
#endif
    
    if (aRect.size.height < (self.textField.frame.origin.y + self.textField.frame.size.height + 80.0)) {
        CGFloat diff = self.textField.frame.origin.y - (aRect.size.height + self.textField.frame.size.height) + 10.0;
        UIEdgeInsets constentInsets = UIEdgeInsetsMake(0.0, 0.0, diff, 0.0);
        self.scrollView.contentInset = constentInsets;
        self.scrollView.scrollIndicatorInsets = constentInsets;
    }
}

- (void)keyboardHide:(NSNotification *) notification
{
    self.scrollView.contentInset = oldContentInset;
    self.scrollView.scrollIndicatorInsets = oldIndicatorInset;
    [self setContentInsetToZero];
    keyboardPresent = NO;
}

- (BOOL) verifyParametersReceived
{
    BOOL verifiedOK = NO;
    
    [[self saveButton] setEnabled:NO];

    if (([self.exerciseName.text length] > 0) && (self.categoryCode < self.exerciseCategoryCopy.count))
    {
        [[self saveButton] setEnabled:YES];
        verifiedOK = YES;

         // ensure that the event being ceated does not already exist.
        if (eventSelectedFromLAvailableList == NO  && self.editMode == NO)
        {
            NSArray *event;
            [self fetchEvents];
            switch (self.categoryCode) {
                case kWeights:
                    event = [self.coreDataHelper fetchDataFor:@"DefaultWeightLifting" withPredicate:@{@"propertyName" : @"eventName", @"value" : self.exerciseName.text} sortKey:nil];
                    for (DefaultWeightLifting *weightEvent in event)
                    {
                        if ([weightEvent.eventName isEqualToString:self.exerciseName.text])
                        {
                            [self.saveButton setEnabled:NO];
                            [self presentAlertMesage:self.exerciseName.text];
                            verifiedOK = NO;
                            break;
                        }
                    }
                    break;
                    
                default:
                    event = [self.coreDataHelper fetchDataFor:@"DefaultAerobic" withPredicate:@{@"propertyName" : @"eventName", @"value" : self.exerciseName.text} sortKey:nil];
                    for (DefaultAerobic *aerobicEvent in event)
                    {
                        if ([aerobicEvent.eventName isEqualToString:self.exerciseName.text])
                        {
                            [self.saveButton setEnabled:NO];
                            [self presentAlertMesage:self.exerciseName.text];
                            verifiedOK = NO;
                            break;
                        }
                    }
                    break;
            }
        }
    }
    return verifiedOK;
}

- (void)presentAlertMesage:(NSString *)eventName
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Event Name: %@ already exists!",eventName] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    
}
- (IBAction)enableSwitchAction:(id)sender {
}

- (IBAction)eventNameInput:(id)sender {
    [self verifyParametersReceived];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.exerciseCategoryCopy.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ExerciseActivityCell" forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    // place a check mark 
    if (indexPath.row == self.categoryCode) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 22.0f;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Exercise Categories";
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectZero];
    UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 30)];
    labelView.textAlignment = NSTextAlignmentLeft;
    labelView.backgroundColor = [UIColor blueColor];
    labelView.textColor = [UIColor whiteColor];
    labelView.text = @"Exercise Categories";
    
    [headerView addSubview:labelView];
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return SECTION_HEADER_HEIGHT;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.text = [NSString stringWithFormat:@"%@", self.exerciseCategoryCopy[indexPath.row][@"Name"]];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.categoryCode = [self.exerciseCategoryCopy[indexPath.row][@"Code"]integerValue];
    [self verifyParametersReceived];
    [self setupInputEntries:self.categoryCode];
    [tableView reloadData];
}

-(void)setupInputEntries:(NSInteger)categoryCode
{
    switch (categoryCode) {
        case kWeights:
        {
            [self weightText];
            break;
        }
            
        case kWalking:
        case kRunning:
        {
            [self walkingText];
            break;
        }
            
        case kStretching:
        {
            break;
        }
            
        case kEliptical:
        {
            [self elipticalText];
            break;
        }
            
        case kBicycling:
        {
            [self bicyclingText];
            break;
        }
            
        default:
            break;
    }
}

- (void)resetDataEntry
{
    self.exerciseName.text = @"";
    self.categoryCode = self.exerciseCategoryCopy.count;
    [self.exerciseActivitySelectionTable reloadData];
    [[self saveButton] setEnabled:NO];
    [self.default1 setEnabled:NO];
    [self.default2 setEnabled:NO];
    [self.default3 setEnabled:NO];
    [self.default1 setHidden:YES];
    [self.default2 setHidden:YES];
    [self.default3 setHidden:YES];
    [self.label1 setHidden:YES];
    [self.label2 setHidden:YES];
    [self.label3 setHidden:YES];
    [[self label0] setHidden:YES];
    [[self enableSwitchOutlet] setHidden:YES];
    [[self enableSwitchOutlet] setEnabled:NO];
}

- (void)setupDefaultEntry:(NSString *)placeHolderString value:(NSNumber *)value outlet:(UITextField *)outlet labelText:(NSString *)labelText label:(UILabel *)label
{
    label.text = labelText;
    [label setHidden:NO];
    [outlet setHidden:NO];
    [outlet setEnabled:YES];
    [label setFont:[UIFont systemFontOfSize:14.0f]];

    if (self.editMode == YES) {
        if ([labelText isEqualToString: @"Default Time:"]) {
            outlet.text = [NSString stringWithFormat:@"%ld:%02ld", [value integerValue]/60, [value integerValue] % 60];
        } else {
            outlet.text = [NSString stringWithFormat:@"%@", value];
        }
    } else {
        outlet.text = placeHolderString;
    }
}
- (void)weightText
{
    [self setupDefaultEntry:@"Weight" value:self.selectedEvent.defaultWeightLiftingData.weight outlet:self.default1 labelText:@"Default Weight:" label:self.label1];
    self.default1.keyboardType = UIKeyboardTypeNumberPad;
    [self setupDefaultEntry:@"Reps" value:self.selectedEvent.defaultWeightLiftingData.numOfReps outlet:self.default2 labelText:@"Default Reps:" label:self.label2];
}

-  (void)walkingText
{
    [self setupDefaultEntry:@"Miles" value:self.selectedEvent.defaultAerobicData.distance outlet:self.default1 labelText:@"Default Miles:" label:self.label1];
    self.default1.keyboardType = UIKeyboardTypeNumberPad;

}

- (void)stretchingText
{
    
}

- (void)bicyclingText
{
    [self setupDefaultEntry:@"HH:MM" value:self.selectedEvent.defaultAerobicData.totalTime outlet:self.default1 labelText:@"Default Time:" label:self.label1];
    self.default1.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    [self setupDefaultEntry:@"HR" value:self.selectedEvent.defaultAerobicData.desiredHR  outlet:self.default2 labelText:@"Default HR:" label:self.label2];
    [self setupDefaultEntry:@"Cadance" value:self.selectedEvent.defaultAerobicData.cadence outlet:self.default3 labelText:@"Default Cadance:" label:self.label3];
//    [self.default3 setFont:[UIFont systemFontOfSize:12.0f]];
}

- (void)elipticalText
{
    self.default1.text = @"Default Time";
    self.default1.placeholder = @"Default Time";
}

#pragma mark - Core Data Save Exercise Classification
- (IBAction)saveData:(id)sender
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    DefaultWeightLifting *newDefaultWeightLifting;
    DefaultAerobic *newDefaultAerobic;
    
    if (self.editMode == YES)
    {
        // update existing objects.
        switch (self.selectedEvent.eventCategory)
        {
            case kWeights:
                self.selectedEvent.defaultWeightLiftingData.numOfReps = [NSNumber numberWithInt:[self.default2.text intValue]];
                self.selectedEvent.defaultWeightLiftingData.weight = [NSNumber numberWithInt:[self.default1.text intValue]];
                self.selectedEvent.defaultWeightLiftingData.enabled = [NSNumber numberWithBool: self.enableSwitchOutlet.isOn];
                break;
                
            default:
                self.selectedEvent.defaultAerobicData.enabled = [NSNumber numberWithBool: self.enableSwitchOutlet.isOn];
                 switch (self.selectedEvent.eventCategory)
                    {
                            case kRunning:
                            case kWalking:
                                {
                                    self.selectedEvent.defaultAerobicData.distance =[NSNumber numberWithInt: [self.default1.text intValue]];
                                }
                                break;
                            case kBicycling:
                                { 
                                    self.selectedEvent.defaultAerobicData.totalTime = [Utilities convertTimeToNumber: self.default1.text];
                                    self.selectedEvent.defaultAerobicData.desiredHR = [NSNumber numberWithInt: [self.default2.text intValue]];
                                    self.selectedEvent.defaultAerobicData.cadence =[NSNumber numberWithInt: [self.default3.text intValue]];
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
    } else {
        switch (self.categoryCode)
        {
            case kWeights:     // weights
                newDefaultWeightLifting = [NSEntityDescription insertNewObjectForEntityForName:@"DefaultWeightLifting" inManagedObjectContext:context];
                newDefaultWeightLifting.eventName = self.exerciseName.text;
                newDefaultWeightLifting.category = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithInteger:self.categoryCode] decimalValue ]];
                newDefaultWeightLifting.weight = [NSNumber numberWithInteger:[self.default1.text integerValue]];
                newDefaultWeightLifting.numOfReps = [NSNumber numberWithInteger:[self.default2.text integerValue]];
                newDefaultWeightLifting.enabled = @(1);         // default is enabled on
                break;
                
            case kWalking:
            case kRunning:
            case kEliptical:
                newDefaultAerobic = [NSEntityDescription insertNewObjectForEntityForName:@"DefaultAerobic" inManagedObjectContext:context];
                newDefaultAerobic.eventName = self.exerciseName.text;
                newDefaultAerobic.category = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithInteger:self.categoryCode] decimalValue ]];
                newDefaultAerobic.distance = [NSNumber numberWithInteger:[self.default1.text integerValue]];
                newDefaultAerobic.enabled = @(1);           // default is enabled on
                break;
                
            case kBicycling:
                newDefaultAerobic = [NSEntityDescription insertNewObjectForEntityForName:@"DefaultAerobic" inManagedObjectContext:context];
                newDefaultAerobic.eventName = self.exerciseName.text;
                newDefaultAerobic.category = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithInteger:self.categoryCode] decimalValue ]];
                newDefaultAerobic.enabled = @(1);           // default is enabled on
                newDefaultAerobic.totalTime = [Utilities convertTimeToNumber: self.default1.text];
                newDefaultAerobic.desiredHR = [NSNumber numberWithInteger:[self.default2.text integerValue]];
                newDefaultAerobic.cadence = [NSNumber numberWithInteger:[self.default3.text integerValue]];
                break;

            case kStretching:
                break;
                
            default:
                break;
        }

        // Save the context.
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        [self.setupDelegate eventDataSetupNotification];
    }
    
    if (self.editMode == NO)
    {  // if in edit mode no need to check for deleting an event from the pre-populated event list
        [self.delegate selectedEventSaved:self.exerciseName.text exerciseCategory:self.categoryCode];
    }
//    [ self resetDataEntry];
    
    // return tot he previous view controller
    [self.navigationController popViewControllerAnimated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
