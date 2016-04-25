//
//  TutorialViewController.m
//  ExerciseRecording
//
//  Created by Douglas Alexander on 11/28/15.
//  Copyright © 2015 Douglas Alexander. All rights reserved.
//

#import "TutorialViewController.h"

@interface TutorialViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *tutorialView;


@property (weak, nonatomic) IBOutlet UIButton *previousButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *nextButtonOutlet;

- (IBAction)previousButton:(id)sender;
- (IBAction)nextButon:(id)sender;
- (IBAction)doneButton:(id)sender;

@property(nonatomic, strong) NSArray *tutorialPages;
@property(nonatomic, assign) NSInteger numOfTutorialPages;
@property(nonatomic, assign) NSInteger currentPage;

@end

static NSString * const navTitle = @"Exercise Recorder Tutorial";

@implementation TutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // get the list of pages to be displayed
    [self setTutorialPages:[self getTutorialViews]];
    [self setNumOfTutorialPages:[[self tutorialPages]count]];
    
    // display the first page
    [self setCurrentPage:0];
    [self setupView:[[self tutorialPages]objectAtIndex:[self currentPage]]];
    
    [[self navigationItem] setTitle:navTitle];
    [self handleButtons];
#ifdef DEBUG
    NSLog(@"**************   %s   ***************", __PRETTY_FUNCTION__);
#endif
}

- (IBAction)previousButton:(id)sender {
    if ([self currentPage] > 0) {
        [self setCurrentPage:[self currentPage] - 1];
        [self setupView:[[self tutorialPages]objectAtIndex:[self currentPage]]];
    }
    [self handleButtons];
}

- (IBAction)nextButon:(id)sender {
    if ([self currentPage] < [self numOfTutorialPages] -1) {
        [self setCurrentPage:[self currentPage] + 1];
        [self setupView:[[self tutorialPages]objectAtIndex:[self currentPage]]];
    }
    [self handleButtons];
}

- (IBAction)doneButton:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

// display the view
- (void)setupView:(NSString *)nameOfPageToBeDisplayed
{
    UIImage *view;
    
    view = [UIImage imageNamed:nameOfPageToBeDisplayed];
    [[self tutorialView] setImage:view];
}

// return an array of pages avaialble to be displayed
- (NSArray *)getTutorialViews
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"TutorialPages" ofType:@"plist"];
    NSDictionary *motivationalQuoteDic = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    return [motivationalQuoteDic objectForKey:@"Pages"];
}

// setup the buttone based on current page value
- (void)handleButtons
{
    if ([self currentPage] == [self numOfTutorialPages] -1) {
        // disable next button if at end of pages array
        [[self nextButtonOutlet] setEnabled:NO];
    } else if ([self numOfTutorialPages] > 1) {
        [[self nextButtonOutlet] setEnabled:YES];
    } else {
        [[self nextButtonOutlet] setEnabled:NO];
    }
    
    if ([self currentPage] == 0) {
        // disable previous button if at beginning of array
        [[self previousButtonOutlet] setEnabled:NO];
    } else {
        [[self previousButtonOutlet] setEnabled:YES];
    }
    
}
@end
