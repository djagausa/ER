//
//  CreateSheduleViewController.m
//  ExerciseRecording
//
//  Created by Douglas Alexander on 5/25/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import "CreateSheduleViewController.h"
#import "DayCollectionViewCell.h"
#import "ScheduleHeaderCollectionReusableView.h"
#import "ScheduledEvent.h"
#import "Schedule.h"

@interface CreateSheduleViewController ()

- (IBAction)scheduleNameInput:(id)sender;
- (IBAction)numberOfWeeksInput:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *numberOfWeeksOutlet;
@property (weak, nonatomic) IBOutlet UITextField *scheduleNameOutlet;
@property (weak, nonatomic) IBOutlet UICollectionView *scheduleCollectionView;
@property (nonatomic, strong) ScheduledEventInfo *scheduledEventInfo;
@property (nonatomic, strong) NSMutableArray *numberOfEventsPerDay;
@property (nonatomic, strong) NSMutableArray *daysConfiguredTheSame;
@property (nonatomic, strong) ScheduledEvent *scheduledEvent;
@property (nonatomic, assign) NSInteger coloredCellCount;
@property (nonatomic, strong) NSArray *scheduledEvents;
@end

static NSString *_dayCellIdentification = @"dayCell";
static NSString *_headerCellIdentification = @"ScheduleHearderCell";
static NSArray *_cellColors;

@implementation CreateSheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initializeData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializeData
{
    self.scheduledEvents = [[NSArray alloc] init];
    self.scheduledEventInfo = [[ScheduledEventInfo alloc] init];
    self.numberOfEventsPerDay = [[NSMutableArray alloc] initWithCapacity:7];
    for (int i = 0; i <= 6; ++i) {
        [self.numberOfEventsPerDay setObject:@(0) atIndexedSubscript:i];
    }
    self.daysConfiguredTheSame = [[NSMutableArray alloc] initWithCapacity:7];
    _cellColors = [[NSArray alloc] initWithObjects:
                   [UIColor redColor],
                   [UIColor greenColor],
                   [UIColor blueColor],
                   [UIColor lightGrayColor],
                   [UIColor orangeColor],
                   [UIColor purpleColor],
                   [UIColor cyanColor],
                   [UIColor whiteColor], nil];
    self.coloredCellCount = 7;       // selecting white color = no configuration for the cell
}

- (IBAction)scheduleNameInput:(id)sender
{
    if ([self.scheduleNameOutlet.text length] > 0) {
        if ([self seeIfAlreadyExists:[sender text]]) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"A schedule with name \"%@\" already exists", [sender text]]
                                                           message:@"Would you like to edit this scedule?"
                                                          delegate:self
                                                 cancelButtonTitle:@"Yes"
                                                 otherButtonTitles:@"No", nil];
            [alert show];
        } else {
            [self.scheduleCollectionView setUserInteractionEnabled:YES];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self.scheduleCollectionView setUserInteractionEnabled:YES];
        [self.scheduledEventInfo setEditMode:YES];
        [self.scheduleCollectionView reloadData];
        return;
    }
    [self.scheduledEventInfo setEditMode:NO];

}

- (IBAction)numberOfWeeksInput:(id)sender
{
    [self.scheduleCollectionView reloadData];
}


#pragma mark - ScheduleDayEventDelegate

- (ScheduledEventInfo *)dayToBeScheduled
{
    self.coloredCellCount++;
    if (self.coloredCellCount >= 7) {
        self.coloredCellCount = 0;
    }
    self.scheduledEventInfo.colorIndex = self.coloredCellCount;
    return self.scheduledEventInfo;
}

// reload the section - events have been saved
- (void)daysConfigured:(NSInteger)week
{
    [self fetchScheduledEvents:self.scheduledEventInfo.scheduleName];

    [self.scheduleCollectionView reloadSections:[NSIndexSet indexSetWithIndex:self.scheduledEventInfo.week-1]];
}

#pragma mark - Collection View

#pragma mark = Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 7;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.numberOfWeeksOutlet.text integerValue];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DayCollectionViewCell * cell = [self.scheduleCollectionView dequeueReusableCellWithReuseIdentifier:_dayCellIdentification forIndexPath:indexPath];
    
    cell.dayCellDayLabel.text = [NSString stringWithFormat:@"Day: %ld", indexPath.row +1];
    [self configureCell:cell day:indexPath.row week:indexPath.section];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        ScheduleHeaderCollectionReusableView *header = [self.scheduleCollectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:_headerCellIdentification forIndexPath:indexPath];
        header.scheduleHeaderLabel.text = [NSString stringWithFormat:@"Week %ld", indexPath.section +1];
        return header;
    }
    return nil;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.scheduledEventInfo.scheduleName = self.scheduleNameOutlet.text;
    self.scheduledEventInfo.numberOfWeeks = [self.numberOfWeeksOutlet.text integerValue];
    self.scheduledEventInfo.week = indexPath.section + 1;
    self.scheduledEventInfo.day = indexPath.row + 1;
}

- (void)configureCell:(DayCollectionViewCell *)cell day:(NSInteger)day week:(NSInteger)week
{
    // default values
    NSInteger totalEvents = 0;
    NSInteger colorIndex = 7;
    
    // if events exists
    if ([self.scheduledEvents count] > 0) {
        Schedule *schedule;
        schedule = [self.scheduledEvents firstObject];
        NSSet *scheduledEvents = schedule.scheduledEvents;
        NSLog(@"Count: %ld", scheduledEvents.count);
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"day" ascending:YES];
        NSArray *sortedSchedule = [scheduledEvents sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
        
        // lookk for an event for the selected cell
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(week == %ld) && (day == %ld)", week + 1, day + 1];
    
        NSArray *events = [sortedSchedule filteredArrayUsingPredicate:predicate];
        if ([events count] > 0){
            // only one entry per day
            ScheduledEvent *dayEvent = [events firstObject];
            
            totalEvents = [dayEvent.totalEvents integerValue];
            colorIndex = [dayEvent.cellColor integerValue];
            
            if (colorIndex > self.coloredCellCount) {
                self.coloredCellCount = colorIndex;
            }
            
#ifdef debug
            NSLog(@"Week: %@; Day: %@; Color: %@; Aerobic Event Count: %ld; Weight Event Count: %ld", dayEvent.week, dayEvent.day, dayEvent.cellColor, dayEvent.aerobicEvent.count, dayEvent.weightEvent.count );
#endif
        }
    }
    
    cell.dayCellNumberOfEvents.text = [NSString stringWithFormat:@"Events: %ld", totalEvents];
    cell.backgroundColor = [_cellColors objectAtIndex: colorIndex];

}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
    ScheduleDayEventsViewController *scheduleEventViewController = [segue destinationViewController];
    scheduleEventViewController.scheduleEventDelegate = self;
}

#pragma  mark - Core Data

-(BOOL) seeIfAlreadyExists:(NSString *)scheduleName
{
    BOOL nameExists = NO;
    
    [self fetchScheduledEvents:scheduleName];

    if ([self.scheduledEvents count] > 0) {
        nameExists = YES;
    }
    
    return nameExists;
}

- (void)fetchScheduledEvents:(NSString *)scheduleName
{
    self.scheduledEvents = [self.coreDataHelper fetchDataFor:scheduleEntityName withPredicate:@{@"propertyName" : @"scheduleName", @"value" : scheduleName}];
}
@end
