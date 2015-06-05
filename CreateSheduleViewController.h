//
//  CreateSheduleViewController.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 5/25/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractEventDataViewController.h"
#import "ScheduleDayEventsViewController.h"

@interface CreateSheduleViewController : AbstractEventDataViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ScheduleDayEventsViewControllerDelegate, UITextFieldDelegate>


@end
