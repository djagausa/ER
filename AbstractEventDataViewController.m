//
//  AbstractWeightDataViewController.m
//  ExerciseRecording
//
//  Created by Douglas Alexander on 4/24/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import "AbstractEventDataViewController.h"
#import "CoreDataHelper.h"
#import "WeightLiftingEvent.h"
#import "EventDataSectionHeaderCell.h"
#import "EventTableViewCell.h"
#import "Support.h"

@interface AbstractEventDataViewController ()

@property (nonatomic, assign) NSInteger                     numberOfSections;
@property (nonatomic, assign) NSInteger                     numberOfItems;
@property (nonatomic, strong) NSFetchedResultsController    *fetchedResultsController;

@end

static NSString *SectionHeaderCellIdentifier = @"SectionHeader";
static NSString *CellIdentifier = @"EventCell";


@implementation AbstractEventDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.selectedEvent = [[SelectedEvent alloc] init];
    self.selectedEvent = [self.delegate selectedEventDataIs];
    
    self.coreDataHelper = [[CoreDataHelper alloc] init];
    self.coreDataHelper.managedObjectContext = self.managedObjectContext;
    self.coreDataHelper.defaultSortAttribute = @"date";
    [self fetchEvents];
}

- (void)viewDidAppear:(BOOL)animated
{
    // This really shouldn't need to be done per Apple's documentation, but the initial
    // loading of the table cells don't expand correctly.
    
    [super viewDidAppear:animated];
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

#pragma mark - Init

- (NSString *)dateToFormatMMddyyy:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSString *convertedDate = [dateFormatter stringFromDate:date];
    NSString *formattedDate = [[NSString alloc] initWithFormat:@"Date: %@", convertedDate];
    
    return formattedDate;
}

#pragma mark - Table view methods
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    EventDataSectionHeaderCell *sectionHeader = [tableView dequeueReusableCellWithIdentifier:SectionHeaderCellIdentifier];
    
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([self selectedEvent].eventCategory) {
        case kWeights:
            {
                WeightLiftingEvent *weightEvent = [self.coreDataHelper.fetchedResultsController objectAtIndexPath:indexPath];
                
                EventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                cell.label1.text = [NSString stringWithFormat:@"%@", weightEvent.setNumber];
                cell.label2.text = [NSString stringWithFormat:@"%@", weightEvent.repCount];
                cell.label3.text = [NSString stringWithFormat:@"%@", weightEvent.weight];
                cell.note.text = weightEvent.notes;
                tableView.estimatedRowHeight = 44.0f;
                tableView.rowHeight = UITableViewAutomaticDimension;
                return cell;
            }
            break;
            
        case kWalking:
        case kRunning:
        case kStretching:
        case kEliptical:
        case kBicycling:
            {
                AerobicEvent *aerobicEvent = [self.coreDataHelper.fetchedResultsController objectAtIndexPath:indexPath];
                EventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                switch ([[self selectedEvent] eventCategory]) {
                    case kBicycling:
                        {
                            cell.label1.text = [NSString stringWithFormat:@"%ld:%02ld", [aerobicEvent.duration integerValue]/ 60, [aerobicEvent.duration integerValue] % 60];
                            cell.label2.text = [NSString stringWithFormat:@"%@", aerobicEvent.heartRate];
                            cell.label3.text = [NSString stringWithFormat:@"%@", aerobicEvent.cadenace];
                            cell.note.text = aerobicEvent.note;
                            tableView.estimatedRowHeight = 44.0f;
                            tableView.rowHeight = UITableViewAutomaticDimension;
                            return cell;
                        }
                        break;
                    case kWalking:
                    case kRunning:
                    {
                        cell.label1.text = [NSString stringWithFormat:@"%ld:%02ld", [aerobicEvent.duration integerValue]/ 60, [aerobicEvent.duration integerValue] % 60];
                        cell.label2.text = [NSString stringWithFormat:@"%@", aerobicEvent.heartRate];
                        cell.label3.text = [NSString stringWithFormat:@"%@", aerobicEvent.distance];
                        cell.note.text = aerobicEvent.note;
                        tableView.estimatedRowHeight = 44.0f;
                        tableView.rowHeight = UITableViewAutomaticDimension;
                        return cell;
                    }
                        break;

                    default:
                        break;
                }
            }
            break;
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = [[self.coreDataHelper.fetchedResultsController sections] count];
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.coreDataHelper.fetchedResultsController sections] objectAtIndex:section];
    
    NSInteger count = [sectionInfo numberOfObjects];
    
    return count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 22.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - Core Data

- (void)fetchEvents
{
    switch ([self selectedEvent].eventCategory) {
        case kWeights:
            {
                [self.coreDataHelper fetchItemsMatching:weightLiftingEventsFileName
                                           forAttribute:nil
                                              sortingBy:@"date"
                                          withPredicate:[[self selectedEvent] eventName] groupBy:nil];
            }
            break;
            
        case kWalking:
        case kRunning:
        case kStretching:
        case kEliptical:
        case kBicycling:
            {
                [self.coreDataHelper fetchItemsMatching:aerobicEventsFileName
                                           forAttribute:nil
                                              sortingBy:@"date"
                                          withPredicate:[[self selectedEvent] eventName] groupBy:nil];
            }
            break;
            
        default:
            break;
    }
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
