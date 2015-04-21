//
//  SelectEventToAddTableViewController.m
//  ExerciseRecording
//
//  Created by Douglas Alexander on 4/15/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import "SelectEventToAddTableViewController.h"
#import "SetupExerciseInfoViewController.h"
#import "DefaultEventSelection.h"
#import "Support.h"

@interface SelectEventToAddTableViewController ()

@property (nonatomic, strong) NSArray        *weightExerciseEvents;
@property (nonatomic, strong) NSArray        *aerobicExerciseEvents;
@property (nonatomic, strong) NSDictionary          *categoryDictionary;
@property (nonatomic, strong) DefaultEventSelection *defaultEventSelection;

- (IBAction)newButtonSelected:(id)sender;

@end

static NSString *cellIdentification = @"SelectEventToAddCell";

@implementation SelectEventToAddTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
     self.clearsSelectionOnViewWillAppear = NO;
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"ExerciseSelection" ofType:@"plist"];
    self.categoryDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];

    self.weightExerciseEvents = self.categoryDictionary[@"WeightLifting"];
    self.aerobicExerciseEvents = self.categoryDictionary[@"Aerobic"];
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"Name" ascending:YES];
    self.weightExerciseEvents = [self.weightExerciseEvents sortedArrayUsingDescriptors: [NSArray arrayWithObjects:descriptor,nil]];
    self.aerobicExerciseEvents = [self.aerobicExerciseEvents sortedArrayUsingDescriptors: [NSArray arrayWithObjects:descriptor,nil]];
    self.defaultEventSelection = [[DefaultEventSelection alloc]init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (DefaultEventSelection *)eventDataHasChangedTo
{
    return self.defaultEventSelection;
}

- (IBAction)newButtonSelected:(id)sender
{
    self.defaultEventSelection.eventCategory = @(-1);
    self.defaultEventSelection.eventName = @"";
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.categoryDictionary.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count;
    
    switch (section) {
        case WeightCategory:
        {
            count = self.weightExerciseEvents.count;
            break;
        }
            
        case AerobicCategory:
        {
            count = self.aerobicExerciseEvents.count;
            break;
        }
            
        default:
            break;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentification forIndexPath:indexPath];
    switch (indexPath.section) {
        case WeightCategory:
        {
            cell.textLabel.text = [NSString stringWithFormat:@"%@", self.weightExerciseEvents[indexPath.row][@"Name"]];
            break;
        }
        
        case AerobicCategory:
        {
            cell.textLabel.text = [NSString stringWithFormat:@"%@", self.aerobicExerciseEvents[indexPath.row][@"Name"]];
        }
            
        default:
            break;
    }
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle;
    
    switch (section) {
        case WeightCategory:
        {
            sectionTitle = @"Weight Event";
            break;
        }
            
        case AerobicCategory:
        {
            sectionTitle = @"Aerobic Event";
            break;
        }
            
        default:
            break;
    }
    return sectionTitle;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case AerobicCategory:
        {
            self.defaultEventSelection.eventCategory = self.aerobicExerciseEvents[indexPath.row][@"Category"];
            self.defaultEventSelection.eventName = self.aerobicExerciseEvents[indexPath.row][@"Name"];
            break;
        }
        case WeightCategory:
        {
            self.defaultEventSelection.eventCategory = self.weightExerciseEvents[indexPath.row][@"Category"];
            self.defaultEventSelection.eventName = self.weightExerciseEvents[indexPath.row][@"Name"];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([[segue identifier] isEqualToString:@"SetupWithDefaultEvent"]) {
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
        SetupExrciseInfoViewController *setupExerciseViewController = [segue destinationViewController];
        setupExerciseViewController.delegate = self;
//    }

//    if ([[segue identifier] isEqualToString:@"SetupWithNewEvent"]) {
//        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
//    } else if ([[segue identifier] isEqualToString:@"SetupWithDefaultEvent"]) {
//        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
//        
//    }
}


@end
