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
@property (weak, nonatomic) IBOutlet UIButton           *stopScheduleButton;
@property (weak, nonatomic) IBOutlet UIButton           *skipDayButton;
@property (weak, nonatomic) IBOutlet UIButton           *startNewScheduleButton;
@property (weak, nonatomic) IBOutlet UIButton           *reviewButton;
@property (weak, nonatomic) IBOutlet UIButton           *currentScheduleButton;
@property (weak, nonatomic) IBOutlet UITableView        *eventTable;
@property (weak, nonatomic) IBOutlet UIButton           *dayFinishedButton;
@property (nonatomic, strong) NSMutableDictionary       *scheduledlStatus;
@property (nonatomic, strong) ScheduleStatusFileHelper  *scheduleFileHelper;
@property (nonatomic, strong) Utilities                 *utilities;
@property (nonatomic, strong) ScheduledEventInfo        *scheduledEventInfo;
@property (nonatomic, strong) ScheduleStatus            *currentScheduleStatus;

- (IBAction)startNewScheduleAction:(id)sender;
- (IBAction)skipDayAction:(id)sender;
- (IBAction)stopScheduleAction:(id)sender;

@end

typedef NS_ENUM(NSInteger, ScheduleActivity) {
    kNewSchedule = 1,
    kSkipDay,
    kStopSchedule,
    kManualSchedule,
};

@implementation WorkoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _scheduleFileHelper = [[ScheduleStatusFileHelper alloc] init];
    _currentScheduleStatus = [[ScheduleStatus alloc] init];
    _scheduledEventInfo = [[ScheduledEventInfo alloc] init];
    
    [self formatButton:self.currentScheduleButton];
    [self formatButton:self.skipDayButton];
    [self formatButton:self.stopScheduleButton];
    [self formatButton:self.startNewScheduleButton];
    [self formatButton:self.reviewButton];
    [self formatButton:self.dayFinishedButton];
    self.startNewScheduleButton.enabled = YES;
        
    [self fetchEvents];
    
    BOOL scheduleStatus = [self isScheduleRunning];
    [self initializeCurrentScheduleButton:scheduleStatus];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startNewScheduleAction:(id)sender {
    // if a schedule is already running then provide alert indicating that it will terminate
    if (self.currentScheduleStatus.active == YES) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"The current schedule \"%@\" will be terminated!", self.currentScheduleStatus.scheduleName]
                                                       message:@"Would you like to continue?"
                                                      delegate:self
                                             cancelButtonTitle:@"Yes"
                                             otherButtonTitles:@"No", nil];
        alert.tag = kNewSchedule;
        [alert show];
    } else {
        [self performSegueWithIdentifier:@"startNewSchedule" sender:self];
    }
}

- (IBAction)skipDayAction:(id)sender
{
    // if a schedule is already running then provide alert indicating that it will terminate
    if (self.currentScheduleStatus.active == YES) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"Skip day %ld?", [self.currentScheduleStatus.day integerValue] +1 ]
                                                       message:@""
                                                      delegate:self
                                             cancelButtonTitle:@"Yes"
                                             otherButtonTitles:@"No", nil];
        alert.tag = kSkipDay;
        [alert show];
    }
}

- (void)bumpDay
{
    BOOL scheduleStatus;
    
    // bunp the schedule by one day
    NSNumber *weeks = [self fetchNumberOfWeeksForSchedule:self.currentScheduleStatus.scheduleName];
    NSNumber *repeatCount = [self fetchRepeatCountForSchedule:self.currentScheduleStatus.scheduleName];
    scheduleStatus = [self bumpScheduleByNumber:1 numberOfWeeks:[weeks integerValue] repeatCount:[repeatCount integerValue]];
    [self initializeCurrentScheduleButton:scheduleStatus];
}

- (IBAction)stopScheduleAction:(id)sender
{
    // if a schedule is already running then provide alert indicating that it will terminate
    if (self.currentScheduleStatus.active == YES) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"Stop the current schedule \"%@\"?", self.currentScheduleStatus.scheduleName]
                                                       message:@""
                                                      delegate:self
                                             cancelButtonTitle:@"Yes"
                                             otherButtonTitles:@"No", nil];
        alert.tag = kStopSchedule;
        [alert show];
    }
}

- (void)stopSchedule
{
    // save empty schedule status file
    [self.scheduleFileHelper clearScheduleStatusFileForSchedule:self.scheduledEventInfo.scheduleName];

    [self initializeCurrentScheduleButton:NO];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case kNewSchedule:
            if (buttonIndex == 0) {
                [self performSegueWithIdentifier:@"startNewSchedule" sender:self];
            }
            break;
        case kSkipDay:
            if (buttonIndex == 0) {
                [self bumpDay];
            }
            break;
        case kStopSchedule:
            if (buttonIndex == 0) {
                [self stopSchedule];
            }
            break;
        default:
            break;
    }
}

- (void)formatButton:(UIButton *)button
{
    button.layer.cornerRadius = 9.0f;
    button.layer.borderColor = [UIColor blueColor].CGColor;
    button.layer.borderWidth = 1.0f;
    button.enabled = NO;
}

#pragma mark - delegates
- (ScheduledEventInfo *)scheduleInfoIs
{
    // default day and week as this is a new schedule
    self.scheduledEventInfo.scheduleName = self.currentScheduleStatus.scheduleName;
    self.scheduledEventInfo.day = [self.currentScheduleStatus.day integerValue];
    self.scheduledEventInfo.scheduleEditMode = kScheduleNew;
    self.scheduledEventInfo.week = [self.currentScheduleStatus.week integerValue];
    return self.scheduledEventInfo;
}

- (SelectedEvent *)selectedEventDataIs
{
    return self.selectedEvent;
}

- (ScheduledEventInfo *)scheduledEventIs
{
    self.scheduledEventInfo.scheduleEditMode = kScheduleReview;
    self.scheduledEventInfo.scheduleName = self.currentScheduleStatus.scheduleName;
    self.scheduledEventInfo.day = [self.currentScheduleStatus.day integerValue];
    self.scheduledEventInfo.week = [self.currentScheduleStatus.week integerValue];
    return self.scheduledEventInfo;
}

- (void)newScheduleInfoIs:(ScheduledEventInfo *)newScheduleInfoIs
{
    // if status file exists
    if ([self readCurentScheduleInfoFromStatusFile] == YES) {
        [self initializeCurrentScheduleButton:YES];
    }
}

#pragma mark - Handle Schedule
- (BOOL)isScheduleRunning
{
    BOOL scheduleBumpResults = NO;   // NO = schedule finished;  YES = schedule bumped
    
    // if status file exists
    if ([self readCurentScheduleInfoFromStatusFile] == YES) {
        
        // if schedule is active then get schedule data
        if ([[self.scheduledlStatus objectForKeyedSubscript:activeKey] boolValue] == YES) {
            
            NSComparisonResult compareResults;
            compareResults = [[Utilities dateWithoutTime:self.currentScheduleStatus.lastUpdateDate] compare: [Utilities dateWithoutTime:[NSDate date]]];
            // NSOrderedAscending = bump schedule
            // NSOderedDescending = shouldn't happen (the last update date should never be beyound today)
            // NSOderedSame = use today's schedule
            
            // if last update day is earlier then today then bump the schedule by one day.
            if (compareResults == NSOrderedAscending) {
                // bunp the schedule by one day
                NSNumber *weeks = [self fetchNumberOfWeeksForSchedule:self.currentScheduleStatus.scheduleName];
                NSNumber *repeatCount = [self fetchRepeatCountForSchedule:self.currentScheduleStatus.scheduleName];
                scheduleBumpResults = [self bumpScheduleByNumber:1 numberOfWeeks:[weeks integerValue] repeatCount:[repeatCount integerValue]];
            } else {
                // use the schedule as is; this condition would occur if the workout was split into two sessions
                scheduleBumpResults = YES;
            }
        }
    }
    return scheduleBumpResults;
}

- (BOOL)readCurentScheduleInfoFromStatusFile
{
    BOOL fileRead = NO;         // NO = no file;    YES = file read
    self.scheduledlStatus = [self.scheduleFileHelper readScheduleStatusFile];
    
    // if status file exists
    if (self.scheduledlStatus  != nil) {
        
        // if schedule is active then get schedule data
        if ([[self.scheduledlStatus objectForKeyedSubscript:activeKey] boolValue] == YES) {
            
            self.currentScheduleStatus.scheduleName = [self.scheduledlStatus objectForKeyedSubscript:scheduleNameKey];
            self.currentScheduleStatus.day = [self.scheduledlStatus objectForKeyedSubscript:dayKey];
            self.currentScheduleStatus.week = [self.scheduledlStatus objectForKeyedSubscript:weekKey];
            self.currentScheduleStatus.lastUpdateDate = [self.scheduledlStatus objectForKeyedSubscript:lastUpdateDateKey];
            self.currentScheduleStatus.active = [[self.scheduledlStatus objectForKeyedSubscript:activeKey]integerValue];
            self.currentScheduleStatus.repeat = [self.scheduledlStatus objectForKeyedSubscript:repeatCountKey];
            fileRead = YES;
        }
    }
    
    return fileRead;
}

#pragma mark - Initialize buttons
- (void)initializeCurrentScheduleButton:(BOOL)scheduleStatus
{
    NSString *labelText;
    
    // if schedule is not done then setup the current schedule button with info and enable
    if (scheduleStatus == YES) {
        // setup the button title to the current schedule info and enable
        
        labelText = [NSString stringWithFormat:@"Continue %@ day %ld of week %ld", self.currentScheduleStatus.scheduleName, [self.currentScheduleStatus.day integerValue] +1, [self.currentScheduleStatus.week integerValue] +1];
        [self.currentScheduleButton setTitle:labelText forState:UIControlStateNormal];
        self.currentScheduleButton.enabled = YES;
        labelText = [NSString stringWithFormat:@"Skip day: %ld", [self.currentScheduleStatus.day integerValue] +1];
        [self.skipDayButton setTitle:labelText forState:UIControlStateNormal];
        self.skipDayButton.enabled = YES;
        self.stopScheduleButton.enabled = YES;
        self.reviewButton.enabled = YES;
    } else {
        // set the button title to schedule finsihed and disable
        
        labelText = [NSString stringWithFormat:@"Schedule Finished"];
        [self.currentScheduleButton setTitle:labelText forState:UIControlStateDisabled];
        self.currentScheduleButton.enabled = NO;
        self.skipDayButton.enabled = NO;
        self.stopScheduleButton.enabled = NO;
        self.reviewButton.enabled = NO;
    }
}

- (BOOL)bumpScheduleByNumber:(NSInteger )bumpNumber numberOfWeeks:(NSInteger )numberOfWeeks repeatCount:(NSInteger )repeatCount
{
    BOOL results = YES;       // NO = schedule finsihed;  YES = scheduled bumped
    NSNumber *day = self.currentScheduleStatus.day;
    NSNumber *week = self.currentScheduleStatus.week;
    NSNumber *repeat = self.currentScheduleStatus.repeat;
    
    // bump the day
    day = @([day integerValue] + bumpNumber);
    
    // if day exceeds a week then select the next week
    if ([day integerValue] > 6) {
        day = @(0);
        
        // bump the week
        week = @([week integerValue] + 1);
        
        // if week exceeds number of scheduled weeks then schedule completed
        if ([week integerValue] >= numberOfWeeks) {
                        
            // bump the repeat counter
            repeat = @([repeat integerValue] + 1);
            // check repeat situation
            if ([repeat integerValue] >= repeatCount) {
                self.currentScheduleStatus.active = NO;
                // workout finished
                results = NO;
            }
        }
    }
    // setup current schedule data with updated values
    self.currentScheduleStatus.day = day;
    self.currentScheduleStatus.week = week;
    self.currentScheduleStatus.lastUpdateDate = [NSDate date];
    self.currentScheduleStatus.repeat = repeat;
    
    // save updated schedule info
    [self.scheduleFileHelper writeScheduleStatusFile:self.currentScheduleStatus];
    
    return results;
}

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"startNewSchedule"]) {
        return NO;
    }
    return YES;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"addSingleEventData"]) {
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
        AddEventDataViewController *addEventDataVC = [segue destinationViewController];
        addEventDataVC.delegate = self;
    } else if ([segue.identifier isEqualToString:@"startNewSchedule"]){
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
        NewScheduledWorkoutTableViewController *newWorkoutSchedule = [segue destinationViewController];
        newWorkoutSchedule.scheduleWorkoutInfoDelegate = self;
    } else if ([segue.identifier isEqualToString:@"continueExistingSchedule"]){
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
        WorkoutScheduledEventViewController *workoutScheduledEventViewController = [segue destinationViewController];
        workoutScheduledEventViewController.workoutScheduleDelegate = self;
        workoutScheduledEventViewController.managedObjectContext = self.managedObjectContext;
    } else if ([segue.identifier isEqualToString:@"ReviewSchedule"]) {
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
        CreateSheduleViewController *createScheduleViewController = [segue destinationViewController];
        createScheduleViewController.createScheduleDelegate = self;
    }
}


@end
