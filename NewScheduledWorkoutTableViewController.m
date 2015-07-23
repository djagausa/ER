//
//  NewScheduledWorkoutTableViewController.m
//  ExerciseRecording
//
//  Created by Douglas Alexander on 6/9/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import "NewScheduledWorkoutTableViewController.h"
#import "Schedule.h"
#import "ScheduledEventInfo.h"
#import "ScheduleStatusFileHelper.h"
#import "ScheduleStatus.h"

@interface NewScheduledWorkoutTableViewController ()
@property (nonatomic, strong) NSArray                   *schedules;
@property (nonatomic, strong) ScheduledEventInfo        *scheduleInfo;
@property (nonatomic, strong) ScheduleStatusFileHelper  *schduleFileHelper;
@end


static NSString *cellName = @"ScheduleCell";

@implementation NewScheduledWorkoutTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    _scheduleInfo = [[ScheduledEventInfo alloc] init];
    _schduleFileHelper =[[ScheduleStatusFileHelper alloc] init];
    
    [self fetchSchedules];
 }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.schedules.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *headerTitle = @"Configured Schedules";
    
    return headerTitle;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName forIndexPath:indexPath];
    
    cell.textLabel.text = [[self.schedules objectAtIndex:indexPath.row] scheduleName];
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.scheduleInfo.scheduleName = [[self.schedules objectAtIndex:indexPath.row] scheduleName];
    
    [self saveNewScheduleInfo];
}

#pragma mark - delegates
- (ScheduledEventInfo *)scheduleInfoIs
{
    // default day and week as this is a new schedule
    self.scheduleInfo.day = 0;
    self.scheduleInfo.week = 0;
    return self.scheduleInfo;
}

#pragma mark - Core Data
- (void)fetchSchedules
{
    self.schedules = [self.coreDataHelper fetchDataFor:scheduleEntityName withPredicate:nil sortKey:nil];
}

- (void)saveNewScheduleInfo
{
    // save schedule info: name; today's date; day=0; week=0
    ScheduleStatus *scheduleStatus = [[ScheduleStatus alloc] init];
    
    scheduleStatus.scheduleName = self.scheduleInfo.scheduleName;
    scheduleStatus.day = @(0);
    scheduleStatus.week = @(0);
    scheduleStatus.lastUpdateDate = [NSDate date];
    scheduleStatus.active = @(1);                   // TRUE = active
    scheduleStatus.repeat = @(self.scheduleInfo.repeatCount);
    
    [self.schduleFileHelper writeScheduleStatusFile:scheduleStatus];
    
    [self.scheduleWorkoutInfoDelegate newScheduleInfoIs:self.scheduleInfo];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    WorkoutScheduledEventViewController *workoutScheduledEventViewController = [segue destinationViewController];
    workoutScheduledEventViewController.workoutScheduleDelegate = self;
    workoutScheduledEventViewController.managedObjectContext = self.managedObjectContext;
}


@end
