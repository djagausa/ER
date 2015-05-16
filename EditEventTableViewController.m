//
//  EditEventTableViewController.m
//  ExerciseRecording
//
//  Created by Douglas Alexander on 4/23/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import "EditEventTableViewController.h"
#import "CoreDataHelper.h"
#import "DefaultWeightLifting.h"
#import "DefaultAerobic.h"
#import "Support.h"
#import "SelectedEvent.h"

@interface EditEventTableViewController ()

@property (nonatomic, strong) NSArray               *weightLiftingDefaultObjects;
@property (nonatomic, strong) NSArray               *aerobicDefaultObjects;
@property (nonatomic, strong) NSMutableArray        *weightLiftingDefaultObjectsCopy;
@property (nonatomic, strong) NSMutableArray        *aerobicDefaultObjectsCopy;
@property (nonatomic, strong) CoreDataHelper        *coreDataHelper;
@property (nonatomic, strong) DefaultWeightLifting  *defaultWeightLifting;
@property (nonatomic, strong) DefaultAerobic        *defaultAerobic;
@property (nonatomic, strong) SelectedEvent         *selectedEvent;

@end

@implementation EditEventTableViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectedEvent = [[SelectedEvent alloc]init];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.coreDataHelper = [[CoreDataHelper alloc] init];
    self.coreDataHelper.managedObjectContext = self.managedObjectContext;
    
    [self fetchEvents];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (SelectedEvent *)selectEventDataIs
{
    return self.selectedEvent;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger count = 0;
    
    if (self.weightLiftingDefaultObjectsCopy.count > 0)
    {
        count++;
    }
    
    if (self.aerobicDefaultObjectsCopy.count > 0)
    {
        count++;
    }
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    
    switch (section) {
        case AerobicCategory:
            if (self.aerobicDefaultObjectsCopy.count > 0) {
                count = self.aerobicDefaultObjectsCopy.count;
            }
            else
            {
                count = self.weightLiftingDefaultObjectsCopy.count;
                
            }
            break;
            
        case WeightCategory:
            count = self.weightLiftingDefaultObjectsCopy.count;
            break;
            
        default:
            break;
    }
    return count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    NSNumber *eventEnable;
    
    switch (indexPath.section) {
        case AerobicCategory:
            if (self.aerobicDefaultObjects.count > 0)
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"EditEventCell" forIndexPath:indexPath];
                DefaultAerobic *event = [self.aerobicDefaultObjectsCopy objectAtIndex:indexPath.row];
                cell.textLabel.text = event.eventName;
                eventEnable = event.enabled;
            }
            else
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"EditEventCell" forIndexPath:indexPath];
                DefaultWeightLifting *event = [self.weightLiftingDefaultObjectsCopy objectAtIndex:indexPath.row];
                cell.textLabel.text = event.eventName;
                eventEnable = event.enabled;
            }
            break;
            
        case WeightCategory:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"EditEventCell" forIndexPath:indexPath];
            DefaultWeightLifting *event = [self.weightLiftingDefaultObjectsCopy objectAtIndex:indexPath.row];
            cell.textLabel.text = event.eventName;
            eventEnable = event.enabled;
        }
            break;
            
        default:
            break;
    }
    if ([eventEnable isEqualToNumber:@(0)]) {
        cell.backgroundColor = [UIColor redColor];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }

    return cell;

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *headerTitle;
    
    switch (section) {
        case AerobicCategory:
            if (self.aerobicDefaultObjects.count > 0) {
                headerTitle = @"Aerobic Events";
            }
            else
            {
                headerTitle = @"Weight Lifting Events";
            }
            break;
            
        case WeightCategory:
            headerTitle = @"Weight Lifting Events";
            break;
            
        default:
            break;
    }
    
    return headerTitle;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case AerobicCategory:
            if (self.aerobicDefaultObjects.count > 0)
            {
                DefaultAerobic *event = [self.aerobicDefaultObjectsCopy objectAtIndex:indexPath.row];
                self.selectedEvent.eventName = event.eventName;
                self.selectedEvent.eventCategory = [event.category integerValue];
            }
            else
            {
                DefaultWeightLifting *event = [self.weightLiftingDefaultObjectsCopy objectAtIndex:indexPath.row];
                self.selectedEvent.eventName = event.eventName;
                self.selectedEvent.eventCategory = [event.category integerValue];
            }
            break;
            
        case WeightCategory:
        {
            DefaultWeightLifting *event = [self.weightLiftingDefaultObjectsCopy objectAtIndex:indexPath.row];
            self.selectedEvent.eventName = event.eventName;
            self.selectedEvent.eventCategory = [event.category integerValue];
        }
            break;
            
        default:
            break;
    }

}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        switch (indexPath.section) {
            case AerobicCategory:
                if (self.aerobicDefaultObjects.count > 0)
                {
                    [self.coreDataHelper deleteObject:self.aerobicDefaultObjectsCopy[indexPath.row]];
                    [self.aerobicDefaultObjectsCopy removeObjectAtIndex:indexPath.row];
                }
                else
                {
                    [self.coreDataHelper deleteObject:self.weightLiftingDefaultObjectsCopy[indexPath.row]];
                    [self.weightLiftingDefaultObjectsCopy removeObjectAtIndex:indexPath.row];
                }
                break;
                
            case WeightCategory:
            {
                [self.coreDataHelper deleteObject:self.weightLiftingDefaultObjectsCopy[indexPath.row]];
                [self.weightLiftingDefaultObjectsCopy removeObjectAtIndex:indexPath.row];
            }
                break;
                
            default:
                break;
        }
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
    EditSelectedEventTableViewController *editSelectedTableViewController = [segue destinationViewController];
    editSelectedTableViewController.delegate = self;
}

#pragma  mark - CoreData

- (void) fetchEvents
{
    self.weightLiftingDefaultObjects = [self.coreDataHelper fetchDefaultDataFor:weightLiftingDefaultEventsFileName withSortKey:@"eventName" ascending:YES usePredicate:NO];
    self.aerobicDefaultObjects = [self.coreDataHelper fetchDefaultDataFor:aerobicDefaultEventsFileName withSortKey:@"eventName" ascending:YES usePredicate:NO];
    self.weightLiftingDefaultObjectsCopy = [NSMutableArray arrayWithArray:self.weightLiftingDefaultObjects];
    self.aerobicDefaultObjectsCopy = [NSMutableArray arrayWithArray:self.aerobicDefaultObjects];
}

@end
