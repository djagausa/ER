//
//  AddEventDataTVC.m
//  ExerciseRecording
//
//  Created by Douglas Alexander on 3/22/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import "AddEventDataTVC.h"
#import "DefaultAerobic.h"
#import "DefaultWeightLifting.h"

@interface AddEventDataTVC ()

@property (nonatomic, strong) NSArray *weightLiftingDefaultObjects;
@property (nonatomic, strong) NSArray *aerobicDefaultObjects;
@property (nonatomic, strong) DefaultWeightLifting *defaultWeightLifting;
@property (nonatomic, strong) DefaultAerobic *defaultAerobic;

@end

@implementation AddEventDataTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self fetchEvents];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = 0;
    
    if (self.weightLiftingDefaultObjects.count > 0)
    {
        count++;
    }
    
    if (self.aerobicDefaultObjects.count > 0)
    {
        count++;
    }
    return count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *headerTitle;
    
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
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    
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
    
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;

    switch (indexPath.section) {
        case 0:
            if (self.aerobicDefaultObjects.count > 0)
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"AerobicEventCell" forIndexPath:indexPath];
                DefaultAerobic *event = [self.aerobicDefaultObjects objectAtIndex:indexPath.row];
                cell.textLabel.text = event.eventName;
            }
            else
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"WeightEventCell" forIndexPath:indexPath];
                DefaultWeightLifting *event = [self.weightLiftingDefaultObjects objectAtIndex:indexPath.row];
                cell.textLabel.text = event.eventName;
            }
            break;
            
        case 1:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"WeightEventCell" forIndexPath:indexPath];
            DefaultWeightLifting *event = [self.weightLiftingDefaultObjects objectAtIndex:indexPath.row];
            cell.textLabel.text = event.eventName;
        }
            break;

        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
}
#pragma mark - Fetched results controller

- (void) fetchEvents
{
    NSFetchRequest *fetchRequst = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DefaultWeightLifting" inManagedObjectContext:self.managedObjectContext];
    [fetchRequst setEntity:entity];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"eventName" ascending:YES];
    [fetchRequst setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"enabled == YES"];
    [fetchRequst setPredicate:filter];
    
    NSError *error;
    self.weightLiftingDefaultObjects = [self.managedObjectContext executeFetchRequest:fetchRequst error:&error];
    
    fetchRequst = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription entityForName:@"DefaultAerobic" inManagedObjectContext:self.managedObjectContext];
    [fetchRequst setEntity:entity];
    self.aerobicDefaultObjects = [self.managedObjectContext executeFetchRequest:fetchRequst error:&error];
    
    for (DefaultWeightLifting *defaultWL in self.weightLiftingDefaultObjects) {
        NSLog(@"Event Name: %@",defaultWL.eventName);
    }
    
    for (DefaultWeightLifting *defaultA in self.aerobicDefaultObjects) {
        NSLog(@"Event Name: %@",defaultA.eventName);
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UITableViewCell *cell = (UITableViewCell *) sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    switch (indexPath.section) {
        case 0:
            if (self.aerobicDefaultObjects.count > 0)
            {
                self.defaultAerobic = [self.aerobicDefaultObjects objectAtIndex:indexPath.row];
            }
            else
            {
                self.defaultWeightLifting = [self.weightLiftingDefaultObjects objectAtIndex:indexPath.row];
            }
            break;
            
        case 1:
        {
            self.defaultWeightLifting = [self.weightLiftingDefaultObjects objectAtIndex:indexPath.row];
        }
            break;
            
        default:
            break;
    }
    
    if ([[segue identifier] isEqualToString:@"addWeightData"]) {
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
        [[segue destinationViewController] setDefaultWeightLifting:self.defaultWeightLifting];
    }
    else if ([[segue identifier] isEqualToString:@"addAerobicData"]) {
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
        [[segue destinationViewController] setDefaultAerobic:self.defaultAerobic];
    }
}


@end
