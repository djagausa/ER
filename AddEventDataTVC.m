//
//  AddEventDataTVC.m
//  ExerciseRecording
//
//  Created by Douglas Alexander on 3/22/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import "AddEventDataTVC.h"
#import "AddEventDataViewController.h"
#import "Support.h"
#import "SelectedEvent.h"

@interface AddEventDataTVC ()

@property (nonatomic, strong) SelectedEvent *selectedEvent;

@end

@implementation AddEventDataTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.selectedEvent = [[SelectedEvent alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (SelectedEvent *)selectedEventDataIs
{
    return self.selectedEvent;
}

#pragma mark - Table View
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case AerobicCategory:
            if (self.aerobicDefaultObjects.count > 0)
            {
                self.defaultAerobic = [self.aerobicDefaultObjects objectAtIndex:indexPath.row];
                self.selectedEvent.defaultAerobicData = self.defaultAerobic;
                self.selectedEvent.eventName = self.defaultAerobic.eventName;
                self.selectedEvent.eventCategory = [self.defaultAerobic.category integerValue];
            }
            else
            {
                self.defaultWeightLifting = [self.weightLiftingDefaultObjects objectAtIndex:indexPath.row];
                self.selectedEvent.defaultWeightLiftingData = self.defaultWeightLifting;
                self.selectedEvent.eventName = self.defaultWeightLifting.eventName;
                self.selectedEvent.eventCategory = [self.defaultWeightLifting.category integerValue];
            }
            break;
            
        case WeightCategory:
        {
            self.defaultWeightLifting = [self.weightLiftingDefaultObjects objectAtIndex:indexPath.row];
            self.selectedEvent.defaultWeightLiftingData = self.defaultWeightLifting;
            self.selectedEvent.eventName = self.defaultWeightLifting.eventName;
            self.selectedEvent.eventCategory = [self.defaultWeightLifting.category integerValue];
        }
            break;
            
        default:
            break;
    }

}
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
    AddEventDataViewController *addEventDataVC = [segue destinationViewController];
    addEventDataVC.delegate = self;
}


@end
