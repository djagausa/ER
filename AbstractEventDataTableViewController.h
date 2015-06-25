//
//  AbstractEventDataTableViewController.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 4/29/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "DefaultAerobic.h"
#import "DefaultWeightLifting.h"
#import "CoreDataHelper.h"

@interface AbstractEventDataTableViewController : UITableViewController

@property (nonatomic, strong) NSManagedObjectContext    *managedObjectContext;
@property (nonatomic, strong) NSArray                   *weightLiftingDefaultObjects;
@property (nonatomic, strong) NSArray                   *aerobicDefaultObjects;
@property (nonatomic, strong) DefaultWeightLifting      *defaultWeightLifting;
@property (nonatomic, strong) DefaultAerobic            *defaultAerobic;
@property (nonatomic, strong) CoreDataHelper            *coreDataHelper;

@end
