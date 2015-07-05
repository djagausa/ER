//
//  EditEventTableViewController.m
//  ExerciseRecording
//
//  Created by Douglas Alexander on 4/23/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import "EditEventTableViewController.h"
#import "CoreDataHelper.h"
#import "DefaultWeightLifting.h"
#import "DefaultAerobic.h"
#import "Support.h"
#import "SelectedEvent.h"
#import "Schedule.h"

@interface EditEventTableViewController ()

@property (nonatomic, strong) NSArray               *weightLiftingDefaultObjects;
@property (nonatomic, strong) NSArray               *aerobicDefaultObjects;
@property (nonatomic, strong) NSMutableArray        *weightLiftingDefaultObjectsCopy;
@property (nonatomic, strong) NSMutableArray        *aerobicDefaultObjectsCopy;
@property (nonatomic, strong) CoreDataHelper        *coreDataHelper;
@property (nonatomic, strong) DefaultWeightLifting  *defaultWeightLifting;
@property (nonatomic, strong) DefaultAerobic        *defaultAerobic;
@property (nonatomic, strong) SelectedEvent         *selectedEvent;
@property (nonatomic, strong) NSArray               *schedules;
@property (nonatomic, strong) ScheduledEventInfo    *scheduledEventInfo;

@end

@implementation EditEventTableViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    _selectedEvent = [[SelectedEvent alloc]init];
    _schedules = [[NSArray alloc] init];
    _scheduledEventInfo = [[ScheduledEventInfo alloc] init];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _coreDataHelper = [[CoreDataHelper alloc] init];
    _coreDataHelper.managedObjectContext = self.managedObjectContext;
    
    [self fetchEvents];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (SelectedEvent *)selectEventDataIs
{
    return self.selectedEvent;
}

#pragma  mark - Deleagate
- (ScheduledEventInfo *)scheduledEventIs
{
    self.scheduledEventInfo.scheduleEditMode = kScheduleEdit;
    return self.scheduledEventInfo;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger count = 1;
    
    if (self.weightLiftingDefaultObjectsCopy.count > 0)
    {
        count++;
    }
    
    if (self.aerobicDefaultObjectsCopy.count > 0)
    {
        count++;
    }
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    
    switch (section) {
        case 0:     // calendar section
            count = [self.schedules count];
            break;
        case 1:
            if (self.aerobicDefaultObjectsCopy.count > 0) {
                count = self.aerobicDefaultObjectsCopy.count;
            }
            else
            {
                count = self.weightLiftingDefaultObjectsCopy.count;
                
            }
            break;
            
        case 2:
            count = self.weightLiftingDefaultObjectsCopy.count;
            break;
            
        default:
            break;
    }
    return count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    NSNumber *eventEnable;
    

    switch (indexPath.section) {
        case 0:     // scheduled section
            cell = [tableView dequeueReusableCellWithIdentifier:@"ScheduleCell" forIndexPath:indexPath];
            cell.textLabel.text = [[self.schedules objectAtIndex:indexPath.row] scheduleName];
            eventEnable = @(1);
            break;
            
        case 1:
            if (self.aerobicDefaultObjects.count > 0)
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"EditEventCell" forIndexPath:indexPath];
                DefaultAerobic *event = [self.aerobicDefaultObjectsCopy objectAtIndex:indexPath.row];
                cell.textLabel.text = event.eventName;
                eventEnable = event.enabled;
            }
            else
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"EditEventCell" forIndexPath:indexPath];
                DefaultWeightLifting *event = [self.weightLiftingDefaultObjectsCopy objectAtIndex:indexPath.row];
                cell.textLabel.text = event.eventName;
                eventEnable = event.enabled;
            }
            break;
            
        case 2:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"EditEventCell" forIndexPath:indexPath];
            DefaultWeightLifting *event = [self.weightLiftingDefaultObjectsCopy objectAtIndex:indexPath.row];
            cell.textLabel.text = event.eventName;
            eventEnable = event.enabled;
        }
            break;
            
        default:
            break;
    }
    if ([eventEnable isEqualToNumber:@(0)]) {
        cell.backgroundColor = [UIColor redColor];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }

    return cell;

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *headerTitle;
    
    switch (section) {
        case 0:     // schedule section
            headerTitle = @"Schedules";
            break;
        case 1:
            if (self.aerobicDefaultObjects.count > 0) {
                headerTitle = @"Aerobic Events";
            }
            else
            {
                headerTitle = @"Weight Lifting Events";
            }
            break;
            
        case 2:
            headerTitle = @"Weight Lifting Events";
            break;
            
        default:
            break;
    }
    
    return headerTitle;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:         // schedule section
        {
            Schedule *selectedSchedule = [self.schedules objectAtIndex:indexPath.row];
            self.scheduledEventInfo.scheduleName = selectedSchedule.scheduleName;
            self.scheduledEventInfo.numberOfWeeks = [selectedSchedule.numberOfWeeks integerValue];
        }
            break;
        case 1:
            if (self.aerobicDefaultObjects.count > 0)
            {
                DefaultAerobic *event = [self.aerobicDefaultObjectsCopy objectAtIndex:indexPath.row];
                self.selectedEvent.eventName = event.eventName;
                self.selectedEvent.eventCategory = [event.category integerValue];
            }
            else
            {
                DefaultWeightLifting *event = [self.weightLiftingDefaultObjectsCopy objectAtIndex:indexPath.row];
                self.selectedEvent.eventName = event.eventName;
                self.selectedEvent.eventCategory = [event.category integerValue];
            }
            break;
            
        case 2:
        {
            DefaultWeightLifting *event = [self.weightLiftingDefaultObjectsCopy objectAtIndex:indexPath.row];
            self.selectedEvent.eventName = event.eventName;
            self.selectedEvent.eventCategory = [event.category integerValue];
        }
            break;
            
        default:
            break;
    }

}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        switch (indexPath.section) {
            case 0:     // schedule section
                break;
            case 1:
                if (self.aerobicDefaultObjects.count > 0)
                {
                    [self.coreDataHelper deleteObject:self.aerobicDefaultObjectsCopy[indexPath.row]];
                    [self.aerobicDefaultObjectsCopy removeObjectAtIndex:indexPath.row];
                }
                else
                {
                    [self.coreDataHelper deleteObject:self.weightLiftingDefaultObjectsCopy[indexPath.row]];
                    [self.weightLiftingDefaultObjectsCopy removeObjectAtIndex:indexPath.row];
                }
                break;
                
            case 2:
            {
                [self.coreDataHelper deleteObject:self.weightLiftingDefaultObjectsCopy[indexPath.row]];
                [self.weightLiftingDefaultObjectsCopy removeObjectAtIndex:indexPath.row];
            }
                break;
                
            default:
                break;
        }
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self fetchEvents];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return SECTION_HEADER_HEIGHT;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"EditEventData"]) {
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
        EditSelectedEventTableViewController *editSelectedTableViewController = [segue destinationViewController];
        editSelectedTableViewController.delegate = self;
    } else if ([segue.identifier isEqualToString:@"EditSchedule"]) {
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
        CreateSheduleViewController *createScheduleViewController = [segue destinationViewController];
        createScheduleViewController.createScheduleDelegate = self;
    }
}

#pragma  mark - CoreData

- (void) fetchEvents
{
    self.weightLiftingDefaultObjects = [self.coreDataHelper fetchDefaultDataFor:weightLiftingDefaultEventsEntityName withSortKey:@"eventName" ascending:YES usePredicate:NO];
    self.aerobicDefaultObjects = [self.coreDataHelper fetchDefaultDataFor:aerobicDefaultEventsEntityName withSortKey:@"eventName" ascending:YES usePredicate:NO];
    self.weightLiftingDefaultObjectsCopy = [NSMutableArray arrayWithArray:self.weightLiftingDefaultObjects];
    self.aerobicDefaultObjectsCopy = [NSMutableArray arrayWithArray:self.aerobicDefaultObjects];
    
    self.schedules = [self.coreDataHelper fetchDataFor:scheduleEntityName withPredicate:nil sortKey:nil];
}

@end
