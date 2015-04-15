//
//  AddEventDataTVC.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 3/22/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AddEventDataTVC : UITableViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
