//
//  Add Aerobic VC.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 3/24/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "DefaultAerobic.h"
#import "WeightLiftingEvent.h"

@interface Add_Aerobic_VC : UIViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) DefaultWeightLifting *defaulAerobicEvent;


@end
