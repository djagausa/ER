//
//  AbstractWeightDataViewController.m
//  ExerciseRecording
//
//  Created by Douglas Alexander on 4/24/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import "AbstractWeightDataViewController.h"
#import "CoreDataHelper.h"
#import "WeightLiftingEvent.h"
#import "WeightEventTVC.h"
#import "AddWeightDataSectionHeaderCell.h"
#import "WeightEventTableCellNoNote.h"
#import "Support.h"

@interface AbstractWeightDataViewController ()

@property (nonatomic, assign) NSInteger                     numberOfSections;
@property (nonatomic, assign) NSInteger                     numberOfItems;
@property (nonatomic, strong) NSFetchedResultsController    *fetchedResultsController;

@end

@implementation AbstractWeightDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    UIBarButtonItem *saveBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveAction)];
    //
    //    self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:saveBarButtonItem, nil];
    
    self.coreDataHelper = [[CoreDataHelper alloc] init];
    self.coreDataHelper.managedObjectContext = self.managedObjectContext;
    self.coreDataHelper.defaultSortAttribute = @"date";
    [self fetchWeightEvents];
}

- (void)viewDidAppear:(BOOL)animated
{
    // This really shouldn't need to be done per Apple's documentation, but the initial
    // loading of the table cells don't expand correctly.
    
    [super viewDidAppear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
}

#pragma mark - Init

- (NSString *)dateToFormatMMddyyy:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSString *convertedDate = [dateFormatter stringFromDate:[NSDate date]];
    NSString *formattedDate = [[NSString alloc] initWithFormat:@"Date: %@", convertedDate];
    
    return formattedDate;
}

#pragma mark - Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = [[self.coreDataHelper.fetchedResultsController sections] count];
    return count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 22.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - Core Data

- (void)fetchWeightEvents
{
    [self.coreDataHelper fetchItemsMatching:@"WeightLiftingEvent"
                               forAttribute:nil
                                  sortingBy:@"date"
                              withPredicate:[[self defaultWeightLifting] eventName] groupBy:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
