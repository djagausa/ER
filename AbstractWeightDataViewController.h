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

@interface AbstractWeightDataViewController : UIViewController

@property (nonatomic, strong) NSManagedObjectContext    *managedObjectContext;
@property (nonatomic, strong) DefaultWeightLifting      *defaultWeightLifting;
@property (nonatomic, strong) CoreDataHelper            *coreDataHelper;

-(void)fetchWeightEvents;
- (NSString *)dateToFormatMMddyyy:(NSDate *)date;

@end
