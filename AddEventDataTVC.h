//
//  AddEventDataTVC.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 3/22/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "AbstractEventDataTableViewController.h"
#import "AbstractEventDataViewController.h"
#import "AddEventDataViewController.h"

@protocol AddEventDataTVCDelegate <NSObject>
@optional
- (void)exerciseDataAddedNotification;
@end

@interface AddEventDataTVC : AbstractEventDataTableViewController <AbstractEventDataDelegate, AddEventDataViewControllerDelegate>

@property (nonatomic, strong) id<AddEventDataTVCDelegate> exerciseDataAddedDelegate;

@end
