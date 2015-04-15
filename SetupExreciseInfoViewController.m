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


@interface SetupExrciseInfoViewController ()

@property (nonatomic, strong) NSArray *exerciseCategory;

@end

@implementation SetupExrciseInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[self exerciseName] setDelegate: self];
    [[self default1] setDelegate: self];
    [[self default2] setDelegate: self];
    [[self default3] setDelegate: self];
    
    [[self exerciseActivitySelectionTable] registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ExerciseActivityCell"];
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"ExerciseCategory" ofType:@"plist"];
    NSDictionary *categoryDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    self.exerciseCategory = categoryDictionary[@"ExerciseCategory"];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    labelView.textAlignment = NSTextAlignmentLeft;
    labelView.backgroundColor = [UIColor blueColor];
    labelView.textColor = [UIColor whiteColor];
    labelView.text = @"Exercise Categories";
    
    [headerView addSubview:labelView];
    self.exerciseActivitySelectionTable.tableHeaderView = headerView;
    
    self.categoryCode = self.exerciseCategory.count;
    
    [[self saveButton] setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [[self saveButton] setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [[self saveButton] setEnabled:NO];
//    self.saveButton.userInteractionEnabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self verifyParametersReceived];
    return YES;
}

- (void) verifyParametersReceived
{
    if (self.exerciseName.text.length > 0 && self.categoryCode < self.exerciseCategory.count )
    {
        [[self saveButton] setEnabled:YES];
    }
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.exerciseCategory.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ExerciseActivityCell" forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    if (indexPath.row == self.categoryCode) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.text = [NSString stringWithFormat:@"%@", self.exerciseCategory[indexPath.row][@"Name"]];
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.categoryCode = [self.exerciseCategory[indexPath.row][@"Code"]integerValue];
    [self verifyParametersReceived];
    
    switch (self.categoryCode) {
        case kWeights:     // weights
            [self enableTwoInputs];
            [self weightText];
            break;
        
        case kWalking:
        case kRunning:
            [self enableOneInput];
            [self walkingText];
            break;
            
        case kStretching:
            [self enableZeroInputs];
            break;
            
        case kEliptical:
            [self enableOneInput];
            [self elipticalText];
          break;
        
        case kBicycling:
            [self enableThreeInputs];
            [self bicyclingText];
            break;
            
        default:
            break;
    }

    [tableView reloadData];
    
}

- (void)enableThreeInputs
{
    [self.default1 setEnabled:YES];
    [self.default1 setHidden:NO];
    [self.default2 setEnabled:YES];
    [self.default2 setHidden:NO];
    [self.default3 setEnabled:YES];
    [self.default3 setHidden:NO];
}

- (void)enableTwoInputs
{
    [self.default1 setEnabled:YES];
    [self.default1 setHidden:NO];
    [self.default2 setEnabled:YES];
    [self.default2 setHidden:NO];
    [self.default3 setEnabled:NO];
    [self.default3 setHidden:YES];
}

- (void)enableOneInput
{
    [self.default1 setEnabled:YES];
    [self.default1 setHidden:NO];
    [self.default2 setEnabled:NO];
    [self.default2 setHidden:YES];
    [self.default3 setEnabled:NO];
    [self.default3 setHidden:YES];
}

- (void)enableZeroInputs
{
    [self.default1 setEnabled:NO];
    [self.default1 setHidden:YES];
    [self.default2 setEnabled:NO];
    [self.default2 setHidden:YES];
    [self.default3 setEnabled:NO];
    [self.default3 setHidden:YES];
}

- (void)resetDataEntry
{
    self.exerciseName.text = @"";
    self.categoryCode = self.exerciseCategory.count;
    [self.exerciseActivitySelectionTable reloadData];
    [[self saveButton] setEnabled:NO];
    [self.default1 setEnabled:NO];
    [self.default2 setEnabled:NO];
    [self.default3 setEnabled:NO];
    [self.default1 setHidden:YES];
    [self.default2 setHidden:YES];
    [self.default3 setHidden:YES];
}

- (void)weightText
{
    self.default1.text = @"Default Weight";
    self.default1.placeholder = @"Default Weight";
    self.default2.text = @"Default Reps";
    self.default2.placeholder = @"Default Reps";
}

-  (void)walkingText
{
    self.default1.text = @"Default Miles";
    self.default1.placeholder = @"Default Miles";
}

- (void)stretchingText
{
    
}

- (void)bicyclingText
{
    self.default1.text = @"Default Time";
    self.default1.placeholder = @"Default Time";
    self.default2.text = @"Default HR";
    self.default2.placeholder = @"Default HR";
    self.default3.text = @"Default Cadance";
    self.default3.placeholder = @"Default Cadance";
    [self.default3 setFont:[UIFont systemFontOfSize:12.0f]];
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
    
    switch (self.categoryCode) {
        case kWeights:     // weights
            newDefaultWeightLifting = [NSEntityDescription insertNewObjectForEntityForName:@"DefaultWeightLifting" inManagedObjectContext:context];
            
            newDefaultWeightLifting.eventName = self.exerciseName.text;
            newDefaultWeightLifting.category = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithInteger:self.categoryCode] decimalValue ]];
            newDefaultWeightLifting.weight = [NSNumber numberWithInteger:[self.default1.text integerValue]];
            newDefaultWeightLifting.numOfReps = [NSNumber numberWithInteger:[self.default2.text integerValue]];
            newDefaultWeightLifting.enabled = [NSNumber numberWithBool:self.enableSwitch.isOn];
            break;
            
        case kWalking:
        case kRunning:
        case kEliptical:
            newDefaultAerobic = [NSEntityDescription insertNewObjectForEntityForName:@"DefaultAerobic" inManagedObjectContext:context];
            newDefaultAerobic.eventName = self.exerciseName.text;
            newDefaultAerobic.category = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithInteger:self.categoryCode] decimalValue ]];
            newDefaultAerobic.category = [NSNumber numberWithInt:kEliptical];
            newDefaultAerobic.enabled = [NSNumber numberWithBool:self.enableSwitch.isOn];
            break;
            
        case kBicycling:
            newDefaultAerobic = [NSEntityDescription insertNewObjectForEntityForName:@"DefaultAerobic" inManagedObjectContext:context];
            newDefaultAerobic.eventName = self.exerciseName.text;
            newDefaultAerobic.category = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithInteger:self.categoryCode] decimalValue ]];
            newDefaultAerobic.enabled = [NSNumber numberWithBool:self.enableSwitch.isOn];
            newDefaultAerobic.totalTime = [NSNumber numberWithInteger:[self.default1.text integerValue]];
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
    [ self resetDataEntry];
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
