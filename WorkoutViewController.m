//
//  WorkoutViewController.m
//  ExerciseRecording
//
//  Created by Douglas Alexander on 6/8/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import "WorkoutViewController.h"
#import "ScheduleStatus.h"
#import "Schedule.h"
#import "DefaultAerobic.h"
#import "DefaultWeightLifting.h"
#import "ScheduleStatusFileHelper.h"
#import "utilities.h"
#import "ScheduledEventInfo.h"

@interface WorkoutViewController ()
@property (nonatomic, strong) NSMutableDictionary       *scheduledlStatus;
@property (weak, nonatomic) IBOutlet UIButton           *currentScheduleButton;
@property (nonatomic, strong) ScheduleStatus            *currentScheduleStatus;
@property (weak, nonatomic) IBOutlet UITableView        *eventTable;
@property (nonatomic, strong) ScheduleStatusFileHelper  *scheduleFileHelper;
@property (nonatomic, strong) Utilities                 *utilities;
@property (nonatomic, strong) ScheduledEventInfo        *scheduledEventInfo;
@end

@implementation WorkoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scheduleFileHelper = [[ScheduleStatusFileHelper alloc] init];
    self.currentScheduleStatus = [[ScheduleStatus alloc] init];
    self.scheduledEventInfo = [[ScheduledEventInfo alloc] init];
    
    [self fetchEvents];
    
    [self initializeCurrentScheduleButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - delegates
- (ScheduledEventInfo *)scheduleInfoIs
{
    // default day and week as this is a new schedule
    self.scheduledEventInfo.scheduleName = self.currentScheduleStatus.scheduleName;
    self.scheduledEventInfo.day = [self.currentScheduleStatus.day integerValue];
    self.scheduledEventInfo.week = [self.currentScheduleStatus.week integerValue];
    return self.scheduledEventInfo;
}

// determine if there is a active schedule running
- (void)initializeCurrentScheduleButton
{
    self.scheduledlStatus = [self.scheduleFileHelper readScheduleStatusFile];
    
    // if status file exists
    if (self.scheduledlStatus  != nil) {
    
        // if schedule is active then get schedule data
        if ([[self.scheduledlStatus objectForKeyedSubscript:activeKey] boolValue] == YES) {
            BOOL scheduleBumpResults;   // NO = schedule finished;  YES = schedule bumped

            self.currentScheduleStatus.scheduleName = [self.scheduledlStatus objectForKeyedSubscript:scheduleNameKey];
            self.currentScheduleStatus.day = [self.scheduledlStatus objectForKeyedSubscript:dayKey];
            self.currentScheduleStatus.week = [self.scheduledlStatus objectForKeyedSubscript:weekKey];
            self.currentScheduleStatus.lastUpdateDate = [self.scheduledlStatus objectForKeyedSubscript:lastUpdateDateKey];
            self.currentScheduleStatus.active = [[self.scheduledlStatus objectForKeyedSubscript:activeKey]integerValue];
            
            NSComparisonResult compareResults;
            compareResults = [[Utilities dateWithoutTime:self.currentScheduleStatus.lastUpdateDate] compare: [Utilities dateWithoutTime:[NSDate date]]];
            // NSOrderedAscending = bump schedule
            // NSOderedDescending = shouldn't happen (the last update date should never be beyound today)
            // NSOderedSame = use today's schedule
            
            // if last update day is earlier then today then bump the schedule by one day.
            if (compareResults == NSOrderedAscending) {
                // bunp the schedule by one day
                NSNumber *weeks = [self fetchNumberOfWeeksForSchedule:self.currentScheduleStatus.scheduleName];
                scheduleBumpResults = [self bumpScheduleByNumber:1 numberOfWeeks:[weeks integerValue]];
            } else {
                // use the schedule as is
                scheduleBumpResults = YES;
            }
            
            NSString *labelText;
            // if schedule is not done then setup the current schedule button with info and enable
            if (scheduleBumpResults == YES) {
                // setup the button title to the current schedule info and enable
                
                labelText = [NSString stringWithFormat:@"Continue %@ day %ld of week %ld", self.currentScheduleStatus.scheduleName, [self.currentScheduleStatus.day integerValue] +1, [self.currentScheduleStatus.week integerValue] +1];
                [self.currentScheduleButton setTitle:labelText forState:UIControlStateNormal];
                self.currentScheduleButton.enabled = YES;
            } else {
                // set the button title to schedule finsihed and disable
                
                labelText = [NSString stringWithFormat:@"Schedue Finished"];
                [self.currentScheduleButton setTitle:labelText forState:UIControlStateDisabled];
                self.currentScheduleButton.enabled = NO;
            }
        }
    }
}

- (BOOL)bumpScheduleByNumber:(NSInteger )bumpNumber numberOfWeeks:(NSInteger )numberOfWeeks
{
    BOOL results;       // NO = schedule finsihed;  YES = scheduled bumped
    NSNumber *day = self.currentScheduleStatus.day;
    NSNumber *week = self.currentScheduleStatus.week;
    
    // bump the day
    day = @([day integerValue] + bumpNumber);
    
    // if day exceeds a week then select the next week
    if ([day integerValue] > 6) {
        day = @(0);
        
        // bump the week
        week = @([week integerValue] + 1);
        
        // if week exceeds number of scheduled weeks then schedule completed
        if ([week integerValue] > numberOfWeeks) {
            // workout finished
            results = NO;
            return results;
        }
    }
    // setup current schedule data with updated values
    self.currentScheduleStatus.day = day;
    self.currentScheduleStatus.week = week;
    self.currentScheduleStatus.lastUpdateDate = [NSDate date];
    
    // save updated schedule info
    [self.scheduleFileHelper writeScheduleStatusFile:self.currentScheduleStatus];
    
    // the schedule has been succesfully bumped
    results = YES;

    return results;
}
#pragma mark - Delegates
- (SelectedEvent *)selectedEventDataIs
{
    return self.selectedEvent;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"addSingleEventData"]) {
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
        AddEventDataViewController *addEventDataVC = [segue destinationViewController];
        addEventDataVC.delegate = self;
    } else if ([segue.identifier isEqualToString:@"startNewSchedule"]){
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
    } else if ([segue.identifier isEqualToString:@"continueExistingSchedule"]){
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
        WorkoutScheduledEventViewController *workoutScheduledEventViewController = [segue destinationViewController];
        workoutScheduledEventViewController.workoutScheduleDelegate = self;
        workoutScheduledEventViewController.managedObjectContext = self.managedObjectContext;
    }
}


@end
