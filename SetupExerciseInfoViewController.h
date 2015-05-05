//
//  SetupExrciseInfoViewController.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 3/8/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "SelectedEvent.h"

@protocol SetupExrciseInfoViewControllerDelegate <NSObject>
- (SelectedEvent *)eventDataHasChangedTo;
@end

@interface SetupExrciseInfoViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *exerciseName;
@property (weak, nonatomic) IBOutlet UITableView *exerciseActivitySelectionTable;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UITextField *default1;
@property (weak, nonatomic) IBOutlet UITextField *default2;
@property (weak, nonatomic) IBOutlet UITextField *default3;
@property (weak, nonatomic) IBOutlet UISwitch *enableSwitch;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) SelectedEvent *selectedEvent;
@property (nonatomic, strong) id <SetupExrciseInfoViewControllerDelegate> delegate;

- (instancetype)init;
- (IBAction)saveData:(id)sender;

@end
