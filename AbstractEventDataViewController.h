//
//  AbstractWeightDataViewController.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 4/24/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "DefaultWeightLifting.h"
#import "WeightLiftingEvent.h"
#import "CoreDataHelper.h"
#import "SelectedEvent.h"

@protocol AbstractEventDataDelegate <NSObject>
-(SelectedEvent *)selectedEventDataIs;
@end

@interface AbstractEventDataViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSManagedObjectContext    *managedObjectContext;
@property (nonatomic, strong) DefaultWeightLifting      *defaultWeightLifting;
@property (nonatomic, strong) CoreDataHelper            *coreDataHelper;
@property (nonatomic, strong) id<AbstractEventDataDelegate> delegate;
@property (nonatomic, strong) SelectedEvent              *selectedEvent;

-(void)fetchEvents;
- (NSString *)dateToFormatMMddyyy:(NSDate *)date;

@end
