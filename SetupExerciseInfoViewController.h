//
//  SetupExrciseInfoViewController.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 3/8/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

typedef NS_ENUM(NSInteger, ExerciseCategory) {
    kWeights = 0,
    kWalking,
    kStretching,
    kRunning,
    kEliptical,
    kBicycling
};

@interface SetupExrciseInfoViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *exerciseName;
@property (weak, nonatomic) IBOutlet UITableView *exerciseActivitySelectionTable;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UITextField *default1;
@property (weak, nonatomic) IBOutlet UITextField *default2;
@property (weak, nonatomic) IBOutlet UITextField *default3;
@property (weak, nonatomic) IBOutlet UISwitch *enableSwitch;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
- (IBAction)saveData:(id)sender;

@property  NSInteger categoryCode;
@end
