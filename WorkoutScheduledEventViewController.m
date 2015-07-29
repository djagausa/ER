//
//  WorkoutSchuledEventViewController.m
//  ExerciseRecording
//
//  Created by Douglas Alexander on 6/9/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import "WorkoutScheduledEventViewController.h"
#import "WorkoutViewController.h"
#import "ScheduledEventInfo.h"
#import "ScheduleStatus.h"
#import "ScheduledEvent.h"
#import "Utilities.h"

@interface WorkoutScheduledEventViewController ()
@property (weak, nonatomic) IBOutlet UILabel        *scheduleInfoLabel;
@property (nonatomic, strong) ScheduledEventInfo    *scheduledEventInfo;
@property (nonatomic, strong) NSArray               *weightLiftingEvents;
@property (nonatomic, strong) NSArray               *aerobicEvents;
@property (weak, nonatomic) IBOutlet UITableView    *tableView;
@property (nonatomic, strong) NSSet                 *weightScheduledEvents;
@property (nonatomic, strong) NSSet                 *aerobicScheduledEvents;
@property (nonatomic, strong) ScheduledEvent        *dayEvent;
@property (weak, nonatomic) IBOutlet UIButton       *skipDayOutlet;
- (IBAction)skipDayAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton       *dayFinishedOutlet;
- (IBAction)dayFinishedAction:(id)sender;
@end

typedef NS_ENUM(NSInteger, ScheduleActivity) {
    kSkipDay=1,
    kDayFinished,
};

@implementation WorkoutScheduledEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scheduledEventInfo = [self.workoutScheduleDelegate scheduleInfoIs];
    [self fetchEvents];
    [self fetchTodaysCompleteEvents];
    [self constructInfoLabel];
    [self formatButton:self.skipDayOutlet];
    [self formatButton:self.dayFinishedOutlet];
    
    // register for events added notifications
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(exerciseDataAddedNotification:) name:eventAddedNotificationName object:nil];
}

- (void)constructInfoLabel
{
    self.scheduledEventInfo = [self.workoutScheduleDelegate scheduleInfoIs];
    NSString *labelText = [NSString stringWithFormat:@"Schedule %@: day %ld of week %ld.", self.scheduledEventInfo.scheduleName, self.scheduledEventInfo.day+1, self.scheduledEventInfo.week+1];
    self.scheduleInfoLabel.text = labelText;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)exerciseDataAddedNotification:(NSNotificationCenter *)notification
{
    // change the color of the table view cell
    [self fetchTodaysCompleteEvents];
    [self.tableView reloadData];
}

- (void)formatButton:(UIButton *)button
{
    button.layer.cornerRadius = 9.0f;
    button.layer.borderColor = [UIColor blueColor].CGColor;
    button.layer.borderWidth = 1.0f;
}

#pragma  mark - Deleagate
- (ScheduledEventInfo *)scheduledEventIs
{
    self.scheduledEventInfo.scheduleEditMode = kScheduleReview;
    return self.scheduledEventInfo;
}

- (IBAction)skipDayAction:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"Skip day %ld?", self.scheduledEventInfo.day+1 ]
                                                   message:@""
                                                  delegate:self
                                         cancelButtonTitle:@"Yes"
                                         otherButtonTitles:@"No", nil];
    alert.tag = kSkipDay;
    [alert show];
}

- (IBAction)dayFinishedAction:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"Finished with day %ld?", self.scheduledEventInfo.day+1 ]
                                                   message:@""
                                                  delegate:self
                                         cancelButtonTitle:@"Yes"
                                         otherButtonTitles:@"No", nil];
    alert.tag = kDayFinished;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {

        case kSkipDay:
            if (buttonIndex == 0) {
                [self bumpDay];
            }
            break;
        case kDayFinished:
            if (buttonIndex == 0) {
                [self bumpDay];
            }
            break;
        default:
            break;
    }
}

- (void)bumpDay
{    
    // bunp the schedule by one day
    NSNumber *weeks = [self fetchNumberOfWeeksForSchedule:self.scheduledEventInfo.scheduleName];
    NSNumber *repeatCount = [self fetchRepeatCountForSchedule:self.scheduledEventInfo.scheduleName];
    [self bumpScheduleByNumber:1 numberOfWeeks:[weeks integerValue] repeatCount:[repeatCount integerValue]];
    self.scheduledEventInfo = [self.workoutScheduleDelegate scheduleInfoIs];
    [self fetchEvents];
    [self fetchTodaysCompleteEvents];
    [self constructInfoLabel];
    [self.tableView reloadData];
}

#pragma mark - Core Data
- (void)fetchEvents
{
//    Schedule *schedule;
    NSArray *scheduledEvents;
    
    scheduledEvents = [self.coreDataHelper fetchDataFor:scheduleEntityName withPredicate:@{@"propertyName" : @"scheduleName", @"value" : self.scheduledEventInfo.scheduleName} sortKey:nil];
    
    self.dayEvent = [self.coreDataHelper fetchScheduledEvent:scheduledEvents week:self.scheduledEventInfo.week day:self.scheduledEventInfo.day];
    
    self.weightScheduledEvents = self.dayEvent.weightEvent;
    self.aerobicScheduledEvents = self.dayEvent.aerobicEvent;
 
    [self.weightLiftingDefaultObjects removeAllObjects];
    [self.aerobicDefaultObjects removeAllObjects];
    
    for (DefaultAerobic *aerobicEvent in self.aerobicScheduledEvents) {
        [self.aerobicDefaultObjects addObject:aerobicEvent];
    }
    
    for (DefaultWeightLifting *weightEvent in self.weightScheduledEvents) {
        [self.weightLiftingDefaultObjects addObject:weightEvent];
    }

    NSSortDescriptor *sortD = [NSSortDescriptor sortDescriptorWithKey:@"eventName" ascending:YES];
    
    [self.weightLiftingDefaultObjects sortUsingDescriptors:[NSArray arrayWithObject:sortD]];
    [self.aerobicDefaultObjects sortUsingDescriptors:[NSArray arrayWithObject:sortD]];
    
#ifdef debug
    for (DefaultAerobic *aerobicEvent in self.aerobicDefaultObjects) {
        NSLog(@"Aerobic Even Name: %@", aerobicEvent.eventName);
    }
    for (DefaultWeightLifting *weightEvent in self.weightLiftingDefaultObjects) {
        NSLog(@"Weight Even Name: %@", weightEvent.eventName);
    }
#endif
}


- (void)fetchTodaysCompleteEvents
{
    //     fetch any saved events that may have occurred
    
    self.completedWeightEvents = [[self.coreDataHelper fetchDataFor:weightLiftingEventsEntityName withPredicate:@{@"propertyName": @"date", @"value" : [Utilities dateWithoutTime:[NSDate date]]} sortKey:@"eventName"] mutableCopy];
    
    self.completedAerobicEvents = [[self.coreDataHelper fetchDataFor:aerobicEventsEntityName withPredicate:@{@"propertyName": @"date", @"value" : [Utilities dateWithoutTime:[NSDate date]]} sortKey:@"eventName"] mutableCopy];
}
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"scheduleReview"]){
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
        CreateSheduleViewController *createScheduleViewController = [segue destinationViewController];
        createScheduleViewController.createScheduleDelegate = self;
    } else if ([segue.identifier isEqualToString:@"scheduledEvent"]) {
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
        AddEventDataViewController *addEventDataVC = [segue destinationViewController];
        addEventDataVC.delegate = self;
    }
}

@end
