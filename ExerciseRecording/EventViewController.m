//
//  EventViewController.m
//  ExerciseRecording
//
//  Created by Douglas Alexander on 3/7/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import "EventViewController.h"
#import "Support.h"
//#import "MotivationalQuoteInfo.h"
#import "MotivationalQuoteHelper.h"

@interface EventViewController ()

@property (weak, nonatomic) IBOutlet UIButton           *addExerciseButton;
@property (weak, nonatomic) IBOutlet UIButton           *reviewExerciseButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem    *editExercise;
@property (weak, nonatomic) IBOutlet UITextView         *motivationalTextOutlet;
@property  (nonatomic, strong) IBOutlet UITapGestureRecognizer *tapRecognizer;
@property (copy, nonatomic) NSString *motivationalStatement;
@property (strong, nonatomic) MotivationalQuoteHelper   *motivationalHelper;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *setupExerciseData;

- (void)exerciseDataAddedNotification:(NSNotificationCenter *)notification;

@end

static NSString * const kTutorialAlerTitle = @"Tutorial";
static NSString * const kTutorialAlertMessage = @"Would you like to view the turorial?";

@implementation EventViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureTheButtons];
    
    // register for events added notifications
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(exerciseDataAddedNotification:) name:eventAddedNotificationName object:nil];
    
    self.motivationalHelper = [[MotivationalQuoteHelper alloc] init];
    
    [self.motivationalTextOutlet.layer setBorderColor:[[UIColor blueColor] CGColor] ];
    [self.motivationalTextOutlet.layer setBorderWidth:2.0];
    self.motivationalTextOutlet.layer.cornerRadius = 5;
    self.motivationalTextOutlet.clipsToBounds = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // provide a modivational statement
    [self addMotivationalQuote];

    // provide tutorial viewing option
    if ([self isThisTheFirstTimeAppIsRun] == YES) {
        [self presentTurtorialViewingOption];
    }

}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    return [self view];
}

-(IBAction)displayGestureForTapRecognizer:(UITapGestureRecognizer *)recognizer
{
    [self addMotivationalQuote];
}

- (void)configureTheButtons
{
    //  only turn the buttons if event data exists
    [self.addExerciseButton setEnabled:NO];
    [self.reviewExerciseButton setEnabled:NO];
    [self.editExercise setEnabled:NO];
    
    // enable the review button only if events have been recorded
    NSInteger count = [self.coreDataHelper numberOfEntities:aerobicEventsEntityName];
    
    if (count == 0) {
        count = [self.coreDataHelper numberOfEntities:weightLiftingEventsEntityName];
    }
    
    if (count > 0)
    {
        [self.reviewExerciseButton setEnabled:YES];
    }

    // enable the add button only if events to add have been setup
    count = [self.coreDataHelper numberOfEntities:aerobicDefaultEventsEntityName];
    
    if (count == 0) {
        count = [self.coreDataHelper numberOfEntities:weightLiftingDefaultEventsEntityName];
    }
    
    if (count > 0)
    {
        [self.addExerciseButton setEnabled:YES];
        [self.editExercise setEnabled:YES];
    }
    
    if ((self.addExerciseButton.enabled == YES) && (self.reviewExerciseButton.enabled == YES)) {
        // un-register for events added notifications
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc removeObserver:self name:eventAddedNotificationName object:nil];
    }
}

- (void)presentTurtorialViewingOption
{
    UIAlertController *alerController = [UIAlertController alertControllerWithTitle:kTutorialAlerTitle message:kTutorialAlertMessage preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                {
                                    [weakSelf startTutorial];
                                }];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                               {
                                   NSLog(@"No action");
                               }];
    [alerController addAction:yesAction];
    [alerController addAction:noAction];
    
    [self presentViewController:alerController animated:YES completion:nil];

}

- (BOOL)isThisTheFirstTimeAppIsRun
{
    BOOL firstRun = NO;
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        firstRun = YES;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    firstRun = YES;

    return firstRun;
}

- (void)startTutorial
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"Tutorial"];
    [[self navigationController] pushViewController:vc animated:YES];
//    [self presentViewController:vc animated:YES completion:nil];
}

- (void)addMotivationalQuote
{
    MotivationalQuoteInfo *motivationalQuoteInfo;
    NSInteger space;

    motivationalQuoteInfo = [self.motivationalHelper provideMotivationQuoteInfo];
    space = 75 - motivationalQuoteInfo.author.length;
    NSString * quoteString = [NSString stringWithFormat:@"%@\n\n%*s - %@", motivationalQuoteInfo.motivtionalQuote, (int)space, " ", motivationalQuoteInfo.author];
    self.motivationalTextOutlet.text = quoteString;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Delegates
- (void)eventAdded
{
    [self configureTheButtons];
}

- (void)exerciseDataAddedNotification:(NSNotificationCenter *)notification
{
    [self configureTheButtons];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
    if ([segue.identifier isEqualToString:@"SelectEventToAdd"]) {
        SelectEventToAddTableViewController *addController = [segue destinationViewController];
        addController.eventAddedDelegate = self;
    }
}


@end
