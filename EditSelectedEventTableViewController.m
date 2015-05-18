//
//  EditSelectedEventTableViewController.m
//  ExerciseRecording
//
//  Created by Douglas Alexander on 4/23/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import "EditSelectedEventTableViewController.h"
#import "CoreDataHelper.h"
#import "WeightLiftingEvent.h"
#import "EditEventTableViewCell.h"
#import "WeightLiftingEvent.h"
#import "AerobicEvent.h"
#import "Support.h"
#import "SelectedEvent.h"

@interface EditSelectedEventTableViewController ()

@property (nonatomic, strong) NSMutableArray        *weightLiftingEventCopy;
@property (nonatomic, strong) NSMutableArray        *aerobicEventCopy;

@property (nonatomic, strong) CoreDataHelper        *coreDataHelper;
@property (nonatomic, strong) SelectedEvent         *selectEditEvent;
@property (nonatomic, strong) WeightLiftingEvent    *weightLiftingEvent;
@property (nonatomic, strong) AerobicEvent          *aerobicEvent;
@property (strong, nonatomic) IBOutlet UITableView  *editSelectedEventTable;
@property (nonatomic, strong) SelectedEvent         *selectedEvent;

@end

@implementation EditSelectedEventTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.selectEditEvent = [[SelectedEvent alloc]init];
    self.selectEditEvent = [self.delegate selectEventDataIs];

    self.selectedEvent =[[SelectedEvent alloc]init];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
//     Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.title = self.selectEditEvent.eventName;
    
    self.coreDataHelper = [[CoreDataHelper alloc] init];
    self.coreDataHelper.managedObjectContext = self.managedObjectContext;
    
    self.editSelectedEventTable.estimatedRowHeight = 22.0f;
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.editSelectedEventTable reloadData];

}

- (SelectedEvent *)selectedEventDataIs
{
    return self.selectedEvent;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSInteger count;
    switch (section) {
        case 0:
            count = 1;
            break;
        
        default:
            switch (self.selectEditEvent.eventCategory) {
                case kWeights:
                    count = self.weightLiftingEventCopy.count;
                    break;
                default:
                    count = self.aerobicEventCopy.count;
                    break;
            }
            break;
    }

   return count;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return NO;
            break;
            
        default:
            break;
    }
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *headerTitle;
    
    switch (section) {
        case 0:
            headerTitle = @"Setup Data";
            break;
            
        case 1:
            headerTitle = @"Event Data";
            break;
            
        default:
            break;
    }
    
    return headerTitle;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    static NSDateFormatter *dateFormatter = nil;

    switch (indexPath.section) {
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:@"EditSetupCell"];
            cell.textLabel.text = @"Edit Setup Data";
            return cell;
            break;
            
        default:

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
                        EditEventTableViewCell *cell = [self.editSelectedEventTable dequeueReusableCellWithIdentifier:@"EditEventCell"];
                        WeightLiftingEvent *weightEvent = [self.weightLiftingEventCopy objectAtIndex:indexPath.row];
                        NSString *convertedDate = [dateFormatter stringFromDate:weightEvent.date];
                        NSString *formattedDate = [[NSString alloc] initWithFormat:@"%@", convertedDate];
                        
                        cell.eventDate.text = formattedDate;
                        cell.eventL1.text = [NSString stringWithFormat:@"Set: %@", weightEvent.setNumber];
                        cell.eventL2.text = [NSString stringWithFormat:@"Reps: %@", weightEvent.repCount];
                        cell.eventL3.text = [NSString stringWithFormat:@"Weight: %@", weightEvent.weight];
                        cell.eventNote.text = weightEvent.notes;
                        return cell;
                    }
                    break;
                default:
                    {
                        EditEventTableViewCell *cell = [self.editSelectedEventTable dequeueReusableCellWithIdentifier:@"EditEventCell"];
                        AerobicEvent *aerobicEvent = [self.aerobicEventCopy objectAtIndex:indexPath.row];
                        NSString *convertedDate = [dateFormatter stringFromDate:aerobicEvent.date];
                        NSString *formattedDate = [[NSString alloc] initWithFormat:@"%@", convertedDate];
                        
                        cell.eventDate.text = formattedDate;
                        cell.eventNote.text = aerobicEvent.note;

                        switch (self.selectEditEvent.eventCategory) {
                            case kWalking:
                            case kRunning:
                                {
                                    cell.eventL1.text = [NSString stringWithFormat:@"Time: %ld:%02ld", [aerobicEvent.duration integerValue]/ 60, [aerobicEvent.duration integerValue] % 60];
                                    cell.eventL2.text = [NSString stringWithFormat:@"HR: %@", aerobicEvent.heartRate];
                                    cell.eventL3.text = [NSString stringWithFormat:@"Distance: %@", aerobicEvent.distance];
                                    return cell;
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
                                    cell.eventL1.text = [NSString stringWithFormat:@"Time: %ld:%02ld", [aerobicEvent.duration integerValue]/ 60, [aerobicEvent.duration integerValue] % 60];
                                    cell.eventL2.text = [NSString stringWithFormat:@"HR: %@", aerobicEvent.heartRate];
                                    cell.eventL3.text = [NSString stringWithFormat:@"CAD: %@", aerobicEvent.cadenace];
                                    return cell;
                                }
                                break;
                                
                            default:
                                break;
                        }
                    }
                    break;
            }
            break;
    }

    return cell;
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        [self.coreDataHelper deleteObject:self.coreDataHelper.fetchedResultsController.fetchedObjects[indexPath.row]];

        switch (self.selectEditEvent.eventCategory) {
            case kWeights:
                {
                    [self.weightLiftingEventCopy removeObjectAtIndex:indexPath.row] ;
                }
                break;
            default:
                {
                    [self.aerobicEventCopy removeObjectAtIndex:indexPath.row] ;
                }
                break;
        }
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            self.selectedEvent.eventName = self.selectEditEvent.eventName;
            self.selectedEvent.eventCategory = self.selectEditEvent.eventCategory;
            break;
            
        case 1:
            switch (self.selectEditEvent.eventCategory) {
                case kWeights:
                    {
                        WeightLiftingEvent *weightEvent = [self.weightLiftingEventCopy objectAtIndex:indexPath.row];
                        self.selectedEvent.weightLiftingEvent = weightEvent;
                        self.selectedEvent.eventCategory = kWeights;
                    }
                    break;
                default:
                    {
                        AerobicEvent *aerobicEvent = [self.aerobicEventCopy objectAtIndex:indexPath.row];
                        self.selectedEvent.aerobicEvent = aerobicEvent;
                        self.selectedEvent.eventCategory = [aerobicEvent.category integerValue];
                    }
                    break;
            }

            break;
        default:
            break;
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"EditEvent"]) {
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
        EditEventViewController *editEventViewController = [segue destinationViewController];
        editEventViewController.delegate = self;
    }
    
    if ([[segue identifier] isEqualToString:@"EditSetupData"]) {
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
        SetupExrciseInfoViewController *setupExerciseViewController = [segue destinationViewController];
        setupExerciseViewController.delegate = self;
        setupExerciseViewController.editMode = YES;
    }

}

#pragma  mark - CoreData

- (void) fetchEvents
{
    switch (self.selectEditEvent.eventCategory) {
        case kWeights:
            {
                [self.coreDataHelper fetchItemsMatching:weightLiftingEventsFileName
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
                [self.coreDataHelper fetchItemsMatching:aerobicEventsFileName
                                           forAttribute:nil
                                              sortingBy:@"date"
                                          withPredicate:[[self selectEditEvent] eventName] groupBy:nil];
            }
            self.aerobicEventCopy = [NSMutableArray arrayWithArray: self.coreDataHelper.fetchedResultsController.fetchedObjects];
            break;

         default:
            break;
    }
}

@end
