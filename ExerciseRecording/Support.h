//
//  Support.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 4/16/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#ifndef ExerciseRecording_Support_h
#define ExerciseRecording_Support_h

typedef NS_ENUM(NSInteger, ExerciseCategory) {
    kWeights = 0,
    kWalking,
    kStretching,
    kRunning,
    kEliptical,
    kBicycling
};

typedef NS_ENUM(NSInteger, WeightCells) {
    kSet = 0,
    kReps,
    kWeight,
    kNote
};

typedef NS_ENUM(NSInteger, EventCateogory) {
    WeightCategory,
    AerobicCategory
};
#endif
