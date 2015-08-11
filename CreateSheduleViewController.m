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

- (IBAction)repeatCountInput:(id)sender;
- (IBAction)scheduleNameInput:(id)sender;
- (IBAction)numberOfWeeksInput:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField        *numberOfWeeksOutlet;
@property (weak, nonatomic) IBOutlet UITextField        *scheduleNameOutlet;
@property (weak, nonatomic) IBOutlet UITextField        *repeatCountOutlet;
@property (weak, nonatomic) IBOutlet UICollectionView   *scheduleCollectionView;
@property (nonatomic, strong) ScheduledEventInfo        *createScheduledEventInfo;
@property (nonatomic, strong) NSMutableArray            *numberOfEventsPerDay;
@property (nonatomic, strong) NSMutableArray            *daysConfiguredTheSame;
@property (nonatomic, strong) ScheduledEvent            *scheduledEvent;
@property (nonatomic, strong) NSArray                   *scheduledEvents;
@property (nonatomic, strong) NSNumber                  *numberOfWeeks;
@property (nonatomic, strong) NSMutableArray            *colorStatus;               // array used to indicate if a color is being used 0 = unused; 1 = used; -1 = reserved
@property (nonatomic, strong) NSMutableArray            *cellColor;                 // array that holds the cell (days) configured color
- (IBAction)scheduleOperationModeAction:(id)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *scheduleOperationModeOutlet;

@end

static NSString *_dayCellIdentification = @"dayCell";
static NSString *_headerCellIdentification = @"ScheduleHearderCell";
static NSArray *_cellAvailableColors;

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
    _cellAvailableColors = [[NSArray alloc] initWithObjects:
                   [UIColor whiteColor],
                   [UIColor redColor],
                   [UIColor greenColor],
                   [UIColor blueColor],
                   [UIColor lightGrayColor],
                   [UIColor orangeColor],
                   [UIColor purpleColor],
                   [UIColor cyanColor],nil];
    _colorStatus = [[NSMutableArray alloc] initWithCapacity:8];             // 0 = unused; 1 = used; -1 = reserved
    for (int i = 0; i < 8; ++i) {
        [_colorStatus addObject:@(0)];                                      //  set to unused
    }
    [_colorStatus setObject:@(-1) atIndexedSubscript:0];                    // the first cell color status is reserved (-1) for white
    
    _cellColor = [[NSMutableArray alloc] initWithCapacity:7];
    for (int i = 0; i < 7; ++i) {
        [_cellColor addObject:@(0)];                                        // zero = white
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.createScheduledEventInfo.scheduleEditMode == kScheduleReview) {
        // disable the schedule input name text field and populate with existing schedule name
        self.scheduleNameOutlet.enabled = NO;
        self.numberOfWeeksOutlet.enabled = NO;
        self.repeatCountOutlet.enabled = NO;
        self.scheduleOperationModeOutlet.enabled = NO;
        [self configureScreenElements];
    } else if (self.createScheduledEventInfo.scheduleEditMode == kScheduleEdit){
        [self configureScreenElements];
    }
}

- (void)configureScreenElements
{
    self.scheduleNameOutlet.text = self.createScheduledEventInfo.scheduleName;
    self.numberOfWeeksOutlet.text = [NSString stringWithFormat:@"%ld",self.createScheduledEventInfo.numberOfWeeks];
    self.repeatCountOutlet.text = [NSString stringWithFormat:@"%ld",self.createScheduledEventInfo.repeatCount];
    [self.scheduleCollectionView setUserInteractionEnabled:YES];
    [self fetchScheduledEvents:self.createScheduledEventInfo.scheduleName];
    [self setupScheduleScreenParameters:self.createScheduledEventInfo.scheduleName];
}

- (IBAction)repeatCountInput:(id)sender {
    if ([self.repeatCountOutlet.text integerValue] != self.createScheduledEventInfo.numberOfWeeks) {
        [self enableUpdateButton];
    }
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

- (IBAction)scheduleOperationModeAction:(id)sender
{
    [self enableUpdateButton];
}

- (void)enableUpdateButton
{
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Update"
                                                                    style:UIBarButtonItemStylePlain target:self action:@selector(updateButtonPressed)];
    self.navigationItem.rightBarButtonItem = rightButton;
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self.createScheduledEventInfo setScheduleEditMode:kScheduleEdit];
        [self.scheduleCollectionView setUserInteractionEnabled:YES];
        [self setupScheduleScreenParameters:self.scheduleNameOutlet.text];
        return;
    }
    [self.createScheduledEventInfo setScheduleEditMode:kScheduleNoEdit];
}

- (void)setupScheduleScreenParameters:(NSString *)scheduleName
{
    Schedule *schedule = [self loadExistingSchedueInfo:scheduleName];
    self.numberOfWeeks = schedule.numberOfWeeks;
    self.numberOfWeeksOutlet.text = [NSString stringWithFormat: @"%@", self.numberOfWeeks];
    self.repeatCountOutlet.text = [NSString stringWithFormat: @"%@", schedule.repeatCount];
    self.scheduleOperationModeOutlet.selectedSegmentIndex = [schedule.operationalMode integerValue];

    [self.scheduleCollectionView reloadData];
}

- (Schedule *)loadExistingSchedueInfo:(NSString *)scheduleName
{
    NSArray *scheduledEvents = [self.coreDataHelper fetchDataFor:@"Schedule" withPredicate:@{@"propertyName" : @"scheduleName", @"value" : scheduleName} sortKey:nil scheduleInfo:nil];
    Schedule *schedule = [scheduledEvents firstObject];
    
    return schedule;
}

- (IBAction)numberOfWeeksInput:(id)sender
{
    [self.scheduleCollectionView reloadData];
}

- (NSInteger)obtainColorIndex
{
    NSInteger colorIndex;

    colorIndex = [self.colorStatus indexOfObject:[NSNumber numberWithInt:0]];
    
    if (colorIndex != NSNotFound) {
        [self setColorStatusUsed:colorIndex];
        return colorIndex;
    }
    return NSNotFound;
}

- (void)setColorStatusFree:(NSInteger)coloreIndex
{
    [self.colorStatus setObject:@(0) atIndexedSubscript:coloreIndex];
}

- (void)setColorStatusUsed:(NSInteger)colorIndex
{
    [self.colorStatus setObject:@(1) atIndexedSubscript:colorIndex];
}

- (void)setCellColor:(NSInteger)cell cellColor:(NSInteger)cellColor
{
    [self.cellColor setObject:@(cellColor) atIndexedSubscript:cell];
}

- (NSInteger)getCellColor:(NSInteger)cell
{
    return [[self.cellColor objectAtIndex:cell] integerValue];
}

#pragma mark - ScheduleDayEventDelegate

- (ScheduledEventInfo *)dayToBeScheduled
{
    NSInteger color;
    
    // if the cell color = 0 (white) then is needs a new color else us existing color
    if ([[self.cellColor objectAtIndex:self.createScheduledEventInfo.day] isEqualToNumber:@(0)]) {
        color = [self obtainColorIndex];
        [self setCellColor:self.createScheduledEventInfo.day cellColor:color];
    } else {
        color = [self getCellColor:self.createScheduledEventInfo.day];
    }
    
    self.createScheduledEventInfo.colorIndex = color;

    return self.createScheduledEventInfo;
}

// reload the section - events have been saved
- (void)daysConfigured:(NSInteger)week
{
    [self fetchScheduledEvents:self.createScheduledEventInfo.scheduleName];

    [self.scheduleCollectionView reloadSections:[NSIndexSet indexSetWithIndex:self.createScheduledEventInfo.week]];
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
    self.createScheduledEventInfo.week = indexPath.section;
    self.createScheduledEventInfo.day = indexPath.row;
    self.createScheduledEventInfo.operationalMode = [self.scheduleOperationModeOutlet selectedSegmentIndex];
    if (self.createScheduledEventInfo.scheduleEditMode <= 0) {
        self.createScheduledEventInfo.scheduleEditMode = kScheduleEdit;
    }
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

        // set this color to used
        [self setColorStatusUsed:colorIndex];
    }
    
    // configure the cell color
    [self setCellColor:day cellColor:colorIndex];
    
    cell.dayCellNumberOfEvents.text = [NSString stringWithFormat:@"Events: %ld", totalEvents];
    cell.backgroundColor = [_cellAvailableColors objectAtIndex: colorIndex];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
    ScheduleDayEventsViewController *scheduleEventViewController = [segue destinationViewController];
    scheduleEventViewController.scheduleEventDelegate = self;
}

- (void)updateButtonPressed
{
    Schedule *schedule = [self loadExistingSchedueInfo:self.createScheduledEventInfo.scheduleName];
    
    schedule.scheduleName = self.scheduleNameOutlet.text;
    schedule.numberOfWeeks = @([self.numberOfWeeksOutlet.text integerValue]);
    schedule.repeatCount = @([self.repeatCountOutlet.text integerValue]);
    schedule.operationalMode = @(self.scheduleOperationModeOutlet.selectedSegmentIndex);
    
    [self.coreDataHelper save];
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
    self.scheduledEvents = [self.coreDataHelper fetchDataFor:scheduleEntityName withPredicate:@{@"propertyName" : @"scheduleName", @"value" : scheduleName} sortKey:nil scheduleInfo:nil];
}

@end
