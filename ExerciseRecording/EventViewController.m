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
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editExercise;

- (void)exerciseDataAddedNotification:(NSNotificationCenter *)notification;

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
    [self.editExercise setEnabled:NO];
    
    // enable the review button only if events have been recorded
    NSInteger count = [self.coreDataHelper numberOfEntities:aerobicEventsEntityName];
    
    if (count == 0) {
        count = [self.coreDataHelper numberOfEntities:weightLiftingEventsEntityName];
    }
    
    if (count > 0)
    {
        [self.reviewExerciseButton setEnabled:YES];
    }

    // enable the add button only if events to add have been setup
    count = [self.coreDataHelper numberOfEntities:aerobicDefaultEventsEntityName];
    
    if (count == 0) {
        count = [self.coreDataHelper numberOfEntities:weightLiftingDefaultEventsEntityName];
    }
    
    if (count > 0)
    {
        [self.addExerciseButton setEnabled:YES];
        [self.editExercise setEnabled:YES];
    }
    
    // register for events added notifications
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(exerciseDataAddedNotification:) name:eventAddedNotificationName object:nil];
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

- (void)exerciseDataAddedNotification:(NSNotificationCenter *)notification
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
}


@end
