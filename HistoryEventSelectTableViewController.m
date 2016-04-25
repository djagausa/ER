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
@property (nonatomic, strong) SelectedEvent     *selectedEvent;
@property (nonatomic, strong) NSArray    *savedWeightEvents;
@property (nonatomic, strong) NSArray    *savedAerobicEvents;
@end

@implementation HistoryEventSelectTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _selectedEvent = [[SelectedEvent alloc] init];
    _savedAerobicEvents = [[NSArray alloc] init];
    _savedWeightEvents = [[NSArray alloc] init];
    [self fetchEvents];
#ifdef DEBUG
    NSLog(@"**************   %s   ***************", __PRETTY_FUNCTION__);
#endif
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

-(SelectedEvent *)selectedEventDataIs
{
    return self.selectedEvent;
}

#pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = 0;
    
    if (self.savedWeightEvents.count > 0)
    {
        count++;
    }
    
    if (self.savedAerobicEvents.count > 0)
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
            if (self.savedAerobicEvents.count > 0) {
                count = self.savedAerobicEvents.count;
            }
            else
            {
                count = self.savedWeightEvents.count;
                
            }
            break;
            
        case 1:
            count = self.savedWeightEvents.count;
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
            if (self.savedAerobicEvents.count > 0) {
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
            if (self.savedAerobicEvents.count > 0)
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"EventCell" forIndexPath:indexPath];
                cell.textLabel.text = [[self.savedAerobicEvents objectAtIndex:indexPath.row] objectForKey:@"eventName"];
            }
            else
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"EventCell" forIndexPath:indexPath];
                cell.textLabel.text = [[self.savedWeightEvents objectAtIndex:indexPath.row]objectForKey:@"eventName"];
            }
            break;
            
        case 1:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"EventCell" forIndexPath:indexPath];
            cell.textLabel.text = [[self.savedWeightEvents objectAtIndex:indexPath.row]objectForKey:@"eventName"];
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
        case 0:
            if (self.savedAerobicEvents.count > 0)
            {
                self.selectedEvent.eventName = [[self.savedAerobicEvents objectAtIndex:indexPath.row] objectForKey:@"eventName"];
                self.selectedEvent.eventCategory = [[[self.savedAerobicEvents objectAtIndex:indexPath.row] objectForKey:@"category"] integerValue];
            }
            else
            {
                self.selectedEvent.eventName = [[self.savedWeightEvents objectAtIndex:indexPath.row]objectForKey:@"eventName"];
                self.selectedEvent.eventCategory = [[[self.savedWeightEvents objectAtIndex:indexPath.row] objectForKey:@"category"] integerValue];
            }
            break;
            
        case 1:
        {
            self.selectedEvent.eventName = [[self.savedWeightEvents objectAtIndex:indexPath.row]objectForKey:@"eventName"];
            self.selectedEvent.eventCategory = [[[self.savedWeightEvents objectAtIndex:indexPath.row] objectForKey:@"category"] integerValue];
        }
            break;
            
        default:
            break;
    }
}

- (void) fetchEvents
{
    // fetch the saved events - they are the events with a history
    self.savedWeightEvents = [self.coreDataHelper fetchSaveEvents:weightLiftingEventsEntityName fetchPropertyName:@"eventName" fetchPropertyCategory:@"category"];
    self.savedAerobicEvents = [self.coreDataHelper fetchSaveEvents:aerobicEventsEntityName fetchPropertyName:@"eventName" fetchPropertyCategory:@"category"];
    
#ifdef DEBUG
    for (NSDictionary *event in self.savedWeightEvents) {
        NSLog(@"Saved weight event: %@", [event objectForKey:@"eventName"]);
    }
    
    for (NSDictionary *event in self.savedAerobicEvents) {
        NSLog(@"Saved aerobic event: %@", [event objectForKey:@"eventName"]);
    }
#endif
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
    EventHistoryViewController *eventHistoryViewController = [segue destinationViewController];
    eventHistoryViewController.delegate = self;
}

@end
