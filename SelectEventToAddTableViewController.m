//
//  SelectEventToAddTableViewController.m
//  ExerciseRecording
//
//  Created by Douglas Alexander on 4/15/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import "SelectEventToAddTableViewController.h"
#import "SetupExerciseInfoViewController.h"
#import "SelectedEvent.h"
#import "CoreDataHelper.h"
#import "Support.h"
#import "DefaultWeightLifting.h"
#import "DefaultAerobic.h"

@interface SelectEventToAddTableViewController ()

@property (nonatomic, strong) NSMutableArray               *weightExerciseEvents;
@property (nonatomic, strong) NSMutableArray               *aerobicExerciseEvents;
@property (nonatomic, strong) NSMutableArray        *weightExerciseEventsCopy;
@property (nonatomic, strong) NSMutableArray        *aerobicExerciseEventsCopy;
@property (nonatomic, strong) NSArray               *weightExerciseExistingEvents;
@property (nonatomic, strong) NSArray               *aerobicExerciseExistingEvents;

@property (nonatomic, strong) NSDictionary          *categoryDictionary;
@property (nonatomic, strong) SelectedEvent         *selectedEvent;
@property (nonatomic, strong) CoreDataHelper        *coreDataHelper;

- (IBAction)newButtonSelected:(id)sender;

@end

static NSString *cellIdentification = @"SelectEventToAddCell";

@implementation SelectEventToAddTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.coreDataHelper = [[CoreDataHelper alloc]init];
    self.coreDataHelper.managedObjectContext = self.managedObjectContext;
    self.selectedEvent = [[SelectedEvent alloc]init];
//    self.weightExerciseEvents = [[NSMutableArray alloc]init];
//    self.aerobicExerciseEvents = [[NSMutableArray alloc]init];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;

    [self fetchPredefinedEvents];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}
-(void)fetchPredefinedEvents
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"ExerciseSelection" ofType:@"plist"];
    self.categoryDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    self.weightExerciseEvents = self.categoryDictionary[@"WeightLifting"];
    self.aerobicExerciseEvents = self.categoryDictionary[@"Aerobic"];
    
    self.weightExerciseExistingEvents = [self.coreDataHelper fetchDefaultDataFor:@"DefaultWeightLifting" withSortKey:@"eventName" ascending:YES];
    self.aerobicExerciseExistingEvents = [self.coreDataHelper fetchDefaultDataFor:@"DefaultAerobic" withSortKey:@"eventName" ascending:YES];
  
    self.weightExerciseEventsCopy = [NSMutableArray arrayWithArray:self.weightExerciseEvents];
    self.aerobicExerciseEventsCopy = [NSMutableArray arrayWithArray:self.aerobicExerciseEvents];
    
    // eliminate events that have already been added
    for (DefaultWeightLifting *defaultWL in self.weightExerciseExistingEvents) {
        for (int i = 0; i < self.weightExerciseEventsCopy.count; ++i) {
            if ([defaultWL.eventName isEqualToString: self.weightExerciseEventsCopy [i][@"Name"]])
            {
                [self.weightExerciseEventsCopy removeObjectAtIndex:i];
                break;
            }
        }
    }
    
    for (DefaultAerobic *defaultA in self.aerobicExerciseExistingEvents) {
        for (int i = 0; i< self.aerobicExerciseEventsCopy.count; ++i) {
            if ([defaultA.eventName isEqualToString: self.aerobicExerciseEventsCopy[i][@"Name"]])
            {
                [self.aerobicExerciseEventsCopy removeObjectAtIndex:i];
                break;
            }
        }
    }
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"Name" ascending:YES];
    [self.weightExerciseEventsCopy sortedArrayUsingDescriptors: [NSArray arrayWithObjects:descriptor,nil]];
    [self.aerobicExerciseEventsCopy sortedArrayUsingDescriptors: [NSArray arrayWithObjects:descriptor,nil]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (SelectedEvent *)eventDataHasChangedTo
{
    return self.selectedEvent;
}

- (IBAction)newButtonSelected:(id)sender
{
    self.selectedEvent.eventCategory = -1;
    self.selectedEvent.eventName = @"";
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
            count = self.weightExerciseEventsCopy.count;
            break;
        }
            
        case AerobicCategory:
        {
            count = self.aerobicExerciseEventsCopy.count;
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
            cell.textLabel.text = [NSString stringWithFormat:@"%@", self.weightExerciseEventsCopy[indexPath.row][@"Name"]];
            break;
        }
        
        case AerobicCategory:
        {
            cell.textLabel.text = [NSString stringWithFormat:@"%@", self.aerobicExerciseEventsCopy[indexPath.row][@"Name"]];
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
            self.selectedEvent.eventCategory = [self.aerobicExerciseEventsCopy[indexPath.row][@"Category"] integerValue];
            self.selectedEvent.eventName = self.aerobicExerciseEventsCopy[indexPath.row][@"Name"];
            [self.aerobicExerciseEventsCopy removeObjectAtIndex:indexPath.row];
            break;
        }
        case WeightCategory:
        {
            self.selectedEvent.eventCategory = [self.weightExerciseEventsCopy[indexPath.row][@"Category"] integerValue];
            self.selectedEvent.eventName = self.weightExerciseEventsCopy[indexPath.row][@"Name"];
            [self.weightExerciseEventsCopy removeObjectAtIndex:indexPath.row];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
        SetupExrciseInfoViewController *setupExerciseViewController = [segue destinationViewController];
        setupExerciseViewController.delegate = self;
}


@end
