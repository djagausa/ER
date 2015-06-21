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
#import "ScheduledEventInfo.h"

@protocol CreateSheduleViewControllerDelegate <NSObject>
- (ScheduledEventInfo *)scheduledEventIs;
@end

@interface CreateSheduleViewController : AbstractEventDataViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ScheduleDayEventsViewControllerDelegate, UITextFieldDelegate>

@property (nonatomic, weak) id<CreateSheduleViewControllerDelegate> createScheduleDelegate;

@end
