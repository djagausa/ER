//
//  WorkoutSchuledEventViewController.m
//  ExerciseRecording
//
//  Created by Douglas Alexander on 6/9/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import "WorkoutScheduledEventViewController.h"
#import "ScheduledEventInfo.h"
#import "ScheduleStatus.h"

@interface WorkoutScheduledEventViewController ()
@property (weak, nonatomic) IBOutlet UILabel        *scheduleInfoLabel;
@property (nonatomic, strong) ScheduledEventInfo    *scheduledEventInfo;
@property (nonatomic, strong) NSArray               *weightLiftingEvents;
@property (nonatomic, strong) NSArray               *aerobicEvents;
@end

@implementation WorkoutScheduledEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scheduledEventInfo = [self.workoutScheduleDelegate scheduleInfoIs];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Core Data
- (void)fetchScheduledEvents:(NSString *)scheduleName
{
    Schedule *schedule;
    NSArray *scheduledEvents;
    
    scheduledEvents = [self.coreDataHelper fetchDataFor:scheduleEntityName withPredicate:@{@"propertyName" : @"scheduleName", @"value" : self.scheduledEventInfo.scheduleName}];

    if ([scheduledEvents count] > 0) {
        schedule = [scheduledEvents firstObject];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
