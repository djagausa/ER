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

@property (nonatomic, strong) NSMutableArray        *weightExerciseEvents;
@property (nonatomic, strong) NSMutableArray        *aerobicExerciseEvents;
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
static NSString *scheduleCellId = @"scheduleCell";

@implementation SelectEventToAddTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.coreDataHelper = [[CoreDataHelper alloc]init];
    self.coreDataHelper.managedObjectContext = self.managedObjectContext;
    self.selectedEvent = [[SelectedEvent alloc]init];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;

    [self fetchPredefinedEvents];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

-(void)fetchPredefinedEvents
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"ExerciseSelection" ofType:@"plist"];
    self.categoryDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    self.weightExerciseEvents = self.categoryDictionary[@"WeightLifting"];
    self.aerobicExerciseEvents = self.categoryDictionary[@"Aerobic"];
    
    self.weightExerciseExistingEvents = [self.coreDataHelper fetchDefaultDataFor:@"DefaultWeightLifting" withSortKey:@"eventName" ascending:YES usePredicate:YES];
    self.aerobicExerciseExistingEvents = [self.coreDataHelper fetchDefaultDataFor:@"DefaultAerobic" withSortKey:@"eventName" ascending:YES usePredicate:YES];
  
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

- (SelectedEvent *)selectedEventDataIs
{
    return self.selectedEvent;
}

- (void)selectedEventSaved:(NSString *)eventName exerciseCategory:(ExerciseCategory)exerciseCategory
{
    switch (exerciseCategory) {
        case kWeights:
            for (WeightLiftingEvent *weightEvent in self.weightExerciseEventsCopy) {
                if ([eventName isEqualToString:[weightEvent valueForKey:@"Name"]]) {
                    [self.weightExerciseEventsCopy removeObject:weightEvent];
                    break;
                }
            }
            break;
            
        default:
            for (AerobicEvent *aerobicEvent in self.aerobicExerciseEventsCopy) {
                if ([eventName isEqualToString:[aerobicEvent valueForKey:@"Name"]]) {
                    [self.aerobicExerciseEventsCopy removeObject:aerobicEvent];
                    break;
                }
            }
            break;
    }
}

- (IBAction)newButtonSelected:(id)sender
{
    self.selectedEvent.eventCategory = -1;
    self.selectedEvent.eventName = @"";
    
    [self performSegueWithIdentifier: @"SetupEvent" sender:sender];
}

- (void)eventDataSetupNotification
{
    [self.eventAddedDelegate eventAdded];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.categoryDictionary.count+1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count;
    
    switch (section) {
        case ScheduleCategory:
        {
            count = 1;
            break;
        }
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
    
    UITableViewCell *cell;
    switch (indexPath.section) {
        case ScheduleCategory:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:scheduleCellId forIndexPath:indexPath];
            cell.textLabel.text = @"Setup Schedule";
            break;
        }
        case WeightCategory:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentification forIndexPath:indexPath];
            cell.textLabel.text = [NSString stringWithFormat:@"%@", self.weightExerciseEventsCopy[indexPath.row][@"Name"]];
            break;
        }
        
        case AerobicCategory:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentification forIndexPath:indexPath];
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
        case ScheduleCategory:
        {
            sectionTitle = @"Schedule Event";
            break;
        }
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
            break;
        }
        case WeightCategory:
        {
            self.selectedEvent.eventCategory = [self.weightExerciseEventsCopy[indexPath.row][@"Category"] integerValue];
            self.selectedEvent.eventName = self.weightExerciseEventsCopy[indexPath.row][@"Name"];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"scheduleSetupSegue"])
    {
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
    } else {
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
        SetupExrciseInfoViewController *setupExerciseViewController = [segue destinationViewController];
        setupExerciseViewController.setupDelegate = self;
        setupExerciseViewController.delegate = (id <AbstractEventDataDelegate> )self;
        setupExerciseViewController.editMode = NO;
    }
}


@end
