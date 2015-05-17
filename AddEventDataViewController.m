//
//  AddWeightDataVC.m
//  ExerciseRecording
//
//  Created by Douglas Alexander on 3/23/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import "AddEventDataViewController.h"
#import "CoreDataHelper.h"
#import "WeightLiftingEvent.h"
#import "EventTableViewCell.h"
#import "Support.h"

@interface AddEventDataViewController () <UITextViewDelegate>

@property (nonatomic, strong) NSNumber                      *setCount;
@property (nonatomic, strong) NSString                      *notes;
@property (nonatomic, strong) NSNumber                      *sectionZeroRowCount;

@end

static NSString *CellIdentifier = @"EventCell";
static NSString *CellIdentifierNoNote = @"EventCellNoNote";
static NSString *notePlaceHolder = @"Enter a note for this set:";

BOOL setCountInitialized;

@implementation AddEventDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.defaultWeightLifting = self.selectedEvent.defaultWeightLiftingData;
    self.defaultAerobic = self.selectedEvent.defaultAerobicData;
    
    [self fetchEvents];
    [self setupInitialValues];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
    
    self.note.delegate = self;
    self.note.text = notePlaceHolder;
    [self.noteSwitch setOn:NO];
    
    self.navigationItem.title = [NSString stringWithFormat:@"Add %@ Data", self.selectedEvent.eventName];
}

- (void)viewDidAppear:(BOOL)animated
{
    // This really shouldn't need to be done per Apple's documentation, but the initial
    // loading of the table cells don't expand correctly.
    
    [super viewDidAppear:animated];
    [self.eventTable reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
}

- (void)didChangePreferredContentSize:(NSNotification *)notification
{
    [self.eventTable reloadData];
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([self.note.text isEqualToString:notePlaceHolder]) {
        self.note.text = @"";
    }
    [self.note becomeFirstResponder];
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    if ([self.note.text isEqualToString:@""]) {
        self.note.text = notePlaceHolder;
    }
    [self.note resignFirstResponder];
}

#pragma mark - Init
- (void)initializeSetCount:(WeightLiftingEvent *)weightLiftingEvent
{
    if (!setCountInitialized) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        NSDateComponents *todayComp = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
        
        NSDateComponents *savedComp = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:weightLiftingEvent.date];
        
        if ([todayComp day] == [savedComp day] && [todayComp month] == [savedComp month] && [todayComp year] == [savedComp year]) {
            self.setCount = [self sectionZeroRowCount];
        } else {
            self.setCount = @(0);
        }
        [self updateSetCount];
        setCountInitialized = YES;
    }
}

- (void)setupInitialValues
{
    self.dateLabel.text = [self dateToFormatMMddyyy:[NSDate date]];

    switch (self.selectedEvent.eventCategory) {
        case kWeights:
            {
                self.label1.text = self.hrdLab1.text = @"Set";
                self.label2.text = self.hdrLab2.text = @"Reps";
                self.label3.text = self.hdrLab3.text = @"Weight";
                self.in2Label.text = [NSString stringWithFormat:@"%@", self.defaultWeightLifting.numOfReps];
                self.in3Label.text = [NSString stringWithFormat:@"%@", self.defaultWeightLifting.weight];
                self.setCount = @(0);
                [self updateSetCount];
                setCountInitialized = NO;
            }
            break;
        case kBicycling:
            {
                self.label1.text = self.hrdLab1.text = @"Time";
                self.label2.text = self.hdrLab2.text = @"Avg HR";
                self.label3.text = self.hdrLab3.text = @"CAD";
                self.in1Label.text = [NSString stringWithFormat:@"%ld:%02ld", [self.defaultAerobic.totalTime integerValue]/60, [self.defaultAerobic.totalTime integerValue] % 60];
                self.in2Label.text = [NSString stringWithFormat:@"%@", self.defaultAerobic.desiredHR];
                self.in3Label.text = [NSString stringWithFormat:@"%@", self.defaultAerobic.cadence];
            }
            break;
        case kWalking:
        case kRunning:
            {
                self.label1.text = self.hrdLab1.text = @"Time";
                self.label2.text = self.hdrLab2.text = @"Avg HR";
                self.label3.text = self.hdrLab3.text = @"Distance";
                self.in1Label.text = @"HH:MM";
                self.in2Label.text = @"";
                self.in3Label.text = [NSString stringWithFormat:@"%@", self.defaultAerobic.distance];
            }
            break;

        default:
            break;
    }

    
    [self refresh];
    
}

- (void)updateSetCount
{
    self.setCount = @(self.setCount.intValue + 1) ;
    self.in1Label.text = [NSString stringWithFormat:@"%@", self.setCount];
}

-(NSDate *)setupDate
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [dateFormatter setCalendar:calendar];
    
    NSDate *date = [NSDate date];
    
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    
    date = [calendar dateFromComponents:dateComponents];

    return date;
}
- (void)setupNewWeightLiftingEvent:(WeightLiftingEvent *)weightLiftingEvent
{
    weightLiftingEvent.date = [self setupDate];
    weightLiftingEvent.setNumber = self.setCount;
    weightLiftingEvent.repCount = @([self.in2Label.text integerValue]);
    if ([self.note.text isEqualToString:notePlaceHolder]) {
        weightLiftingEvent.notes = @"";
    } else {
        weightLiftingEvent.notes = self.note.text;
    }
    weightLiftingEvent.weight= @([self.in3Label.text integerValue]);
    weightLiftingEvent.defaultEvent = self.defaultWeightLifting;
}

- (void)setupNewAerobicEvent:(AerobicEvent *)aerobicEvent
{
    aerobicEvent.date = [self setupDate];
    if ([self.note.text isEqualToString:notePlaceHolder]) {
        aerobicEvent.note = @"";
    } else {
        aerobicEvent.note = self.note.text;
    }
    aerobicEvent.defaultEvent = self.defaultAerobic;
    aerobicEvent.category = @(self.selectedEvent.eventCategory);

    switch (self.selectedEvent.eventCategory) {
        case kBicycling:
            {
                aerobicEvent.duration = [self convertTimeToNumber: self.in1Label.text];
                aerobicEvent.heartRate = @([self.in2Label.text integerValue]);
                aerobicEvent.cadenace = @([self.in3Label.text integerValue]);
            }
            break;
        case kRunning:
        case kWalking:
        {
            aerobicEvent.duration = [self convertTimeToNumber: self.in1Label.text];
            aerobicEvent.heartRate = @([self.in2Label.text integerValue]);
            aerobicEvent.distance = @([self.in3Label.text integerValue]);
        }
            break;

        default:
            break;
    }
}

- (void)saveAction
{
    // Surround the "add" functionality with undo grouping
    NSUndoManager *manager = self.coreDataHelper.managedObjectContext.undoManager;
    [manager beginUndoGrouping];
    switch (self.selectedEvent.eventCategory) {
        case kWeights:
            {
                WeightLiftingEvent *weightLiftingEvent = (WeightLiftingEvent *)[self.coreDataHelper newObject:@"WeightLiftingEvent"];
                [self setupNewWeightLiftingEvent:weightLiftingEvent];
            }
            break;
            
        default:
            {
                AerobicEvent *aerobicEvent = (AerobicEvent *)[self.coreDataHelper newObject:@"AerobicEvent"];
                [self setupNewAerobicEvent:aerobicEvent];
            }
            break;
    }
    [manager endUndoGrouping];
    [manager setActionName:@"Add"];
    [self.coreDataHelper save];
}

- (void)setupNoteInputTextField
{
    self.note.text = notePlaceHolder;
    [self.note resignFirstResponder];

}

- (void)refresh
{
    [self fetchEvents];
    [[self eventTable] reloadData];
}

#pragma mark - Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = [[self.coreDataHelper.fetchedResultsController sections] count];
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.coreDataHelper.fetchedResultsController sections] objectAtIndex:section];
    
    NSInteger count = [sectionInfo numberOfObjects];
    
    if (section == 0) {
        [self setSectionZeroRowCount:@(count)];
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (self.selectedEvent.eventCategory) {
        case kWeights:
            {
                WeightLiftingEvent *weightEvent = [self.coreDataHelper.fetchedResultsController objectAtIndexPath:indexPath];
                
                if (indexPath.section == 0) {
                    [self initializeSetCount:weightEvent];
                }
                if ([self.noteSwitch isOn]) {
                    EventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    cell.label1.text = [NSString stringWithFormat:@"%@", weightEvent.setNumber];
                    cell.label2.text = [NSString stringWithFormat:@"%@", weightEvent.repCount];
                    cell.label3.text = [NSString stringWithFormat:@"%@", weightEvent.weight];
                    cell.note.hidden = NO;
                    cell.note.text = weightEvent.notes;
                    tableView.estimatedRowHeight = 44.0f;
                    tableView.rowHeight = UITableViewAutomaticDimension;
                    return cell;
                } else {
                    EventTableViewCell *cell = [self.eventTable dequeueReusableCellWithIdentifier:CellIdentifierNoNote];
                    cell.label1.text = [NSString stringWithFormat:@"%@", weightEvent.setNumber];
                    cell.label2.text = [NSString stringWithFormat:@"%@", weightEvent.repCount];
                    cell.label3.text = [NSString stringWithFormat:@"%@", weightEvent.weight];
                    self.eventTable.rowHeight = 22.0f;
                    return cell;
                }
            }
            break;
            
        case kBicycling:
            {
                AerobicEvent *aerobicEvent = [self.coreDataHelper.fetchedResultsController objectAtIndexPath:indexPath];
                NSInteger duration = [aerobicEvent.duration integerValue];

                if ([self.noteSwitch isOn]) {
                    EventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    cell.label1.text = [NSString stringWithFormat:@"%ld:%02ld", duration/60, duration % 60];
                    cell.label2.text = [NSString stringWithFormat:@"%@", aerobicEvent.heartRate];
                    cell.label3.text = [NSString stringWithFormat:@"%@", aerobicEvent.cadenace];
                    cell.note.hidden = NO;
                    cell.note.text = aerobicEvent.note;
                    tableView.estimatedRowHeight = 44.0f;
                    tableView.rowHeight = UITableViewAutomaticDimension;
                    return cell;
                } else {
                    EventTableViewCell *cell = [self.eventTable dequeueReusableCellWithIdentifier:CellIdentifierNoNote];
                    cell.label1.text = [NSString stringWithFormat:@"%ld:%02ld", duration/60, duration % 60];
                    cell.label2.text = [NSString stringWithFormat:@"%@", aerobicEvent.heartRate];
                    cell.label3.text = [NSString stringWithFormat:@"%@", aerobicEvent.cadenace];
                    self.eventTable.rowHeight = 22.0f;
                    return cell;
                }
            }
            break;

        case kWalking:
        case kRunning:
            {
                AerobicEvent *aerobicEvent = [self.coreDataHelper.fetchedResultsController objectAtIndexPath:indexPath];
                NSInteger duration = [aerobicEvent.duration integerValue];

                if ([self.noteSwitch isOn]) {
                    EventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    cell.label1.text = [NSString stringWithFormat:@"%ld:%02ld", duration/60, duration % 60];
                    cell.label2.text = [NSString stringWithFormat:@"%@", aerobicEvent.heartRate];
                    cell.label3.text = [NSString stringWithFormat:@"%@", aerobicEvent.distance];
                    cell.note.hidden = NO;
                    cell.note.text = aerobicEvent.note;
                    tableView.estimatedRowHeight = 44.0f;
                    tableView.rowHeight = UITableViewAutomaticDimension;
                    return cell;
                } else {
                    EventTableViewCell *cell = [self.eventTable dequeueReusableCellWithIdentifier:CellIdentifierNoNote];
                    cell.label1.text = [NSString stringWithFormat:@"%ld:%02ld", duration/60, duration % 60];
                    cell.label2.text = [NSString stringWithFormat:@"%@", aerobicEvent.heartRate];
                    cell.label3.text = [NSString stringWithFormat:@"%@", aerobicEvent.distance];
                    self.eventTable.rowHeight = 22.0f;
                    return cell;
                }
            }
            break;

            
        default:
            break;
    }
    return nil;
}

- (IBAction)noteSwitchChanged:(id)sender
{
    [[self eventTable] reloadData];
}

- (IBAction)setCountField:(id)sender {
}

- (IBAction)repCountField:(id)sender {
}

- (IBAction)weightField:(id)sender {
}

- (IBAction)addData:(id)sender
{
    [self saveAction];
    if (self.selectedEvent.eventCategory == kWeights) {
        [self updateSetCount];
    }
    [self setupNoteInputTextField];
    [self refresh];
    [self.addEventDataDelegate exerciseDataAdded];
}

- (IBAction)in1Input:(id)sender {
}

- (IBAction)in2Input:(id)sender {
}

- (IBAction)in3Input:(id)sender {
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
