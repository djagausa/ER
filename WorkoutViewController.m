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

@interface WorkoutViewController ()
@property (nonatomic, strong) NSMutableDictionary   *scheduledlStatus;
@property (weak, nonatomic) IBOutlet UIButton       *currentScheduleButton;
@property (nonatomic, strong) ScheduleStatus        *currentScheduleStatus;
@property (weak, nonatomic) IBOutlet UITableView    *eventTable;
@end

static NSString *scheduleStatusFileName = @"SechuedlStatus.out:";
static NSString *scheduleNameKey =  @"scheduledNameKey";
static NSString *dayKey = @"dayKey";
static NSString *weekKey = @"weekKey";
static NSString *lastUpdateDateKey = @"lastUpdateDateKey";
static NSString *activeKey = @"activeKey";

@implementation WorkoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scheduledlStatus = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"", scheduleNameKey, @(0), dayKey, @(0),weekKey, @"", lastUpdateDateKey, @(0), activeKey, nil ];
    self.currentScheduleStatus = [[ScheduleStatus alloc] init];
    
    // get the available workout events
    [self fetchEvents];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializeCurrentScheduleButton
{
    BOOL scheduleStatusFileExists = [self readScheduleStatusFile];
    BOOL scheduleBumpResults;   // NO = schedule finushed;  YES = schedule bumped
    
    // if status file exists
    if (scheduleStatusFileExists) {
    
        // if schedule is active then get schedule data
        if ([[self.scheduledlStatus objectForKeyedSubscript:activeKey] integerValue] == YES) {
            self.currentScheduleStatus.scheduleName = [self.scheduledlStatus objectForKeyedSubscript:scheduleNameKey];
            self.currentScheduleStatus.day = [self.scheduledlStatus objectForKeyedSubscript:dayKey];
            self.currentScheduleStatus.week = [self.scheduledlStatus objectForKeyedSubscript:weekKey];
            self.currentScheduleStatus.lastUpdateDate = [self.scheduledlStatus objectForKeyedSubscript:lastUpdateDateKey];
            self.currentScheduleStatus.active = [[self.scheduledlStatus objectForKeyedSubscript:activeKey]integerValue];
            
            NSComparisonResult compareResults;
            compareResults = [self.currentScheduleStatus.lastUpdateDate compare:[NSDate date]];
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
                
                labelText = [NSString stringWithFormat:@"Continue: %@; day: %@ of wek: %@", self.currentScheduleStatus.scheduleName, self.currentScheduleStatus.day, self.currentScheduleStatus.week];
                self.currentScheduleButton.titleLabel.text = labelText;
                self.currentScheduleButton.enabled = YES;
            } else {
                // set the button title to schedule finsihed and disable
                
                labelText = [NSString stringWithFormat:@"Schedue Finished"];
                self.currentScheduleButton.titleLabel.text = labelText;
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
    
    // the schedule has been succesfully bumped
    results = YES;

    return results;
}
#pragma mark - Delegates
- (SelectedEvent *)selectedEventDataIs
{
    return self.selectedEvent;
}

#pragma mark - Schedule status

// get scheduled status file if it exists
- (BOOL)readScheduleStatusFile
{
    BOOL fileExists = NO;   // setup return value no file present
    NSString *scheduleStatusFile;     // path to schedule status file
    
    // get path to documents dirsctory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
    
    if ([paths count] > 0) {
        // Path to schedlue status
        scheduleStatusFile = [[paths objectAtIndex:0] stringByAppendingPathComponent:scheduleStatusFileName];
        
        // if schedule status file exists
        if ([[NSFileManager defaultManager] fileExistsAtPath:scheduleStatusFile]) {
        
            fileExists = YES;
            
            // read the scheduled status file
            self.scheduledlStatus = [NSMutableDictionary dictionaryWithContentsOfFile:scheduleStatusFile];
            return fileExists;
        }
    }
    
    return fileExists;
}

// get scheduled status file if it exists
- (void)writeScheduleStatusFile
{
    NSString *filePath;     // path to schedule status file
    
    [self.scheduledlStatus setObject:self.currentScheduleStatus.scheduleName forKey:scheduleNameKey];
    [self.scheduledlStatus setObject:self.currentScheduleStatus.week forKey:weekKey];
    [self.scheduledlStatus setObject:self.currentScheduleStatus.day forKey:dayKey];
    [self.scheduledlStatus setObject:self.currentScheduleStatus.lastUpdateDate forKey:lastUpdateDateKey];
    [self.scheduledlStatus setObject:@(self.currentScheduleStatus.active) forKey:activeKey];

    // get path to documents dirsctory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
    
    if ([paths count] > 0) {
        // Path to schedlue status
        filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:scheduleStatusFileName];
        
        // write the scheduled status file
        [self.scheduledlStatus writeToFile:filePath atomically:YES];
    }
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
    }
}


@end
