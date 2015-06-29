//
//  AbstractEventDataTableViewController.m
//  ExerciseRecording
//
//  Created by Douglas Alexander on 4/29/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import "AbstractEventDataTableViewController.h"
#import "Support.h"

@interface AbstractEventDataTableViewController ()

@end

@implementation AbstractEventDataTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _coreDataHelper = [[CoreDataHelper alloc] init];
    _coreDataHelper.managedObjectContext = self.managedObjectContext;
    
    [self fetchEvents];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
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

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 28.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return SECTION_HEADER_HEIGHT;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

#pragma mark - Fetched results controller

- (void) fetchEvents
{
    
    self.weightLiftingDefaultObjects = [self.coreDataHelper fetchDefaultDataFor:weightLiftingDefaultEventsEntityName withSortKey:@"eventName" ascending:YES usePredicate:YES];
    self.aerobicDefaultObjects = [self.coreDataHelper fetchDefaultDataFor:aerobicDefaultEventsEntityName withSortKey:@"eventName" ascending:YES usePredicate:YES];
    
#ifdef DEBUG
     for (DefaultWeightLifting *defaultWL in self.weightLiftingDefaultObjects) {
     NSLog(@"Weight Event Name: %@",defaultWL.eventName);
     }
     
     for (DefaultAerobic *defaultA in self.aerobicDefaultObjects) {
     NSLog(@"Aerobic Event Name: %@",defaultA.eventName);
     }
#endif
}

@end
