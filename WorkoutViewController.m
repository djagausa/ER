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
@property (weak, nonatomic) IBOutlet UIButton           *startNewScheduleButton;
@property (weak, nonatomic) IBOutlet UIButton           *reviewButton;
@property (weak, nonatomic) IBOutlet UIButton           *currentScheduleButton;
@property (weak, nonatomic) IBOutlet UITableView        *eventTable;
@property (nonatomic, strong) NSMutableDictionary       *scheduledlStatus;
@property (nonatomic, strong) ScheduleStatusFileHelper  *scheduleFileHelper;
@property (nonatomic, strong) Utilities                 *utilities;
@property (nonatomic, strong) ScheduledEventInfo        *scheduledEventInfo;
//@property (nonatomic, strong) ScheduleStatus            *currentScheduleStatus;

- (IBAction)startNewScheduleAction:(id)sender;
- (IBAction)stopScheduleAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end

typedef NS_ENUM(NSInteger, ScheduleActivity) {
    kNewSchedule = 1,
    kStopSchedule,
    kManualSchedule,
};

BOOL manualSingleEvent;

@implementation WorkoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _scheduleFileHelper = [[ScheduleStatusFileHelper alloc] init];
    _scheduledEventInfo = [[ScheduledEventInfo alloc] init];
    
    [self formatButton:self.currentScheduleButton];
    [self formatButton:self.stopScheduleButton];
    [self formatButton:self.startNewScheduleButton];
    [self formatButton:self.reviewButton];
    self.startNewScheduleButton.enabled = YES;
    
    self.dateLabel.text = [Utilities dateToFormatMMddyyy:[NSDate date]];
    [self fetchEvents];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    BOOL scheduleStatus = [self isScheduleRunning];
    [self initializeCurrentScheduleButton:scheduleStatus];
    manualSingleEvent = NO;
    [[self eventTable] reloadData];
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
    [self.scheduleFileHelper clearScheduleStatusFileForSchedule:self.currentScheduleStatus.scheduleName];

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
    [self readCurentScheduleInfoFromStatusFile];
    if (manualSingleEvent == YES) {
        self.scheduledEventInfo.scheduleName = @"manual";
    } else {
        self.scheduledEventInfo.scheduleName = self.currentScheduleStatus.scheduleName;
    }
    self.scheduledEventInfo.day = [self.currentScheduleStatus.day integerValue];
    self.scheduledEventInfo.scheduleEditMode = kScheduleNew;
    self.scheduledEventInfo.week = [self.currentScheduleStatus.week integerValue];
    self.scheduledEventInfo.lastUpdateDate = self.currentScheduleStatus.lastUpdateDate;
    self.scheduledEventInfo.repeatCount = [self.currentScheduleStatus.repeat integerValue];
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
    self.scheduledEventInfo.repeatCount = [self.currentScheduleStatus.repeat integerValue];
    return self.scheduledEventInfo;
}

- (void)newScheduleInfoIs:(ScheduledEventInfo *)newScheduleInfoIs
{
    // if status file exists
    if ([self readCurentScheduleInfoFromStatusFile] == YES) {
        [self initializeCurrentScheduleButton:YES];
    }
}

- (void)exerciseDataAdded:(SelectedEvent *)eventAdded
{
    [[self manualCompletedEvents] addObject:eventAdded.eventName];
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
            
            // if last update day is earlier then today then bump the schedule by one day and using auto schedule.
            NSNumber *operatingMode = [self fetchOpertionalModeCountForSchedule:self.currentScheduleStatus.scheduleName];
            if (compareResults == NSOrderedAscending && ([operatingMode isEqualToNumber: @(kScheduleModeAuto)])) {
                // bunp the schedule by one day
                NSNumber *weeks = [self fetchNumberOfWeeksForSchedule:self.currentScheduleStatus.scheduleName];
                NSNumber *repeatCount = [self fetchRepeatCountForSchedule:self.currentScheduleStatus.scheduleName];
                scheduleBumpResults = [self bumpScheduleByNumber:1 numberOfWeeks:[weeks integerValue] repeatCount:[repeatCount integerValue]];
            } else {
                // use the schedule as is; this condition would occur if the workout was split into two sessions or manual completion
                scheduleBumpResults = YES;
            }
        }
    }
    return scheduleBumpResults;
}

#pragma mark - Initialize buttons
- (void)initializeCurrentScheduleButton:(BOOL)scheduleStatus
{
    NSString *labelText;
    
    // if schedule is not done then setup the current schedule button with info and enable
    if (scheduleStatus == YES) {
        // setup the button title to the current schedule info and enable
        labelText = [NSString stringWithFormat:@"Continue: %@; day %ld of week %ld", self.currentScheduleStatus.scheduleName, [self.currentScheduleStatus.day integerValue] +1, [self.currentScheduleStatus.week integerValue]+1];
        [self.currentScheduleButton setTitle:labelText forState:UIControlStateNormal];
        self.currentScheduleButton.enabled = YES;
        self.stopScheduleButton.enabled = YES;
        self.reviewButton.enabled = YES;
    } else {
        // set the button title to schedule finsihed and disable
        
        labelText = [NSString stringWithFormat:@"Schedule Finished"];
        [self.currentScheduleButton setTitle:labelText forState:UIControlStateDisabled];
        self.currentScheduleButton.enabled = NO;
        self.stopScheduleButton.enabled = NO;
        self.reviewButton.enabled = NO;
    }
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
        addEventDataVC.addEventDataDelegate = self;
        addEventDataVC.delegate = self;
        manualSingleEvent = YES;
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
