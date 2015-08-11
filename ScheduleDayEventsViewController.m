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
@property (weak, nonatomic) IBOutlet UILabel *selectFromLabelTitle;

@property (nonatomic, strong) NSArray               *weightLiftingObjects;
@property (nonatomic, strong) NSArray               *aerobicObjects;
@property (nonatomic, strong) NSMutableArray        *weightLiftingDefaultObjects;
@property (nonatomic, strong) NSMutableArray        *aerobicDefaultObjects;
@property (nonatomic, strong) NSMutableArray        *selectedWeightEvents;
@property (nonatomic, strong) NSMutableArray        *selectedAerobicEvents;

@property (nonatomic, strong) ScheduledEventInfo    *scheduledEventInfo;
@property (nonatomic, assign) NSInteger             selectedEventTableHeight;
@property (nonatomic, assign) NSInteger             selectedEventTableHeightMax;
@property (nonatomic, strong) NSMutableArray        *selectedDays;
@property (nonatomic, strong) NSMutableArray        *orignalSelectedDays;
@property (nonatomic, strong) NSMutableArray        *allReadySelectedDays;


- (IBAction)saveAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *navSaveButton;
@end

const CGFloat kTableCellHeight = 40.0;

@implementation ScheduleDayEventsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.selectedWeightEvents = [[NSMutableArray alloc] init];
    self.selectedAerobicEvents = [[NSMutableArray alloc] init];
    self.selectedDays = [[NSMutableArray alloc]initWithCapacity:7];
    self.orignalSelectedDays = [[NSMutableArray alloc]initWithCapacity:7];
    self.allReadySelectedDays = [[NSMutableArray alloc]initWithCapacity:7];

    for (int i=0; i < 7; ++i) {
        [self.orignalSelectedDays addObject:@(0)];
        [self.allReadySelectedDays addObject:@(0)];
    }
     // get the info about what is being scehuled
    self.scheduledEventInfo = [self.scheduleEventDelegate dayToBeScheduled];
  
    self.selectedEventTableHeightMax = 280;
    // disable controls if the edit mode is review
    if (self.scheduledEventInfo.scheduleEditMode == kScheduleReview) {
        self.repeatDayOutlet.enabled = NO;
        self.selectedEventsTable.allowsSelection = NO;
        self.availableEventsTable.allowsSelection = NO;
        self.availableEventsTable.hidden = YES;
        self.selectFromLabelTitle.hidden = YES;
        self.navSaveButton.enabled = NO;
        self.selectedEventTableHeightMax = 480;
    }
    
    self.navigationItem.title = [NSString stringWithFormat:@"Setup day %ld of week %ld.", self.scheduledEventInfo.day+1, self.scheduledEventInfo.week+1];
    self.selectedEventTableHeight = 0;
    
    // the tag is used to id which segments have been selected when selecting multiple segments; initial state just selected day hghlighted
    [self tagSegemntControlSubViewsAndInitializeSelectedDays];
    
    // initialize the day that a schedule is being created for
    [self.selectedDays replaceObjectAtIndex:self.scheduledEventInfo.day withObject:@(1)];

    // get the avaialble event and handle edit mode
    [self fetchScheduledEvents];
    
    // register section header
    [[self selectedEventsTable] registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"sectionHeader"];
    
    [self findAndHighLiteDaysThatHaveAlreadyBeenSelected];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self highLiteSelectedRepeatDay:self.scheduledEventInfo.day];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
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
    
    [self handleSegmentState:selectedIndex];
    [self highLiteSelectedRepeatDay:selectedIndex];
    
    [self.navSaveButton setEnabled:YES];
}

- (void)handleSegmentState:(NSInteger)selectedIndex
{
    NSNumber *selectedDayState;
    NSNumber *newState;

    selectedDayState = [self.selectedDays objectAtIndex:selectedIndex];
    if ([selectedDayState isEqualToNumber:@(0)]) {
        newState = [NSNumber numberWithInt:1];
    } else {
        newState = [NSNumber numberWithInt:0];
    }
    
    [self.selectedDays replaceObjectAtIndex:selectedIndex withObject:newState];
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
    [self.repeatDayOutlet setEnabled:NO forSegmentAtIndex:self.scheduledEventInfo.day];
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

// let the user know which days have already been scheduled
- (void)findAndHighLiteDaysThatHaveAlreadyBeenSelected
{
    NSInteger i = 6;  // acceeing the segment starts with the last one.
    for (id seg in [self.repeatDayOutlet subviews]) {
        ScheduledEvent *event = [self getscheduledEventForToday:self.scheduledEventInfo.week day:i];
        if (event && ([[self.orignalSelectedDays objectAtIndex:i] isEqualToNumber:@(0)]) ) {
            [seg setBackgroundColor:[UIColor redColor]];
            [self.allReadySelectedDays setObject:@(1) atIndexedSubscript:i];
        }
        i--;
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *sectionView = [[self selectedEventsTable] dequeueReusableHeaderFooterViewWithIdentifier:@"sectionHeader"];
    return sectionView;
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
    [self.navSaveButton setEnabled:YES];

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
    return 30.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableCellHeight;
}

- (void)updateSelectedTableHeight
{
    if ([self.selectedAerobicEvents count] > 0) {
        self.selectedEventTableHeight = SECTION_HEADER_HEIGHT;
    }
    if ([self.selectedWeightEvents count] > 0) {
        self.selectedEventTableHeight += SECTION_HEADER_HEIGHT;
    }
    for (int i = 0; i < [self.selectedAerobicEvents count]; ++i) {
        self.selectedEventTableHeight += kTableCellHeight;
    }
    
    for (int i = 0; i < [self.selectedWeightEvents count]; ++i) {
        self.selectedEventTableHeight += kTableCellHeight;
    }
    if (self.selectedEventTableHeight > self.selectedEventTableHeightMax) {
        self.selectedEventTableHeight = self.selectedEventTableHeightMax;
    }
    self.selectedTableHeight.constant = self.selectedEventTableHeight;
    [self.selectedEventsTable needsUpdateConstraints];
}

- (void)updateTables
{
    [self.selectedEventsTable reloadData];
    [self.availableEventsTable reloadData];
    
    [self updateSelectedTableHeight];
}
#pragma mark - Fetched results controller

- (void) fetchScheduledEvents
{
    self.weightLiftingDefaultObjects = [[self.coreDataHelper fetchDefaultDataFor:weightLiftingDefaultEventsEntityName withSortKey:@"eventName" ascending:YES usePredicate:YES] mutableCopy];
    self.aerobicDefaultObjects = [[self.coreDataHelper fetchDefaultDataFor:aerobicDefaultEventsEntityName withSortKey:@"eventName" ascending:YES usePredicate:YES] mutableCopy];

    // if this is an edit session then get the existing schedule data
    if (self.scheduledEventInfo.scheduleEditMode == kScheduleEdit || self.scheduledEventInfo.scheduleEditMode == kScheduleReview) {
        
          // get the events for the selected day
        ScheduledEvent *daysEvent = [self  getscheduledEventForToday:self.scheduledEventInfo.week day:self.scheduledEventInfo.day];

        // if events are scheduled for this day then update selected days and event tables with existing info
        if (daysEvent) {

            // get scheduled weight events
            NSSet *scheduledWeightEvents = daysEvent.weightEvent;
            
            // get scheduled aerobic events
            NSSet *scheduledAerobicEvents = daysEvent.aerobicEvent;
            
#ifdef DEBUG
            for (WeightLiftingEvent *event in scheduledWeightEvents) {
                NSLog(@"Select weight set Event Name: %@",event);
            }
            for (AerobicEvent *event in scheduledAerobicEvents) {
                NSLog(@"Select aerobic set Event Name: %@",event);
            }
#endif
            
            // add scheduled events to selected tables
            self.selectedAerobicEvents = [[scheduledAerobicEvents allObjects]mutableCopy];
            self.selectedWeightEvents = [[scheduledWeightEvents allObjects]mutableCopy];
            
            // remove scheduled events from available events table
            for (WeightLiftingEvent *weigthEvent in scheduledWeightEvents) {
                [self.weightLiftingDefaultObjects removeObject:weigthEvent];
            }
            for (AerobicEvent *aerobicEvent in scheduledAerobicEvents) {
                [self.aerobicDefaultObjects removeObject:aerobicEvent];
            }
            
            // setup repeated days
            self.selectedDays = [NSMutableArray arrayWithArray: daysEvent.repeatedDays];
            self.orignalSelectedDays = [NSMutableArray arrayWithArray: daysEvent.repeatedDays];
            for (int i = 0; i <= 6; ++i) {
                [self highLiteSelectedRepeatDay:i];
            }
            
            // reload tables
            [self updateTables];
                
        }
        
        // change navigation save button text to "update"
        self.navSaveButton.title = @"Update";
    }
#ifdef DUBUG
    for (DefaultWeightLifting *defaultWL in self.weightLiftingDefaultObjects) {
        NSLog(@"Default weight Event Name: %@",defaultWL.eventName);
    }
    
    for (DefaultAerobic *defaultA in self.aerobicDefaultObjects) {
        NSLog(@"Default aerobic Event Name: %@",defaultA.eventName);
    }
    
    for (AerobicEvent *event in self.selectedAerobicEvents) {
        NSLog(@"Select aerobic Event Name: %@",event);
    }
    for (WeightLiftingEvent *event in self.selectedWeightEvents) {
        NSLog(@"Select wight Event Name: %@",event);
    }
#endif
}

- (ScheduledEvent *) getscheduledEventForToday:(NSInteger)week day:(NSInteger)day
{
    // get the scheduled events for this schedule
    NSArray *scheduledEvents;
    scheduledEvents = [self.coreDataHelper fetchDataFor:scheduleEntityName withPredicate:@{@"propertyName" : @"scheduleName", @"value" : self.scheduledEventInfo. scheduleName} sortKey:nil scheduleInfo:nil];
    
    // get the events for the selected day
    ScheduledEvent *daysEvent = [self.coreDataHelper fetchScheduledEvent:scheduledEvents week:week day:day];

    return daysEvent;
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
    
#ifdef DEBUG
    NSLog(@"11111..........scheduleEvent id: %@", scheduledEvent.objectID);
    NSLog(@"11111..........aerobic set: %ld", scheduledEvent.aerobicEvent.count);
    NSLog(@"11111..........weight event: %ld", scheduledEvent.weightEvent.count);
#endif
}

- (Schedule *)setupSchedule
{
    Schedule *schedule;
    
    NSArray *schedules = [self.coreDataHelper fetchDataFor:scheduleEntityName withPredicate:@{@"propertyName" : @"scheduleName", @"value" : self.scheduledEventInfo.scheduleName} sortKey:nil scheduleInfo:nil];

    if ([schedules count] > 0) {
        schedule = [schedules firstObject];
    } else {
        schedule = (Schedule *)[self.coreDataHelper newObject:@"Schedule"];
        schedule.scheduleName = self.scheduledEventInfo.scheduleName;
    }
    schedule.numberOfWeeks = @(self.scheduledEventInfo.numberOfWeeks);
    schedule.repeatCount = @(self.scheduledEventInfo.repeatCount);
    return schedule;
}

- (IBAction)saveAction:(id)sender {

    // disable the navigation save button - user feed back
    [self.navSaveButton setEnabled:NO];
     
    // Surround the "add" functionality with undo grouping
    NSUndoManager *manager = self.coreDataHelper.managedObjectContext.undoManager;
    [manager beginUndoGrouping];
    
    Schedule *schedule = [self setupSchedule];
    
    // rmove all prevously saved events
    for (int i = 0; i < [self.orignalSelectedDays count]; ++i) {
        if ([self.orignalSelectedDays[i] isEqualToNumber:@(1)]) {
            ScheduledEvent *scheduledEvent = [self  getscheduledEventForToday:self.scheduledEventInfo.week day:i];
            if (scheduledEvent != nil) {
                [schedule removeScheduledEventsObject:scheduledEvent];
            }
        }
    }
    
    for (int i = 0; i < [self.selectedDays count]; ++i) {

        // save all the days that are the same
        if ([self.selectedDays[i] isEqualToNumber:@(1)]) {
 
            ScheduledEvent *scheduledEvent = (ScheduledEvent *)[self.coreDataHelper newObject:@"ScheduledEvent"];
            [self setupScheduledEvent:scheduledEvent forSchedule:schedule forDay:i];
#ifdef DEBUG
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
    
    // return to the previous view
    [self.navigationController popViewControllerAnimated:YES];
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
