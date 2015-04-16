//
//  SelectEventToAddTableViewController.m
//  ExerciseRecording
//
//  Created by Douglas Alexander on 4/15/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import "SelectEventToAddTableViewController.h"

@interface SelectEventToAddTableViewController ()

@property (nonatomic, strong) NSMutableArray    *weightExerciseEvents;
@property (nonatomic, strong) NSMutableArray    *aerobicExerciseEvents;
@property (nonatomic, strong) NSDictionary      *categoryDictionary;

@end

static NSString *cellIdentification = @"SelectEventToAddCell";

typedef NS_ENUM(NSInteger, EventCateogory) {
    WeightCategory,
    AerobicCategory
};


@implementation SelectEventToAddTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
     self.clearsSelectionOnViewWillAppear = NO;
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"ExerciseSelection" ofType:@"plist"];
    self.categoryDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];

    self.weightExerciseEvents = self.categoryDictionary[@"WeightLifting"];
    self.aerobicExerciseEvents = self.categoryDictionary[@"Aerobic"];
    
    [self.weightExerciseEvents sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    [self.aerobicExerciseEvents sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.categoryDictionary.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count;
    
    switch (section) {
        case WeightCategory:
        {
            count = self.weightExerciseEvents.count;
            break;
        }
            
        case AerobicCategory:
        {
            count = self.aerobicExerciseEvents.count;
            break;
        }
            
        default:
            break;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentification forIndexPath:indexPath];
    switch (indexPath.section) {
        case WeightCategory:
        {
            cell.textLabel.text = [self.weightExerciseEvents objectAtIndex:indexPath.row];
            break;
        }
        
        case AerobicCategory:
        {
            cell.textLabel.text = [self.aerobicExerciseEvents objectAtIndex:indexPath.row];
        }
            
        default:
            break;
    }
    
    
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
