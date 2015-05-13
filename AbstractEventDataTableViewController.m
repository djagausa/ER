//
//  AbstractEventDataTableViewController.m
//  ExerciseRecording
//
//  Created by Douglas Alexander on 4/29/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import "AbstractEventDataTableViewController.h"


@interface AbstractEventDataTableViewController ()

@end

@implementation AbstractEventDataTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.coreDataHelper = [[CoreDataHelper alloc] init];
    self.coreDataHelper.managedObjectContext = self.managedObjectContext;
    
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    switch (indexPath.section) {
        case 0:
            if (self.aerobicDefaultObjects.count > 0)
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"EventCell" forIndexPath:indexPath];
                DefaultAerobic *event = [self.aerobicDefaultObjects objectAtIndex:indexPath.row];
                cell.textLabel.text = event.eventName;
            }
            else
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"EventCell" forIndexPath:indexPath];
                DefaultWeightLifting *event = [self.weightLiftingDefaultObjects objectAtIndex:indexPath.row];
                cell.textLabel.text = event.eventName;
            }
            break;
            
        case 1:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"EventCell" forIndexPath:indexPath];
            DefaultWeightLifting *event = [self.weightLiftingDefaultObjects objectAtIndex:indexPath.row];
            cell.textLabel.text = event.eventName;
        }
            break;
            
        default:
            break;
    }
    return cell;
}

#pragma mark - Fetched results controller

- (void) fetchEvents
{
    
    self.weightLiftingDefaultObjects = [self.coreDataHelper fetchDefaultDataFor:@"DefaultWeightLifting" withSortKey:@"eventName" ascending:YES usePredicate:YES];
    self.aerobicDefaultObjects = [self.coreDataHelper fetchDefaultDataFor:@"DefaultAerobic" withSortKey:@"eventName" ascending:YES usePredicate:YES];
    

//     for (DefaultWeightLifting *defaultWL in self.weightLiftingDefaultObjects) {
//     NSLog(@"Event Name: %@",defaultWL.eventName);
//     }
//     
//     for (DefaultAerobic *defaultA in self.aerobicDefaultObjects) {
//     NSLog(@"Event Name: %@",defaultA.eventName);
//     }

}

@end
