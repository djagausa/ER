//
//  EventHistoryViewController.m
//  ExerciseRecording
//
//  Created by Douglas Alexander on 5/1/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import "EventHistoryViewController.h"
#import "SelectedEvent.h"
#import "EventHistoryPlotViewController.h"
#import "Support.h"

@interface EventHistoryViewController ()
@property (nonatomic, strong) SelectedEvent *selectedEvent;
@end


@implementation EventHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = [NSString stringWithFormat:@"%@ History", self.selectedEvent.eventName];
    
    self.defaultWeightLifting = self.selectedEvent.defaultWeightLiftingData;
    
    [self fetchEvents];
    [self setupLabels];
}

- (void)viewWillAppear:(BOOL)animated
{
    // This really shouldn't need to be done per Apple's documentation, but the initial
    // loading of the table cells don't expand correctly.
    
    [super viewWillAppear:animated];
    [[self eventHistoryTable] reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(SelectedEvent *)selectedEventDataIs
{
    return self.selectedEvent;
}

- (void)setupLabels
{
    switch (self.selectedEvent.eventCategory) {
            case kWeights:
            {
                self.label1.text = @"Set";
                self.label2.text = @"Reps";
                self.label3.text = @"Weight";
            }
            break;
        case kBicycling:
            {
                
            }
            break;
        case kWalking:
        case kRunning:
        case kEliptical:
            {
                
            }
            break;
        default:
            break;
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
    EventHistoryPlotViewController *eventHistoryPlotViewController = [segue destinationViewController];
    eventHistoryPlotViewController.delegate = self;
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}


@end
