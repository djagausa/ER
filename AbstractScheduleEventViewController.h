//
//  AbstractScheduleEventViewController.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 6/12/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "CoreDataHelper.h"
#import "SelectedEvent.h"
#import "DefaultWeightLifting.h"
#import "DefaultAerobic.h"

@interface AbstractScheduleEventViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSManagedObjectContext    *managedObjectContext;
@property (nonatomic, strong) CoreDataHelper            *coreDataHelper;
@property (nonatomic, strong) DefaultWeightLifting      *defaultWeightLifting;
@property (nonatomic, strong) DefaultAerobic            *defaultAerobic;
@property (nonatomic, strong) SelectedEvent             *selectedEvent;

- (NSNumber *)fetchNumberOfWeeksForSchedule:(NSString *)scheduleName;
- (void) fetchEvents;

@end
