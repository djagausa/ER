//
//  Support.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 4/16/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#ifndef ExerciseRecording_Support_h
#define ExerciseRecording_Support_h

static const float SECTION_HEADER_HEIGHT = 30.0;

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
    ScheduleCategory,
    AerobicCategory,
    WeightCategory
};

typedef NS_ENUM(NSInteger, ScheduleDiplayMode) {
    kScheduleEdit = 1,
    kScheduleReview,
    kScheduleNew,
    kScheduleNoEdit
};

typedef NS_ENUM(NSInteger, ScheduleOpertaingMode) {
    kScheduleModeAuto = 0,
    kScheduleModeManual,
};

static NSString *aerobicEventsEntityName = @"AerobicEvent";
static NSString *weightLiftingEventsEntityName = @"WeightLiftingEvent";
static NSString *aerobicDefaultEventsEntityName = @"DefaultAerobic";
static NSString *weightLiftingDefaultEventsEntityName = @"DefaultWeightLifting";
static NSString *scheduleEntityName = @"Schedule";
static NSString *scheduledEventEntityName = @"ScheduledEvent";


static NSString *scheduleStatusFileName = @"ScheduledStatus.out";
static NSString *scheduleNameKey =  @"scheduledNameKey";
static NSString *dayKey = @"dayKey";
static NSString *weekKey = @"weekKey";
static NSString *lastUpdateDateKey = @"lastUpdateDateKey";
static NSString *activeKey = @"activeKey";
static NSString *repeatCountKey = @"repeatKey";
static NSString *operationMode = @"operationMode";

static NSString *eventAddedNotificationName = @"ExerciseEventAdded";

static NSString *motivationalAuthorKey = @"MotivationalAuthorKey";
static NSString *motivationalQuoteKey = @"MotivationalQuoteKey";

#endif
