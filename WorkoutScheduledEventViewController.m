//
//  WorkoutSchuledEventViewController.m
//  ExerciseRecording
//
//  Created by Douglas Alexander on 6/9/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import "WorkoutScheduledEventViewController.h"
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
@end

@implementation WorkoutScheduledEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scheduledEventInfo = [self.workoutScheduleDelegate scheduleInfoIs];
    [self fetchEvents];
    [self fetchTodaysCompleteEvents];
    [self constructInfoLabel];
}

- (void)constructInfoLabel
{
    NSString *labelText = [NSString stringWithFormat:@"Schedule %@: day %ld of week %ld.", self.scheduledEventInfo.scheduleName, self.scheduledEventInfo.day+1, self.scheduledEventInfo.week+1];
    self.scheduleInfoLabel.text = labelText;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)exerciseDataAdded:(SelectedEvent *)eventAdded
{
    // change the color of the table view cell
    [self fetchEvents];
    [self.tableView reloadData];
}

#pragma  mark - Deleagate
- (ScheduledEventInfo *)scheduledEventIs
{
    self.scheduledEventInfo.scheduleEditMode = kScheduleReview;
    return self.scheduledEventInfo;
}

#pragma mark - Core Data
- (void)fetchEvents
{
    Schedule *schedule;
    NSArray *scheduledEvents;
    
    scheduledEvents = [self.coreDataHelper fetchDataFor:scheduleEntityName withPredicate:@{@"propertyName" : @"scheduleName", @"value" : self.scheduledEventInfo.scheduleName}];

    if ([scheduledEvents count] > 0) {
        schedule = [scheduledEvents firstObject];
    }
    
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
    
    self.completedWeightEvents = [[self.coreDataHelper fetchDataFor:weightLiftingEventsEntityName withPredicate:@{@"propertyName": @"date", @"value" : [Utilities dateWithoutTime:[NSDate date]]}] mutableCopy];
    
    self.completedAerobicEvents = [[self.coreDataHelper fetchDataFor:aerobicEventsEntityName withPredicate:@{@"propertyName": @"date", @"value" : [Utilities dateWithoutTime:[NSDate date]]}] mutableCopy];
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
        addEventDataVC.addEventDataDelegate = self;
    }
}
@end
