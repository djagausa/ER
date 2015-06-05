//
//  dayCollectionViewCell.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 5/25/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DayCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *dayCellDayLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayCellNumberOfEvents;

@end
