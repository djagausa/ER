  //
//  ScheduleDayEventsViewController.m
//  ExerciseRecording
//
//  Created by Douglas Alexander on 5/26/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import "ScheduleDayEventsViewController.h"
#import <CoreData/CoreData.h>
#import "DefaultAerobic.h"
#import "DefaultWeightLifting.h"
#import "CoreDataHelper.h"
#import "ScheduledEventInfo.h"
#import "Schedule.h"
#import "ScheduledEvent.h"
#import "Support.h"

@interface ScheduleDayEventsViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectedTableHeight;
@property (weak, nonatomic) IBOutlet UISegmentedControl *repeatDayOutlet;
- (IBAction)repeatDayAction:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *selectedEventsTable;
@property (weak, nonatomic) IBOutlet UITableView *availableEventsTable;

@property (nonatomic, strong) NSArray               *weightLiftingObjects;
@property (nonatomic, strong) NSArray               *aerobicObjects;
@property (nonatomic, strong) NSMutableArray        *weightLiftingDefaultObjects;
@property (nonatomic, strong) NSMutableArray        *aerobicDefaultObjects;
@property (nonatomic, strong) NSMutableArray        *selectedWeightEvents;
@property (nonatomic, strong) NSMutableArray        *selectedAerobicEvents;

@property (nonatomic, strong) ScheduledEventInfo    *scheduledEventInfo;
@property (nonatomic, assign) NSInteger             selectedEventTableHeigth;
@property (nonatomic, strong) NSMutableArray        *selectedDays;
- (IBAction)saveAction:(id)sender;
@end

const CGFloat kTableSectionHeaderHeight = 26.0;
const CGFloat kTableCellHeight = 28.0;

@implementation ScheduleDayEventsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.selectedWeightEvents = [[NSMutableArray alloc] init];
    self.selectedAerobicEvents = [[NSMutableArray alloc] init];
    self.selectedDays = [[NSMutableArray alloc]init];
    
    self.scheduledEventInfo = [self.scheduleEventDelegate dayToBeScheduled];
    
    self.navigationItem.title = [NSString stringWithFormat:@"Setup day %ld of week %ld.", self.scheduledEventInfo.day, self.scheduledEventInfo.week];
    self.selectedEventTableHeigth = 0;
    [self tagSegemntControlSubViewsAndInitializeSelectedDays];
    [self.selectedDays replaceObjectAtIndex:self.scheduledEventInfo.day-1 withObject:@(1)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self highLiteSelectedRepeatDay:self.scheduledEventInfo.day-1];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)addSelectedAerobicEvent:(DefaultAerobic *)aerobicEvent
{
    [self.selectedAerobicEvents addObject:aerobicEvent];
}

- (void)addSelectedWeightEvent:(DefaultWeightLifting *)weightLiftingEvent
{
    [self.selectedWeightEvents addObject:weightLiftingEvent];
}

- (IBAction)repeatDayAction:(id)sender
{
    NSInteger selectedIndex;
    selectedIndex = [sender selectedSegmentIndex];
    
    NSNumber *selectedDayState;
    NSNumber *newState;
    selectedDayState = [self.selectedDays objectAtIndex:selectedIndex];
    if ([selectedDayState isEqualToNumber:@(0)]) {
        newState = [NSNumber numberWithInt:1];
    } else {
        newState = [NSNumber numberWithInt:0];
    }
    
    [self.selectedDays replaceObjectAtIndex:selectedIndex withObject:newState];
    
    [self highLiteSelectedRepeatDay:selectedIndex];
}

- (void)tagSegemntControlSubViewsAndInitializeSelectedDays
{
    int j = 0;
    for (int i = (int)[[self.repeatDayOutlet subviews]count]-1; i >= 0; i--) {
        [[[self.repeatDayOutlet subviews] objectAtIndex:i] setTag:j];
        j++;
        
        // initialize selected days while here
        [self.selectedDays addObject:[NSNumber numberWithInt:0]];
    }
    [[UISegmentedControl appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blueColor]} forState:UIControlStateSelected];
    [self.repeatDayOutlet setEnabled:NO forSegmentAtIndex:self.scheduledEventInfo.day-1];

}

- (void)highLiteSelectedRepeatDay:(NSInteger)selectedDay
{
    for (id seg in [self.repeatDayOutlet subviews]) {
        if ([seg tag] == selectedDay) {
            if ([[self.selectedDays objectAtIndex:selectedDay] integerValue] > 0) {
                [seg setBackgroundColor:[UIColor greenColor]];
            } else {
                [seg setBackgroundColor:[UIColor whiteColor]];
            }
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = 0;
    if (tableView == self.availableEventsTable) {
        if (self.weightLiftingDefaultObjects.count > 0)
        {
            count++;
        }
        
        if (self.aerobicDefaultObjects.count > 0)
        {
            count++;
        }
    } else if (tableView == self.selectedEventsTable) {
        if (self.selectedWeightEvents.count > 0)
        {
            count++;
        }
        
        if (self.selectedAerobicEvents.count > 0)
        {
            count++;
        }
    }
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    
    if (tableView == self.availableEventsTable) {
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
    } else if (tableView == self.selectedEventsTable) {
        switch (section) {
            case 0:
                if (self.selectedAerobicEvents.count > 0) {
                    count = self.selectedAerobicEvents.count;
                }
                else
                {
                    count = self.selectedWeightEvents.count;
                    
                }
                break;
            case 1:
                count = [self.selectedWeightEvents count];
                break;
                
            default:
                break;
        }
    }
    return count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *headerTitle;
    if (tableView == self.availableEventsTable) {

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
    } else if (tableView == self.selectedEventsTable) {
        switch (section) {
            case 0:
                if (self.selectedAerobicEvents.count > 0) {
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
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (tableView == self.availableEventsTable) {
        switch (indexPath.section) {
            case 0:
                if (self.aerobicDefaultObjects.count > 0)
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"availableEventCell" forIndexPath:indexPath];
                    DefaultAerobic *event = [self.aerobicDefaultObjects objectAtIndex:indexPath.row];
                    cell.textLabel.text = event.eventName;
                }
                else
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"availableEventCell" forIndexPath:indexPath];
                    DefaultWeightLifting *event = [self.weightLiftingDefaultObjects objectAtIndex:indexPath.row];
                    cell.textLabel.text = event.eventName;
                }
                break;
                
            case 1:
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"availableEventCell" forIndexPath:indexPath];
                DefaultWeightLifting *event = [self.weightLiftingDefaultObjects objectAtIndex:indexPath.row];
                cell.textLabel.text = event.eventName;
            }
                break;
                
            default:
                break;
        }
        return cell;
    } else if (tableView == self.selectedEventsTable) {
        switch (indexPath.section) {
            case 0:
                if (self.selectedAerobicEvents.count > 0)
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"selectedEventCell" forIndexPath:indexPath];
                    DefaultAerobic *event = [self.selectedAerobicEvents objectAtIndex:indexPath.row];
                    cell.textLabel.text = event.eventName;
                }
                else
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"selectedEventCell" forIndexPath:indexPath];
                    DefaultWeightLifting *event = [self.selectedWeightEvents objectAtIndex:indexPath.row];
                    cell.textLabel.text = event.eventName;
                }
                break;
                
            case 1:
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"selectedEventCell" forIndexPath:indexPath];
                DefaultWeightLifting *event = [self.selectedWeightEvents objectAtIndex:indexPath.row];
                cell.textLabel.text = event.eventName;
            }
                break;
                
            default:
                break;
        }
        return cell;

    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.availableEventsTable) {
        switch (indexPath.section) {
            case 0:
                if (self.aerobicDefaultObjects.count > 0)
                {
                    self.defaultAerobic = [self.aerobicDefaultObjects objectAtIndex:indexPath.row];
                    [self addSelectedAerobicEvent:self.defaultAerobic];
                    [self.aerobicDefaultObjects removeObjectAtIndex:indexPath.row];
                }
                else
                {
                    self.defaultWeightLifting = [self.weightLiftingDefaultObjects objectAtIndex:indexPath.row];
                    [self addSelectedWeightEvent:self.defaultWeightLifting];
                    [self.weightLiftingDefaultObjects removeObjectAtIndex:indexPath.row];
                }
                break;
                
            case 1:
            {
                self.defaultWeightLifting = [self.weightLiftingDefaultObjects objectAtIndex:indexPath.row];
                [self addSelectedWeightEvent:self.defaultWeightLifting];
                [self.weightLiftingDefaultObjects removeObjectAtIndex:indexPath.row];
            }
                break;
                
            default:
                break;
        }

    } else if (tableView == self.selectedEventsTable) {
        switch (indexPath.section) {
            case 0:
                if (self.selectedAerobicEvents.count > 0)
                {
                    self.defaultAerobic = [self.selectedAerobicEvents objectAtIndex:indexPath.row];
                    [self.aerobicDefaultObjects addObject:self.defaultAerobic];
                    [self.selectedAerobicEvents removeObjectAtIndex:indexPath.row];
                }
                else
                {
                    self.defaultWeightLifting = [self.selectedWeightEvents objectAtIndex:indexPath.row];
                    [self.weightLiftingDefaultObjects addObject:self.defaultWeightLifting];
                    [self.selectedWeightEvents removeObjectAtIndex:indexPath.row];
                }
                break;
                
            case 1:
            {
                self.defaultWeightLifting = [self.selectedWeightEvents objectAtIndex:indexPath.row];
                [self.weightLiftingDefaultObjects addObject:self.defaultWeightLifting];
                [self.selectedWeightEvents removeObjectAtIndex:indexPath.row];
            }
                break;
                
            default:
                break;
        }

    }
    [self updateTables];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableSectionHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableCellHeight;
}

- (void)updateSelectedTableHeight
{
    if ([self.selectedAerobicEvents count] > 0) {
        self.selectedEventTableHeigth = kTableSectionHeaderHeight;
    }
    if ([self.selectedWeightEvents count] > 0) {
        self.selectedEventTableHeigth += kTableSectionHeaderHeight;
    }
    for (int i = 0; i < [self.selectedAerobicEvents count]; ++i) {
        self.selectedEventTableHeigth += kTableCellHeight;
    }
    
    for (int i = 0; i < [self.selectedWeightEvents count]; ++i) {
        self.selectedEventTableHeigth += kTableCellHeight;
    }
    if (self.selectedEventTableHeigth > 180) {
        self.selectedEventTableHeigth = 180;
    }
    self.selectedTableHeight.constant = self.selectedEventTableHeigth;
    [self.selectedEventsTable needsUpdateConstraints];
}

- (void)updateTables
{
    [self.selectedEventsTable reloadData];
    [self.availableEventsTable reloadData];
    
    [self updateSelectedTableHeight];
}
#pragma mark - Fetched results controller

- (void) fetchEvents
{
    
    self.weightLiftingObjects = [self.coreDataHelper fetchDefaultDataFor:weightLiftingDefaultEventsEntityName withSortKey:@"eventName" ascending:YES usePredicate:YES];
    self.aerobicObjects = [self.coreDataHelper fetchDefaultDataFor:aerobicDefaultEventsEntityName withSortKey:@"eventName" ascending:YES usePredicate:YES];
    
    self.weightLiftingDefaultObjects = [self.weightLiftingObjects mutableCopy];
    self.aerobicDefaultObjects = [self.aerobicObjects mutableCopy];

#ifdef debug
     for (DefaultWeightLifting *defaultWL in self.weightLiftingDefaultObjects) {
     NSLog(@"Event Name: %@",defaultWL.eventName);
     }

     for (DefaultAerobic *defaultA in self.aerobicDefaultObjects) {
     NSLog(@"Event Name: %@",defaultA.eventName);
     }
#endif
}

- (void)setupScheduledEvent:(ScheduledEvent *)scheduledEvent forSchedule:(Schedule *)schedule forDay:(NSInteger)day
{
    scheduledEvent.schedule = schedule;
    scheduledEvent.day = @(day);
    scheduledEvent.week = @(self.scheduledEventInfo.week);
    scheduledEvent.repeatedDays = [NSArray arrayWithArray:self.selectedDays];
    scheduledEvent.cellColor = @(self.scheduledEventInfo.colorIndex);
    scheduledEvent.totalEvents = @(self.selectedWeightEvents.count + self.selectedAerobicEvents.count);
    
    for (DefaultWeightLifting *weightLiftingEvent in self.selectedWeightEvents) {
        [scheduledEvent addWeightEventObject:weightLiftingEvent];
    }

    for (DefaultAerobic *aerobicEvent in self.selectedAerobicEvents) {
        [scheduledEvent addAerobicEventObject: aerobicEvent];
    }
    [schedule addScheduledEventsObject:scheduledEvent];
    
#ifdef debug
    NSLog(@"11111..........scheduleEvent id: %@", scheduledEvent.objectID);
    NSLog(@"11111..........aerobic set: %ld", scheduledEvent.aerobicEvent.count);
    NSLog(@"11111..........weight event: %ld", scheduledEvent.weightEvent.count);
#endif
}

- (Schedule *)setupSchedule
{
    Schedule *schedule;
    
    NSArray *schedules = [self.coreDataHelper fetchDataFor:scheduleEntityName withPredicate:@{@"propertyName" : @"scheduleName", @"value" : self.scheduledEventInfo.scheduleName}];

    if ([schedules count] > 0) {
        schedule = [schedules firstObject];
    } else {
        schedule = (Schedule *)[self.coreDataHelper newObject:@"Schedule"];
        schedule.numberOfWeeks = @(self.scheduledEventInfo.numberOfWeeks);
        schedule.scheduleName = self.scheduledEventInfo.scheduleName;
    }
    return schedule;
}

- (IBAction)saveAction:(id)sender {
    
    // Surround the "add" functionality with undo grouping
    NSUndoManager *manager = self.coreDataHelper.managedObjectContext.undoManager;
    [manager beginUndoGrouping];
    
    Schedule *schedule = [self setupSchedule];
    
    for (int i = 0; i < [self.selectedDays count]; ++i) {
        if ([self.selectedDays[i] isEqualToNumber:@(1)]) {
            ScheduledEvent *scheduledEvent = (ScheduledEvent *)[self.coreDataHelper newObject:@"ScheduledEvent"];
            [self setupScheduledEvent:scheduledEvent forSchedule:schedule forDay:i+1];
#ifdef debug
            NSLog(@"22222...........scheduleEvent id: %@", scheduledEvent.objectID);
            NSLog(@"22222...........aerobic set: %ld", scheduledEvent.aerobicEvent.count);
            NSLog(@"22222...........weight event: %ld", scheduledEvent.weightEvent.count);
#endif
        }
    }
    
    [manager endUndoGrouping];
    [manager setActionName:@"Add"];
    [self.coreDataHelper save];
    [self.scheduleEventDelegate daysConfigured:self.scheduledEventInfo.week];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
