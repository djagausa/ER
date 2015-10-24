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
#import "ScheduledEventInfo.h"

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
@property (nonatomic, strong) ScheduledEventInfo    *scheduledEventInfo;

- (IBAction)newButtonSelected:(id)sender;

@end

static NSString *cellIdentification = @"SelectEventToAddCell";
static NSString *scheduleCellId = @"scheduleCell";

@implementation SelectEventToAddTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _coreDataHelper = [[CoreDataHelper alloc]init];
    _coreDataHelper.managedObjectContext = self.managedObjectContext;
    _selectedEvent = [[SelectedEvent alloc]init];
    _scheduledEventInfo = [[ScheduledEventInfo alloc]init];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;

    [self fetchPredefinedEvents];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

-(void)fetchPredefinedEvents
{
    NSMutableArray *weightEvents;
    NSMutableArray *aerobicEvents;
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"ExerciseSelection" ofType:@"plist"];
    self.categoryDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    self.weightExerciseEvents = self.categoryDictionary[@"WeightLifting"];
    self.aerobicExerciseEvents = self.categoryDictionary[@"Aerobic"];
    
    self.weightExerciseExistingEvents = [self.coreDataHelper fetchDefaultDataFor:@"DefaultWeightLifting" withSortKey:@"eventName" ascending:YES usePredicate:YES];
    self.aerobicExerciseExistingEvents = [self.coreDataHelper fetchDefaultDataFor:@"DefaultAerobic" withSortKey:@"eventName" ascending:YES usePredicate:YES];
  
    weightEvents = [NSMutableArray arrayWithArray:self.weightExerciseEvents];
    aerobicEvents = [NSMutableArray arrayWithArray:self.aerobicExerciseEvents];
    
    // eliminate events that have already been added
    for (DefaultWeightLifting *defaultWL in self.weightExerciseExistingEvents) {
        for (int i = 0; i < weightEvents.count; ++i) {
            if ([defaultWL.eventName isEqualToString: weightEvents [i][@"Name"]])
            {
                [weightEvents removeObjectAtIndex:i];
                break;
            }
        }
    }
    
    for (DefaultAerobic *defaultA in self.aerobicExerciseExistingEvents) {
        for (int i = 0; i< aerobicEvents.count; ++i) {
            if ([defaultA.eventName isEqualToString: aerobicEvents[i][@"Name"]])
            {
                [aerobicEvents removeObjectAtIndex:i];
                break;
            }
        }
    }
    NSArray *sortedWeight = [weightEvents sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *name1 = [(NSDictionary *)obj1 objectForKey:@"Name"];
        NSString *name2 = [(NSDictionary *)obj2 objectForKey:@"Name"];
        return [name1 compare:name2];
    }];
    self.weightExerciseEventsCopy = [NSMutableArray arrayWithArray:sortedWeight];
    
    NSArray *sortedAerobic = [aerobicEvents sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *name1 = [(NSDictionary *)obj1 objectForKey:@"Name"];
        NSString *name2 = [(NSDictionary *)obj2 objectForKey:@"Name"];
        return [name1 compare:name2];
    }];
    self.aerobicExerciseEventsCopy = [NSMutableArray arrayWithArray:sortedAerobic];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (SelectedEvent *)selectedEventDataIs
{
    return self.selectedEvent;
}

- (ScheduledEventInfo *)scheduledEventIs
{
    return self.scheduledEventInfo;
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
    
    [self performSegueWithIdentifier: @"SetupEventSegue" sender:sender];
}

- (void)eventDataSetupNotification
{
    [self.eventAddedDelegate eventAdded];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.aerobicExerciseEventsCopy count] > 0) {
         return self.categoryDictionary.count+1;
    } else {
        return self.categoryDictionary.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    
    switch (section) {
        case 0:
        {
            count = 1;
            break;
        }
        case 1:
        {
            if ([self.aerobicExerciseEventsCopy count] > 0) {
                count = self.aerobicExerciseEventsCopy.count;
            } else {
                count = self.weightExerciseEventsCopy.count;
            }
            break;
        }
            
        case 2:
        {
            if ([self.weightExerciseEventsCopy count] > 0) {
                count = self.weightExerciseEventsCopy.count;
            }
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
        case 0:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:scheduleCellId forIndexPath:indexPath];
            cell.textLabel.text = @"Setup Schedule";
            break;
        }
        case 1:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentification forIndexPath:indexPath];

            if ([self.aerobicExerciseEventsCopy count] > 0) {
                cell.textLabel.text = [NSString stringWithFormat:@"%@", self.aerobicExerciseEventsCopy[indexPath.row][@"Name"]];
            } else {
                cell.textLabel.text = [NSString stringWithFormat:@"%@", self.weightExerciseEventsCopy[indexPath.row][@"Name"]];
            }
            break;
        }
        
        case 2:
        {
            if ([self.weightExerciseEventsCopy count] > 0) {
                cell = [tableView dequeueReusableCellWithIdentifier:cellIdentification forIndexPath:indexPath];
                cell.textLabel.text = [NSString stringWithFormat:@"%@", self.weightExerciseEventsCopy[indexPath.row][@"Name"]];
            }
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
        case 0:
        {
            sectionTitle = @"Schedule Event";
            break;
        }
        case 1:
        {
            if ([self.aerobicExerciseEventsCopy count] > 0) {
                sectionTitle = @"Aerobic Event";
            } else {
                sectionTitle = @"Weight Event";
            }
            break;
        }
            
        case 2:
        {
            if ([self.weightExerciseEventsCopy count] > 0) {
                sectionTitle = @"Weight Event";
            }
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
        case 0:
        {
            self.scheduledEventInfo.scheduleEditMode = 0;
            break;
        }
        case 1:
        {
            if ([self.aerobicExerciseEventsCopy count] > 0) {
                self.selectedEvent.eventCategory = [self.aerobicExerciseEventsCopy[indexPath.row][@"Category"] integerValue];
                self.selectedEvent.eventName = self.aerobicExerciseEventsCopy[indexPath.row][@"Name"];
            } else {
                self.selectedEvent.eventCategory = [self.weightExerciseEventsCopy[indexPath.row][@"Category"] integerValue];
                self.selectedEvent.eventName = self.weightExerciseEventsCopy[indexPath.row][@"Name"];
            }
            break;
        }
        case 2:
        {
            if ([self.weightExerciseEventsCopy count] > 0) {
                self.selectedEvent.eventCategory = [self.weightExerciseEventsCopy[indexPath.row][@"Category"] integerValue];
                self.selectedEvent.eventName = self.weightExerciseEventsCopy[indexPath.row][@"Name"];
            }
            break;
        }
            
        default:
            break;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return SECTION_HEADER_HEIGHT;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"scheduleSetupSegue"])
    {
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
        CreateSheduleViewController *createScheduleViweCintroller = [segue destinationViewController];
        createScheduleViweCintroller.createScheduleDelegate = self;
    } else {
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
        SetupExrciseInfoViewController *setupExerciseViewController = [segue destinationViewController];
        setupExerciseViewController.setupDelegate = self;
        setupExerciseViewController.delegate = (id <AbstractEventDataDelegate> )self;
        setupExerciseViewController.editMode = NO;
    }
}


@end
