//
//  EventViewController.m
//  ExerciseRecording
//
//  Created by Douglas Alexander on 3/7/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import "EventViewController.h"
#import "Support.h"

@interface EventViewController ()

@property (weak, nonatomic) IBOutlet UIButton *addExerciseButton;
@property (weak, nonatomic) IBOutlet UIButton *reviewExerciseButton;
@end

@implementation EventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTheButtons];
}

- (void)configureTheButtons
{
    //  only turn the buttons if event data exists
    [self.addExerciseButton setEnabled:NO];
    [self.reviewExerciseButton setEnabled:NO];
    [self.editButtonItem setEnabled:NO];
    
    // enable the review button only if events have been recorded
    NSInteger count = [self.coreDataHelper numberOfEntities:aerobicEventsFileName];
    
    if (count == 0) {
        count = [self.coreDataHelper numberOfEntities:weightLiftingEventsFileName];
    }
    
    if (count > 0)
    {
        [self.reviewExerciseButton setEnabled:YES];
    }

    // enable the add button only if events to add have been setup
    count = [self.coreDataHelper numberOfEntities:aerobicDefaultEventsFileName];
    
    if (count == 0) {
        count = [self.coreDataHelper numberOfEntities:weightLiftingDefaultEventsFileName];
    }
    
    if (count > 0)
    {
        [self.addExerciseButton setEnabled:YES];
        [self.editButtonItem setEnabled:NO];
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Delegates
- (void)eventAdded
{
    [self configureTheButtons];
}

- (void)exerciseDataAddedNotification
{
    [self configureTheButtons];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
    if ([segue.identifier isEqualToString:@"SelectEventToAdd"]) {
        SelectEventToAddTableViewController *addController = [segue destinationViewController];
        addController.eventAddedDelegate = self;
    }
    if ([segue.identifier isEqualToString:@"AddEventData"]) {
        AddEventDataTVC *addController = [segue destinationViewController];
        addController.exerciseDataAddedDelegate = self;
    }

}


@end
