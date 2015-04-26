//
//  AddWeightDataVC.m
//  ExerciseRecording
//
//  Created by Douglas Alexander on 3/23/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import "AddWeightDataVC.h"
#import "CoreDataHelper.h"
#import "WeightLiftingEvent.h"
#import "WeightEventTVC.h"
#import "AddWeightDataSectionHeaderCell.h"
#import "WeightEventTableCellNoNote.h"
#import "Support.h"

@interface AddWeightDataVC () <UITextViewDelegate>

@property (nonatomic, strong) NSNumber                      *setCount;
@property (nonatomic, strong) NSString                      *notes;
@property (nonatomic, strong) NSNumber                      *sectionZeroRowCount;

@end

static NSString *CellIdentifier = @"WeightEventCell";
static NSString *CellIdentifierNoNote = @"WeightEventCellNoNote";
static NSString *SectionHeaderCellIdentifier = @"SectionHeader";
static NSString *notePlaceHolder = @"Enter a note for this set:";

BOOL setCountInitialized;

@implementation AddWeightDataVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self fetchWeightEvents];
    [self setupInitialValues];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
    
    self.note.delegate = self;
    self.note.text = notePlaceHolder;
    [self.noteSwitch setOn:NO];
    setCountInitialized = NO;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    // This really shouldn't need to be done per Apple's documentation, but the initial
    // loading of the table cells don't expand correctly.
    
    [super viewDidAppear:animated];
    [self.weightEventsTable reloadData];
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
    [self.weightEventsTable reloadData];
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

    self.repsInput.text = [NSString stringWithFormat:@"%@", self.defaultWeightLifting.numOfReps];
    self.weightInput.text = [NSString stringWithFormat:@"%@", self.defaultWeightLifting.weight];
    self.navigationItem.title = [NSString stringWithFormat:@"Add %@ Data", self.defaultWeightLifting.eventName];
    self.dateLabel.text = [self dateToFormatMMddyyy:[NSDate date]];
    self.setCount = @(0);
    [self updateSetCount];
    
    [self refresh];
    
}

- (void)updateSetCount
{
    self.setCount = @(self.setCount.intValue + 1) ;
    self.setInput.text = [NSString stringWithFormat:@"%@", self.setCount];
}

- (void)setupNewWeightLiftingEvent:(WeightLiftingEvent *)weightLiftingEvent
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [dateFormatter setCalendar:calendar];
    
    NSDate *date = [NSDate date];
    
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];

    weightLiftingEvent.date = [calendar dateFromComponents:dateComponents];
    weightLiftingEvent.setNumber = self.setCount;
    weightLiftingEvent.repCount = @([self.repsInput.text integerValue]);
    if ([self.note.text isEqualToString:notePlaceHolder]) {
        weightLiftingEvent.notes = @"";
    } else {
        weightLiftingEvent.notes = self.note.text;
    }
    weightLiftingEvent.weight= @([self.weightInput.text integerValue]);
    weightLiftingEvent.defaultEvent = self.defaultWeightLifting;
    
}
- (void)saveAction
{
    // Surround the "add" functionality with undo grouping
    NSUndoManager *manager = self.coreDataHelper.managedObjectContext.undoManager;
    [manager beginUndoGrouping];
    {
        WeightLiftingEvent *weightLiftingEvent = (WeightLiftingEvent *)[self.coreDataHelper newObject:@"WeightLiftingEvent"];
        [self setupNewWeightLiftingEvent:weightLiftingEvent];
    }
    [manager endUndoGrouping];
    [manager setActionName:@"Add"];
    [self.coreDataHelper save];
    [self updateSetCount];
    [self setupNoteInputTextField];
    [self refresh];

}

- (void)setupNoteInputTextField
{
    self.note.text = notePlaceHolder;
    [self.note resignFirstResponder];

}

- (void)refresh
{
    [self fetchWeightEvents];
    [[self weightEventsTable] reloadData];
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
    WeightLiftingEvent *weightEvent = [self.coreDataHelper.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        [self initializeSetCount:weightEvent];
    }
    if ([self.noteSwitch isOn]) {
        WeightEventTVC *cell = [self.weightEventsTable dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.setCount.text = [NSString stringWithFormat:@"%@", weightEvent.setNumber];
        cell.repsCount.text = [NSString stringWithFormat:@"%@", weightEvent.repCount];
        cell.weight.text = [NSString stringWithFormat:@"%@", weightEvent.weight];
        cell.note.hidden = NO;
        cell.note.text = weightEvent.notes;
        self.weightEventsTable.estimatedRowHeight = 44.0f;
        self.weightEventsTable.rowHeight = UITableViewAutomaticDimension;
        return cell;
    } else {
        WeightEventTableCellNoNote *cell = [self.weightEventsTable dequeueReusableCellWithIdentifier:CellIdentifierNoNote];
        cell.setCount.text = [NSString stringWithFormat:@"%@", weightEvent.setNumber];
        cell.repsCount.text = [NSString stringWithFormat:@"%@", weightEvent.repCount];
        cell.weight.text = [NSString stringWithFormat:@"%@", weightEvent.weight];
        self.weightEventsTable.rowHeight = 22.0f;
        return cell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    AddWeightDataSectionHeaderCell *sectionHeader = [self.weightEventsTable dequeueReusableCellWithIdentifier:SectionHeaderCellIdentifier];
    
    id <NSFetchedResultsSectionInfo> theSection = [[self.coreDataHelper.fetchedResultsController sections] objectAtIndex:section];
    
    /*
     Section information derives from an event's sectionIdentifier, which is a string representing the number (year * 1000) + month.
     To display the section title, convert the year, month and day components to a string representation.
     */
    static NSDateFormatter *formatter = nil;
    
    if (!formatter)
    {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setCalendar:[NSCalendar currentCalendar]];
        
        NSString *formatTemplate = [NSDateFormatter dateFormatFromTemplate:@"MM/dd/yyyy" options:0 locale:[NSLocale currentLocale]];
        [formatter setDateFormat:formatTemplate];
    }
    
    NSInteger numericSection = [[theSection name] integerValue];
    NSInteger year = numericSection / 1000;
    NSInteger month = (numericSection - (year * 1000)) /100;
    NSInteger day = (numericSection - (year * 1000)) - (month * 100);
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.year = year;
    dateComponents.month = month;
    dateComponents.day = day;
    
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
    
    NSString *titleString = [formatter stringFromDate:date];
    
    sectionHeader.date.text = titleString;
    
    return sectionHeader;
}

- (IBAction)noteSwitchChanged:(id)sender
{
    [[self weightEventsTable] reloadData];
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
