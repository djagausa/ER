//
//  EventViewController.m
//  ExerciseRecording
//
//  Created by Douglas Alexander on 3/7/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import "EventViewController.h"

@interface EventViewController ()

@end

@implementation EventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"SelectEventToAdd"]) {
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
    } else if ([[segue identifier] isEqualToString:@"AddEventData"]) {
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
   
    }
}
@end
