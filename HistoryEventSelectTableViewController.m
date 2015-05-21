//
//  HistoryEventSelectTableViewController.m
//  ExerciseRecording
//
//  Created by Douglas Alexander on 4/29/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import "HistoryEventSelectTableViewController.h"
#import "SelectedEvent.h"
#import "EventHistoryViewController.h"
#import "Support.h"

@interface HistoryEventSelectTableViewController ()
@property (nonatomic, strong) SelectedEvent *selectedEvent;
@end

@implementation HistoryEventSelectTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectedEvent = [[SelectedEvent alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

-(SelectedEvent *)selectedEventDataIs
{
    return self.selectedEvent;
}

#pragma mark - Table View

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case AerobicCategory:
            if (self.aerobicDefaultObjects.count > 0)
            {
                self.defaultAerobic = [self.aerobicDefaultObjects objectAtIndex:indexPath.row];
                self.selectedEvent.eventName = self.defaultAerobic.eventName;
                self.selectedEvent.eventCategory = [self.defaultAerobic.category integerValue];
            }
            else
            {
                self.defaultWeightLifting = [self.weightLiftingDefaultObjects objectAtIndex:indexPath.row];
                self.selectedEvent.eventName = self.defaultWeightLifting.eventName;
                self.selectedEvent.eventCategory = [self.defaultWeightLifting.category integerValue];
            }
            break;
            
        case WeightCategory:
        {
            self.defaultWeightLifting = [self.weightLiftingDefaultObjects objectAtIndex:indexPath.row];
            self.selectedEvent.eventName = self.defaultWeightLifting.eventName;
            self.selectedEvent.eventCategory = [self.defaultWeightLifting.category integerValue];
        }
            break;
            
        default:
            break;
    }
}

- (void) fetchEvents
{
    
    self.weightLiftingDefaultObjects = [self.coreDataHelper fetchDefaultDataFor:weightLiftingDefaultEventsFileName withSortKey:@"eventName" ascending:YES usePredicate:NO];
    self.aerobicDefaultObjects = [self.coreDataHelper fetchDefaultDataFor:aerobicDefaultEventsFileName withSortKey:@"eventName" ascending:YES usePredicate:NO];
    
    
    //     for (DefaultWeightLifting *defaultWL in self.weightLiftingDefaultObjects) {
    //     NSLog(@"Event Name: %@",defaultWL.eventName);
    //     }
    //
    //     for (DefaultAerobic *defaultA in self.aerobicDefaultObjects) {
    //     NSLog(@"Event Name: %@",defaultA.eventName);
    //     }
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
    EventHistoryViewController *eventHistoryViewController = [segue destinationViewController];
    eventHistoryViewController.delegate = self;
}

@end
