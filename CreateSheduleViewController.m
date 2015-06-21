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
@property (nonatomic, strong) ScheduledEventInfo *createScheduledEventInfo;
@property (nonatomic, strong) NSMutableArray *numberOfEventsPerDay;
@property (nonatomic, strong) NSMutableArray *daysConfiguredTheSame;
@property (nonatomic, strong) ScheduledEvent *scheduledEvent;
@property (nonatomic, assign) NSInteger coloredCellCount;
@property (nonatomic, strong) NSArray *scheduledEvents;
@property (nonatomic, strong) NSNumber *numberOfWeeks;

@end

static NSString *_dayCellIdentification = @"dayCell";
static NSString *_headerCellIdentification = @"ScheduleHearderCell";
static NSArray *_cellColors;

@implementation CreateSheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _createScheduledEventInfo = [[ScheduledEventInfo alloc] init];
    
    if (self.createScheduleDelegate && [self.createScheduleDelegate respondsToSelector:@selector(scheduledEventIs)]) {
        self.createScheduledEventInfo = [self.createScheduleDelegate scheduledEventIs];
    }
    
    [self initializeData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializeData
{
    self.scheduledEvents = [[NSArray alloc] init];    
    self.numberOfEventsPerDay = [[NSMutableArray alloc] initWithCapacity:7];
    for (int i = 0; i <= 6; ++i) {
        [self.numberOfEventsPerDay setObject:@(0) atIndexedSubscript:i];
    }
    self.daysConfiguredTheSame = [[NSMutableArray alloc] initWithCapacity:7];
    _cellColors = [[NSArray alloc] initWithObjects:
                   [UIColor whiteColor],
                   [UIColor redColor],
                   [UIColor greenColor],
                   [UIColor blueColor],
                   [UIColor lightGrayColor],
                   [UIColor orangeColor],
                   [UIColor purpleColor],
                   [UIColor cyanColor],nil];
    self.coloredCellCount = 0;       // selecting white color = no configuration for the cell
    
    if (self.createScheduledEventInfo.scheduleEditMode == kScheduleReview) {
        // disable the schedule input name text field and populate with existing schedule name
        self.scheduleNameOutlet.enabled = NO;
        self.numberOfWeeksOutlet.enabled = NO;
        [self configureScreenElements];
    } else if (self.createScheduledEventInfo.scheduleEditMode == kScheduleEdit){
        [self configureScreenElements];
    }
}

- (void)configureScreenElements
{
    self.scheduleNameOutlet.text = self.createScheduledEventInfo.scheduleName;
    [self.scheduleCollectionView setUserInteractionEnabled:YES];
    [self fetchScheduledEvents:self.createScheduledEventInfo.scheduleName];
    [self loadExistingSchedueInfo:self.createScheduledEventInfo.scheduleName];
}
- (IBAction)scheduleNameInput:(id)sender
{
    if ([self.scheduleNameOutlet.text length] > 0) {
        if ([self seeIfAlreadyExists:[sender text]]) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"A schedule with name \"%@\" already exists", [sender text]]
                                                           message:@"Would you like to edit this schedule?"
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
        [self.createScheduledEventInfo setScheduleEditMode:kScheduleEdit];
        [self.scheduleCollectionView setUserInteractionEnabled:YES];
        [self loadExistingSchedueInfo:self.scheduleNameOutlet.text];
        return;
    }
    [self.createScheduledEventInfo setScheduleEditMode:kNoScheduleEdit];
}

- (void)loadExistingSchedueInfo:(NSString *)scheduleName
{
    NSArray *scheduledEvents = [self.coreDataHelper fetchDataFor:@"Schedule" withPredicate:@{@"propertyName" : @"scheduleName", @"value" : scheduleName}];
    Schedule *schedule = [scheduledEvents firstObject];
    self.numberOfWeeks = schedule.numberOfWeeks;
    self.numberOfWeeksOutlet.text = [NSString stringWithFormat: @"%@", self.numberOfWeeks];

    [self.scheduleCollectionView reloadData];
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
        self.coloredCellCount = 1;
    }
    self.createScheduledEventInfo.colorIndex = self.coloredCellCount;

    return self.createScheduledEventInfo;
}

// reload the section - events have been saved
- (void)daysConfigured:(NSInteger)week
{
    [self fetchScheduledEvents:self.createScheduledEventInfo.scheduleName];

    [self.scheduleCollectionView reloadSections:[NSIndexSet indexSetWithIndex:self.createScheduledEventInfo.week-1]];
}

#pragma mark - Collection View

#pragma mark = Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 7;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSInteger numberOfSection = 0;
    
    if (self.createScheduledEventInfo.scheduleEditMode == kScheduleEdit) {
        numberOfSection =  [self.numberOfWeeks integerValue];
    }
    
    // handle the situation where user inscreases the number weeks in edit mode
    if ([self.numberOfWeeksOutlet.text integerValue] > numberOfSection) {
        numberOfSection = [self.numberOfWeeksOutlet.text integerValue];
    }
    return numberOfSection;
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
    self.createScheduledEventInfo.scheduleName = self.scheduleNameOutlet.text;
    self.createScheduledEventInfo.numberOfWeeks = [self.numberOfWeeksOutlet.text integerValue];
    self.createScheduledEventInfo.week = indexPath.section + 1;
    self.createScheduledEventInfo.day = indexPath.row + 1;
}

- (void)configureCell:(DayCollectionViewCell *)cell day:(NSInteger)day week:(NSInteger)week
{
    // default values
    NSInteger totalEvents = 0;
    NSInteger colorIndex = 0;
    
    ScheduledEvent *dayEvent = [self.coreDataHelper fetchScheduledEvent:self.scheduledEvents week:week day:day];
    
    // if events exists get cell info
    if (dayEvent != nil) {
        totalEvents = [dayEvent.totalEvents integerValue];
        colorIndex = [dayEvent.cellColor integerValue];
        
        if (colorIndex > self.coloredCellCount) {
            self.coloredCellCount = colorIndex;
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
