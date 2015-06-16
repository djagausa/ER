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
#import "AbstractEventDataViewController.h"
#import "AddEventDataViewController.h"

@interface AbstractScheduleEventViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, AbstractEventDataDelegate,AddEventDataViewControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext    *managedObjectContext;
@property (nonatomic, strong) CoreDataHelper            *coreDataHelper;
@property (nonatomic, strong) DefaultWeightLifting      *defaultWeightLifting;
@property (nonatomic, strong) DefaultAerobic            *defaultAerobic;
@property (nonatomic, strong) SelectedEvent             *selectedEvent;
@property (nonatomic, strong) NSMutableArray            *weightLiftingDefaultObjects;
@property (nonatomic, strong) NSMutableArray            *aerobicDefaultObjects;
@property (nonatomic, strong) NSMutableArray            *completedWeightEvents;             // used to keep track of todays completed events
@property (nonatomic, strong) NSMutableArray             *completedAerobicEvents;            // used to keep track of todays completed events

- (NSNumber *)fetchNumberOfWeeksForSchedule:(NSString *)scheduleName;
- (void) fetchEvents;

@end
