//
//  AbstractScheduleEventViewController.m
//  ExerciseRecording
//
//  Created by Douglas Alexander on 6/12/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import "AbstractScheduleEventViewController.h"
#import "ScheduleStatus.h"
#import "Schedule.h"
#import "DefaultAerobic.h"
#import "DefaultWeightLifting.h"
#import "AddEventDataViewController.h"
#import "Utilities.h"

@interface AbstractScheduleEventViewController ()

@property (nonatomic, assign) NSInteger                     numberOfSections;
@property (nonatomic, assign) NSInteger                     numberOfItems;
@property (nonatomic, strong) NSFetchedResultsController    *fetchedResultsController;
@property (nonatomic, strong) NSMutableDictionary           *scheduledlStatus;
@property (nonatomic, strong) ScheduleStatus                *currentScheduleStatus;
@end

static NSString *SectionHeaderCellIdentifier = @"SectionHeader";
static NSString *CellIdentifier = @"EventCell";

@implementation AbstractScheduleEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _selectedEvent = [[SelectedEvent alloc]init];
    
    _coreDataHelper = [[CoreDataHelper alloc] init];
    _coreDataHelper.managedObjectContext = self.managedObjectContext;

    _weightLiftingDefaultObjects = [[NSMutableArray alloc] init];
    _aerobicDefaultObjects = [[NSMutableArray alloc] init];
    _completedAerobicEvents = [[NSMutableArray alloc] init];
    _completedWeightEvents = [[NSMutableArray alloc] init];
    
    [self fetchTodaysCompleteEvents];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Delegate

- (SelectedEvent *)selectedEventDataIs
{
    return self.selectedEvent;
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = 0;
    
    if (self.weightLiftingDefaultObjects.count > 0)
    {
        count++;
    }
    
    if (self.aerobicDefaultObjects.count > 0)
    {
        count++;
    }
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    
    switch (section) {
        case 0:
            if (self.aerobicDefaultObjects.count > 0) {
                count = self.aerobicDefaultObjects.count;
            }
            else
            {
                count = self.weightLiftingDefaultObjects.count;
                
            }
            break;
            
        case 1:
            count = self.weightLiftingDefaultObjects.count;
            break;
            
        default:
            break;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    switch (indexPath.section) {
        case 0:
            if (self.aerobicDefaultObjects.count > 0)
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"EventCell" forIndexPath:indexPath];
                DefaultAerobic *event = [self.aerobicDefaultObjects objectAtIndex:indexPath.row];
                cell.textLabel.text = event.eventName;
                if ([self eventHasBeenPerfomed:event.eventName eventCategory:AerobicCategory]) {
                    cell.backgroundColor = [UIColor greenColor];
                }
            }
            else
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"EventCell" forIndexPath:indexPath];
                DefaultWeightLifting *event = [self.weightLiftingDefaultObjects objectAtIndex:indexPath.row];
                cell.textLabel.text = event.eventName;
                if ([self eventHasBeenPerfomed:event.eventName eventCategory:WeightCategory]) {
                    cell.backgroundColor = [UIColor greenColor];
                }
            }
            break;
            
        case 1:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"EventCell" forIndexPath:indexPath];
            DefaultWeightLifting *event = [self.weightLiftingDefaultObjects objectAtIndex:indexPath.row];
            cell.textLabel.text = event.eventName;
            if ([self eventHasBeenPerfomed:event.eventName eventCategory:WeightCategory]) {
                cell.backgroundColor = [UIColor greenColor];
            }
        }
            break;
            
        default:
            break;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            if (self.aerobicDefaultObjects.count > 0)
            {
                self.defaultAerobic = [self.aerobicDefaultObjects objectAtIndex:indexPath.row];
                self.selectedEvent.defaultAerobicData = self.defaultAerobic;
                self.selectedEvent.eventName = self.defaultAerobic.eventName;
                self.selectedEvent.eventCategory = [self.defaultAerobic.category integerValue];
            }
            else
            {
                self.defaultWeightLifting = [self.weightLiftingDefaultObjects objectAtIndex:indexPath.row];
                self.selectedEvent.defaultWeightLiftingData = self.defaultWeightLifting;
                self.selectedEvent.eventName = self.defaultWeightLifting.eventName;
                self.selectedEvent.eventCategory = [self.defaultWeightLifting.category integerValue];
            }
            break;
            
        case 1:
        {
            self.defaultWeightLifting = [self.weightLiftingDefaultObjects objectAtIndex:indexPath.row];
            self.selectedEvent.defaultWeightLiftingData = self.defaultWeightLifting;
            self.selectedEvent.eventName = self.defaultWeightLifting.eventName;
            self.selectedEvent.eventCategory = [self.defaultWeightLifting.category integerValue];
        }
            break;
            
        default:
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *headerTitle;
    
    switch (section) {
        case 0:
            if (self.aerobicDefaultObjects.count > 0) {
                headerTitle = @"Aerobic Events";
            }
            else
            {
                headerTitle = @"Weight Lifting Events";
            }
            break;
            
        case 1:
            headerTitle = @"Weight Lifting Events";
            break;
            
        default:
            break;
    }
    
    return headerTitle;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return SECTION_HEADER_HEIGHT;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (BOOL)eventHasBeenPerfomed:(NSString *)eventName eventCategory:(EventCateogory)eventCategory
{
    switch (eventCategory) {
        case AerobicCategory:
            for (AerobicEvent *aerobicEvent in self.completedAerobicEvents) {
                if ([aerobicEvent.defaultEvent.eventName isEqualToString:eventName]) {
                    return YES;
                }
            }
            break;
        case WeightCategory:
            for (WeightLiftingEvent *weightEvent in self.completedWeightEvents) {
                if ([weightEvent.defaultEvent.eventName isEqualToString:eventName]) {
                    return YES;
                }
            }
            break;
        default:
            break;
    }
    return NO;
}

#pragma mark - Core Data
- (NSNumber *)fetchNumberOfWeeksForSchedule:(NSString *)scheduleName
{
    NSNumber *weeks = @(0);
    Schedule *schedule;
    
    NSArray *schedules = [self.coreDataHelper fetchDataFor:scheduleEntityName withPredicate:@{@"propertyName" : @"scheduleName", @"value" : scheduleName} sortKey:nil];
    
    if ([schedules count] > 0) {
        schedule = [schedules firstObject];
        return schedule.numberOfWeeks;
    }
    
    return weeks;
}

- (NSNumber *)fetchRepeatCountForSchedule:(NSString *)scheduleName
{
    NSNumber *repeatCount = @(0);
    Schedule *schedule;
    
    NSArray *schedules = [self.coreDataHelper fetchDataFor:scheduleEntityName withPredicate:@{@"propertyName" : @"scheduleName", @"value" : scheduleName} sortKey:nil];
    
    if ([schedules count] > 0) {
        schedule = [schedules firstObject];
        return schedule.repeatCount;
    }
    
    return repeatCount;
}

- (NSNumber *)fetchOpertionalModeCountForSchedule:(NSString *)scheduleName
{
    NSNumber *opertionalMode = @(0);
    Schedule *schedule;
    
    NSArray *schedules = [self.coreDataHelper fetchDataFor:scheduleEntityName withPredicate:@{@"propertyName" : @"opertionalMode", @"value" : scheduleName} sortKey:nil];
    
    if ([schedules count] > 0) {
        schedule = [schedules firstObject];
        return schedule.operationalMode;
    }
    
    return opertionalMode;
}


- (void) fetchEvents
{
    self.weightLiftingDefaultObjects = [[self.coreDataHelper fetchDefaultDataFor:weightLiftingDefaultEventsEntityName withSortKey:@"eventName" ascending:YES usePredicate:YES] mutableCopy];
    self.aerobicDefaultObjects = [[self.coreDataHelper fetchDefaultDataFor:aerobicDefaultEventsEntityName withSortKey:@"eventName" ascending:YES usePredicate:YES] mutableCopy];
    
#ifdef debug
    for (DefaultWeightLifting *defaultWL in self.weightLiftingDefaultObjects) {
        NSLog(@"Weight Event Name: %@",defaultWL.eventName);
    }
    
    for (DefaultAerobic *defaultA in self.aerobicDefaultObjects) {
        NSLog(@"Aerobic Event Name: %@",defaultA.eventName);
    }
#endif
}


- (void)fetchTodaysCompleteEvents
{
    // implement in class
}

/*
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}
*/

@end
