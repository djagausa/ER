//
//  HistoryEventSelectTableViewController.m
//  ExerciseRecording
//
//  Created by Douglas Alexander on 4/29/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import "HistoryEventSelectTableViewController.h"
#import "SelectedEditEvent.h"
#import "EventHistoryPlotViewController.h"
#import "Support.h"

@interface HistoryEventSelectTableViewController ()
@property (nonatomic, strong) SelectedEditEvent *selectedEvent;
@end

@implementation HistoryEventSelectTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectedEvent = [[SelectedEditEvent alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(SelectedEditEvent *)selectedEventDataIs
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
    EventHistoryPlotViewController *eventHistoryPlotViewController = [segue destinationViewController];
    eventHistoryPlotViewController.delegate = self;
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];

}

@end
