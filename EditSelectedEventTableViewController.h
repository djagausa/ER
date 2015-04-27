//
//  EditSelectedEventTableViewController.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 4/23/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectedEditEvent.h"
#import "EditEventViewController.h"

@protocol EditSelectedEventTableViewControllerDelegate <NSObject>
- (SelectedEditEvent *)selectEventDataIs;
@end

@interface EditSelectedEventTableViewController : UITableViewController <EditEventViewControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) id <EditSelectedEventTableViewControllerDelegate> delegate;
@property (nonatomic, strong) EditStoredEventData *storedEventData;

@end
