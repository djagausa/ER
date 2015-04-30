//
//  EditSelectedEventTableViewController.m
//  ExerciseRecording
//
//  Created by Douglas Alexander on 4/23/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import "EditSelectedEventTableViewController.h"
#import "SelectedEditEvent.h"
#import "CoreDataHelper.h"
#import "WeightLiftingEvent.h"
#import "EditWeightTableViewCell.h"
#import "WeightLiftingEvent.h"
#import "AerobicEvent.h"
#import "Support.h"
#import "SelectedEvent.h"

@interface EditSelectedEventTableViewController ()

@property (nonatomic, strong) NSMutableArray        *weightLiftingEventCopy;
@property (nonatomic, strong) NSMutableArray        *aerobicEventCopy;

@property (nonatomic, strong) CoreDataHelper        *coreDataHelper;
@property (nonatomic, strong) SelectedEditEvent     *selectEditEvent;
@property (nonatomic, strong) WeightLiftingEvent    *weightLiftingEvent;
@property (nonatomic, strong) AerobicEvent          *aerobicEvent;
@property (strong, nonatomic) IBOutlet UITableView  *editSelectedEventTable;
@property (nonatomic, strong) SelectedEvent         *selectedEvent;

@end

@implementation EditSelectedEventTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.selectEditEvent = [[SelectedEditEvent alloc]init];
    self.selectEditEvent = [self.delegate selectEventDataIs];

    self.selectedEvent =[[SelectedEvent alloc]init];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
//     Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.title = self.selectEditEvent.eventName;
    
    self.coreDataHelper = [[CoreDataHelper alloc] init];
    self.coreDataHelper.managedObjectContext = self.managedObjectContext;
    
    self.editSelectedEventTable.estimatedRowHeight = 44.0f;
    self.editSelectedEventTable.rowHeight = UITableViewAutomaticDimension;

    [self fetchEvents];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.editSelectedEventTable reloadData];
}

- (SelectedEvent *)selectedEventDataIs
{
    return self.selectedEvent;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   return self.weightLiftingEventCopy.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    static NSDateFormatter *dateFormatter = nil;

    if (!dateFormatter)
    {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setCalendar:[NSCalendar currentCalendar]];
        
        NSString *formatTemplate = [NSDateFormatter dateFormatFromTemplate:@"MM/dd/yyyy" options:0 locale:[NSLocale currentLocale]];
        [dateFormatter setDateFormat:formatTemplate];
    }

    switch (self.selectEditEvent.eventCategory) {
        case kWeights:
            {
                EditWeightTableViewCell *cell = [self.editSelectedEventTable dequeueReusableCellWithIdentifier:@"EditWeightCell"];
                WeightLiftingEvent *weightEvent = [self.weightLiftingEventCopy objectAtIndex:indexPath.row];
                NSString *convertedDate = [dateFormatter stringFromDate:weightEvent.date];
                NSString *formattedDate = [[NSString alloc] initWithFormat:@"%@", convertedDate];
                
                cell.weightDate.text = formattedDate;
                cell.weightSet.text = [NSString stringWithFormat:@"Set: %@", weightEvent.setNumber];
                cell.weightReps.text = [NSString stringWithFormat:@"Reps: %@", weightEvent.repCount];
                cell.weightWeight.text = [NSString stringWithFormat:@"Weight: %@", weightEvent.weight];
                cell.weightNote.text = weightEvent.notes;
                return cell;
            }
            break;
        case kWalking:
        case kRunning:
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"EditRunningCell" forIndexPath:indexPath];
                
            }
            break;
        case kStretching:
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"EditStretchingCell" forIndexPath:indexPath];
                
            }
            break;
        case kEliptical:
            {
                
            }
            break;
        case kBicycling:
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"EditBicyclingCell" forIndexPath:indexPath];
            }
            break;
        default:
            break;
    }
    return cell;
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
       
        switch (self.selectEditEvent.eventCategory) {
            case kWeights:
            {
                [self.coreDataHelper deleteObject:self.coreDataHelper.fetchedResultsController.fetchedObjects[indexPath.row]];
                [self.weightLiftingEventCopy removeObjectAtIndex:indexPath.row] ;
            }
                break;
            case kWalking:
            case kRunning:
            {
                
            }
                break;
            case kStretching:
            {
                
            }
                break;
            case kEliptical:
            {
                
            }
                break;
            case kBicycling:
            {
            }
                break;
            default:
                break;
        }
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (self.selectEditEvent.eventCategory) {
        case kWeights:
            {
                WeightLiftingEvent *weightEvent = [self.weightLiftingEventCopy objectAtIndex:indexPath.row];
                self.selectedEvent.weightLiftingEvent = weightEvent;
                self.selectedEvent.eventCategory = kWeights;
            }
            break;
        case kWalking:
        case kRunning:
            {
                
            }
            break;
        case kStretching:
            {
                
            }
            break;
        case kEliptical:
            {
                
            }
            break;
        case kBicycling:
            {
            }
            break;
        default:
            break;
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
    EditEventViewController *editEventViewController = [segue destinationViewController];
    editEventViewController.delegate = self;
}

#pragma  mark - CoreData

- (void) fetchEvents
{
    switch (self.selectEditEvent.eventCategory) {
        case kWeights:
            {
                [self.coreDataHelper fetchItemsMatching:@"WeightLiftingEvent"
                                           forAttribute:nil
                                              sortingBy:@"date"
                                          withPredicate:[[self selectEditEvent] eventName] groupBy:nil];
            }
            self.weightLiftingEventCopy = [NSMutableArray arrayWithArray: self.coreDataHelper.fetchedResultsController.fetchedObjects];
            break;
            
        case kWalking:
        case kRunning:
        case kStretching:
        case kEliptical:
        case kBicycling:
            {
                [self.coreDataHelper fetchItemsMatching:@"AerobicEvent"
                                           forAttribute:nil
                                              sortingBy:@"date"
                                          withPredicate:[[self selectEditEvent] eventName] groupBy:nil];
            }
            break;

         default:
            break;
    }
}

@end
