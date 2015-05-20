//
//  EventHistoryPlotViewController.m
//  ExerciseRecording
//
//  Created by Douglas Alexander on 4/30/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import "EventHistoryPlotViewController.h"
#import "Support.h"


@interface EventHistoryPlotViewController()

@property (nonatomic, strong) NSNumber *yMin;
@property (nonatomic, strong) NSNumber *yMax;
@property (nonatomic, strong) NSNumber *period;
@property (nonatomic, strong) NSArray  *weightLiftingEvents;
@property (nonatomic, strong) NSArray  *aerobicEvents;
@property (nonatomic, strong) NSString *eventTitle;

- (IBAction)activitySelector:(id)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *activitySelectorOutlet;
- (IBAction)periodSelection:(id)sender;

@end

typedef NS_ENUM(NSInteger, walkngEventMeasurements) {
    kWalkHR = 0,
    kWalkTime,
    kWalkDistance
};

typedef NS_ENUM(NSInteger, bicyclingEventMeasurements) {
    kBikeHR = 0,
    kBikeTime,
    kBikeCadence
};

@implementation EventHistoryPlotViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];

    // Do any additional setup after loading the view.
    self.navigationItem.title = [NSString stringWithFormat:@"%@", self.selectedEvent.eventName];
    
    self.period = [self setEventPeriod:@(60)];
    [self getEventsForSPecificRange];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupActivitySelector];
    [self initPlot];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
//    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
//    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return NO;
}

- (void)setupActivitySelector
{
    [self.activitySelectorOutlet setSelectedSegmentIndex:0];
    switch (self.selectedEvent.eventCategory) {
        case kWeights:
            [self.activitySelectorOutlet setEnabled:NO];
            [self.activitySelectorOutlet setHidden:YES];
            [self.activitySelectorOutlet setTitle:@"Set" forSegmentAtIndex:0];
            break;
            
        default:
            [self.activitySelectorOutlet setEnabled:YES];
            [self.activitySelectorOutlet setHidden:NO];
            switch (self.selectedEvent.eventCategory) {
                case kWeights:
                    break;
                case kWalking:
                case kRunning:
                    [self.activitySelectorOutlet setTitle:@"HR" forSegmentAtIndex:0];
                    [self.activitySelectorOutlet setTitle:@"Time" forSegmentAtIndex:1];
                    [self.activitySelectorOutlet setTitle:@"Distance" forSegmentAtIndex:2];
                    break;
                    
                case kBicycling:
                    [self.activitySelectorOutlet setTitle:@"HR" forSegmentAtIndex:0];
                    [self.activitySelectorOutlet setTitle:@"Time" forSegmentAtIndex:1];
                    [self.activitySelectorOutlet setTitle:@"Cadence" forSegmentAtIndex:2];

                    break;
                case kEliptical:
                case kStretching:
                    break;
            }
            break;
    }

}
- (IBAction)activitySelector:(id)sender
{
    [self findMinAndMax];
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];
}

- (IBAction)periodSelection:(id)sender
{
    self.period = @(([sender selectedSegmentIndex] + 1) * 30);
    self.period = [self setEventPeriod:self.period];
    [self getEventsForSPecificRange];
    [self findMinAndMax];
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];

}

- (NSNumber *)setEventPeriod:(NSNumber *)selectedPeriod
{
    NSNumber *period;
    period = [@(self.coreDataHelper.fetchedResultsController.fetchedObjects.count) isLessThan: selectedPeriod] ? @(self.coreDataHelper.fetchedResultsController.fetchedObjects.count) : selectedPeriod;
    return period;
}

- (void)getEventsForSPecificRange
{
    NSRange range;
    range.length = [self.period integerValue];
    range.location = self.coreDataHelper.fetchedResultsController.fetchedObjects.count - ([self.period integerValue]);
    
    NSArray *tempArray;
    NSSortDescriptor *sortByDate = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortByDate];
    
    switch (self.selectedEvent.eventCategory) {
        case kWeights:
            tempArray = [self.coreDataHelper.fetchedResultsController.fetchedObjects subarrayWithRange:range];
            self.weightLiftingEvents = [tempArray sortedArrayUsingDescriptors:sortDescriptors];
            break;
            
        default:
            tempArray = [self.coreDataHelper.fetchedResultsController.fetchedObjects subarrayWithRange:range];
            self.aerobicEvents = [tempArray sortedArrayUsingDescriptors:sortDescriptors];
            break;
    }
}
#pragma mark - Chart behavior

- (void)initPlot
{
    [self findMinAndMax];
    [self confingureHost];
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];
}

- (void)findMinAndMax
{
    self.yMin = [[NSNumber alloc] initWithInt:1000];
    self.yMax = [[NSNumber alloc] initWithInt:0];
    
    switch (self.selectedEvent.eventCategory) {
        case kWeights:
            for (WeightLiftingEvent *weightEvent in self.weightLiftingEvents) {
                [self setMinMax:weightEvent.weight];
            }
            break;
            
        default:
            switch (self.selectedEvent.eventCategory) {
                case kWalking:
                case kRunning:
                    {
                        switch (self.activitySelectorOutlet.selectedSegmentIndex) {
                            case kWalkHR:
                                for (AerobicEvent *aerobicEvent in self.aerobicEvents) {
                                    [self setMinMax:aerobicEvent.heartRate];
                                }
                                break;
                            case kWalkTime:
                                for (AerobicEvent *aerobicEvent in self.aerobicEvents) {
                                    [self setMinMax:aerobicEvent.duration];
                                }
                                break;
                            case kWalkDistance:
                                for (AerobicEvent *aerobicEvent in self.aerobicEvents) {
                                    [self setMinMax:aerobicEvent.distance];
                                }
                                break;
                            default:
                                break;
                        }
                    }
                    break;
                case kBicycling:
                    {
                        switch (self.activitySelectorOutlet.selectedSegmentIndex) {
                            case kBikeHR:
                                for (AerobicEvent *aerobicEvent in self.aerobicEvents) {
                                    [self setMinMax:aerobicEvent.heartRate];
                                }
                                break;
                            case kBikeTime:
                                for (AerobicEvent *aerobicEvent in self.aerobicEvents) {
                                    [self setMinMax:aerobicEvent.duration];
                                }
                                break;
                            case kBikeCadence:
                                for (AerobicEvent *aerobicEvent in self.aerobicEvents) {
                                    [self setMinMax:aerobicEvent.cadenace];
                                }
                                break;
                            default:
                                break;
                        }
                    }
                    break;
                    
                default:
                    break;
            }
            break;
    }
    // if min and max are equal then set 10 point apart
    
    if ([self.yMax isEqualToNumber: self.yMin]){
        if ([self.yMin isLessThanOrEqualTo: @(5)]) {
            self.yMax =  @([self.yMin integerValue] + 10);
        } else {
            self.yMax = @([self.yMax integerValue] + 5);
            self.yMin = @([self.yMin integerValue] - 5);
        }
    }
}

- (void)setMinMax:(NSNumber *)value
{
    if ([value isLessThan: self.yMin]) {
        self.yMin = value;
    }
    if ([value isGreaterThan: self.yMax]) {
        self.yMax = value;
    }
}

- (void)confingureHost
{
    CGRect windowRect = self.view.bounds;
    CGSize navBarSize = self.navigationController.navigationBar.bounds.size;
    windowRect = CGRectMake(windowRect.origin.x, windowRect.origin.y+navBarSize.height, windowRect.size.width, windowRect.size.height-80); // making space for period
    self.hostView = [[CPTGraphHostingView alloc] initWithFrame:windowRect];
    self.hostView.allowPinchScaling = YES;
    [self.view addSubview:self.hostView];
}

- (void)configureGraph
{
    // Create the graph
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    [graph applyTheme:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
    self.hostView.hostedGraph = graph;
    
    // Set padding for plot area
    [graph.plotAreaFrame setPaddingLeft:20.0f];
    [graph.plotAreaFrame setPaddingBottom:20.0f];
    
    // Enable user interaction for plotspace
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
}

- (void)configurePlots
{
    // Get graph and plot space
    CPTGraph *graph = self.hostView.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    
    
    // Create the plot
    CPTScatterPlot *eventPlot = [[CPTScatterPlot alloc] init];
    eventPlot.dataSource = self;
    eventPlot.identifier = self.selectedEvent.eventName;
    CPTColor *eventColor = [CPTColor redColor];
    [graph addPlot:eventPlot toPlotSpace:plotSpace];
    
    // Set up plot space
    [plotSpace scaleToFitPlots:[NSArray arrayWithObjects:eventPlot, nil]];
    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
    [xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
    plotSpace.xRange = xRange;
    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
    yRange = [CPTMutablePlotRange plotRangeWithLocation:CPTDecimalFromInt([self.yMin intValue] -6) length:CPTDecimalFromInt([self.yMax intValue] - [self.yMin intValue] +5)];
    [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.4f)];
    plotSpace.yRange = yRange;
    plotSpace.globalYRange = plotSpace.yRange;
    
    //Create styles and symbol
    CPTMutableLineStyle *eventLineStyle = [eventPlot.dataLineStyle mutableCopy];
    eventLineStyle.lineWidth = 1.5;
    eventLineStyle.lineColor = eventColor;
    eventPlot.dataLineStyle = eventLineStyle;
    CPTMutableLineStyle *eventSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    eventSymbolLineStyle.lineColor = eventColor;
    CPTPlotSymbol *eventSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    eventSymbol.fill = [CPTFill fillWithColor:eventColor];
    eventSymbol.lineStyle = eventSymbolLineStyle;
    eventSymbol.size = CGSizeMake(4.0f, 4.0f);
    eventPlot.plotSymbol = eventSymbol;
    
}

- (void)configureAxes
{
    // Create styles
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor whiteColor];
    axisTitleStyle.fontName = @"Helvetica-Bold";
    axisTitleStyle.fontSize = 12.0f;
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [CPTColor whiteColor];
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = [CPTColor whiteColor];
    axisTextStyle.fontName = @"Helvetica-Bold";
    axisTextStyle.fontSize = 11.0f;
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor whiteColor];
    tickLineStyle.lineWidth = 2.0f;
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor blackColor];
    tickLineStyle.lineWidth = 1.0f;
    
    // Get axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    
    // Configure x-axis
    axisSet.xAxis.orthogonalCoordinateDecimal = CPTDecimalFromInt([self.yMin intValue]-5);
    
    CPTAxis *x = axisSet.xAxis;
//    x.title = [self.activitySelectorOutlet titleForSegmentAtIndex:self.activitySelectorOutlet.selectedSegmentIndex];
    x.titleTextStyle = axisTitleStyle;
    x.titleOffset = -20.0f;
    x.axisLineStyle = axisLineStyle;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    x.labelTextStyle = axisTextStyle;
    x.majorTickLineStyle = axisLineStyle;
    x.majorTickLength = 4.0f;
    x.tickDirection = CPTSignNegative;
    CGFloat eventCount = [self.period floatValue];
    NSMutableSet *xLabels = [NSMutableSet setWithCapacity:eventCount];
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:eventCount];
    NSInteger i = 0;
    NSInteger jump;
    jump = eventCount / 30 +1;
    NSString *date;
    for (int j = 1; j <= eventCount; j += jump) {
        date = [self plotDate:j-1];
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%@", date]  textStyle:x.labelTextStyle];
        CGFloat location = i;
        i += jump;
        label.tickLocation = CPTDecimalFromCGFloat(location);
        label.offset = x.majorTickLength;
        label.rotation = M_PI / 4;
        if (label) {
            [xLabels addObject:label];
            [xLocations addObject:[NSNumber numberWithFloat:location]];
        }
    }
    x.axisLabels = xLabels;
    x.majorTickLocations = xLocations;
    
    // Configure y-axis
    [self getEventTitle];
    CPTAxis *y = axisSet.yAxis;
    y.title = self.eventTitle;
    y.titleTextStyle = axisTitleStyle;
    y.titleOffset = -45.0f;
    y.axisLineStyle = axisLineStyle;
    y.majorGridLineStyle = gridLineStyle;
    y.labelingPolicy = CPTAxisLabelingPolicyNone;
    y.labelTextStyle = axisTextStyle;
    y.labelOffset = 25.0f;
    y.majorTickLineStyle = axisLineStyle;
    y.majorTickLength = 4.0f;
    y.minorTickLength = 2.0f;
    y.tickDirection = CPTSignPositive;
    NSInteger majorIncrement = 5;
    NSInteger minorIncrement = 1;
    NSInteger factor;
    CGFloat yMax = [self.yMax floatValue] + 5.0;  // should determine dynamically based on max
    CGFloat yMin = [self.yMin floatValue] - 5.0;  // should determine dynamically based on max
    CGFloat range = yMax - yMin;
    factor = range / 60 + 1;
    NSMutableSet *yLabels = [NSMutableSet set];
    NSMutableSet *yMajorLocations = [NSMutableSet set];
    NSMutableSet *yMinorLocations = [NSMutableSet set];
    for (NSInteger j = yMin; j <= yMax; j += minorIncrement) {
        NSUInteger mod = j % (majorIncrement * factor);
        if (mod == 0) {
            CPTAxisLabel *label;
            if (self.activitySelectorOutlet.selectedSegmentIndex == kWalkTime)
            {
                label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%ld:%02ld", (long)j/60, (long)j%60] textStyle:y.labelTextStyle];
            } else {
                label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%li", (long)j] textStyle:y.labelTextStyle];
            }
            NSDecimal location = CPTDecimalFromInteger(j);
            label.tickLocation = location;
            label.offset = -y.majorTickLength - y.labelOffset;
            if (label) {
                [yLabels addObject:label];
            }
            [yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
        } else {
            [yMinorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromInteger(j)]];
        }
    }
    y.axisLabels = yLabels;    
    y.majorTickLocations = yMajorLocations;
    y.minorTickLocations = yMinorLocations;
}


#pragma mark - CPTPlotDataSource

- (void)getEventTitle
{
    switch (self.selectedEvent.eventCategory) {
        case kWeights:
        {
            self.eventTitle = @"Weight";
        }
            break;
            
        default:
        {
            self.eventTitle = [self.activitySelectorOutlet titleForSegmentAtIndex:self.activitySelectorOutlet.selectedSegmentIndex];
        }
            break;
    }

}
- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [self.period integerValue];
}

- (NSString *)dateToFormatMMddyyy:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSString *convertedDate = [dateFormatter stringFromDate:date];
    NSString *formattedDate = [[NSString alloc] initWithFormat:@"%@", convertedDate];
    
    return formattedDate;
}

- (NSString *)plotDate:(NSUInteger)plotPoint
{
    NSString *date;
    switch (self.selectedEvent.eventCategory) {
        case kWeights:
        {
            WeightLiftingEvent *weightEvent = self.weightLiftingEvents[plotPoint];
            date = [self dateToFormatMMddyyy:weightEvent.date];
        }
            break;
            
        default:
        {
            AerobicEvent *aerobicEvent = self.aerobicEvents[plotPoint];
            date = [self dateToFormatMMddyyy:aerobicEvent.date];
        }
            break;
    }
    NSLog(@"Date: %@ for %lu", date, (unsigned long)plotPoint);
    return date;
}

- (id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx
{
    switch (fieldEnum) {
        case CPTScatterPlotFieldX:
            {
                NSLog(@"x value for %lu is %lu", (unsigned long)idx, (unsigned long)idx);
                return [NSNumber numberWithUnsignedInteger:idx];
            }
            break;
        case CPTScatterPlotFieldY:
            {
                switch (self.selectedEvent.eventCategory) {
                    case kWeights:
                        {
                            WeightLiftingEvent *weightEvent = self.weightLiftingEvents[idx];
                            NSLog(@"x value for %lu is %@", (unsigned long)idx, weightEvent.weight);
                            return weightEvent.weight;
                        }
                        break;
                        
                    default:
                        {
                            AerobicEvent *aerobicEvent = self.aerobicEvents[idx];
                            switch (self.selectedEvent.eventCategory) {
                                case kWalking:
                                case kRunning:
                                    {
                                        switch (self.activitySelectorOutlet.selectedSegmentIndex) {
                                            case kWalkHR:
                                                NSLog(@"y value for %lu is %@", (unsigned long)idx, aerobicEvent.heartRate);
                                                return aerobicEvent.heartRate;
                                                break;
                                            case kWalkTime:
                                                NSLog(@"y value for %lu is %@", (unsigned long)idx, aerobicEvent.duration);
                                                return aerobicEvent.duration;
                                                break;
                                            case kWalkDistance:
                                                NSLog(@"y value for %lu is %@", (unsigned long)idx, aerobicEvent.distance);
                                                return aerobicEvent.distance;
                                                break;
                                            default:
                                                break;
                                        }
                                    }
                                    break;
                                case kBicycling:
                                    {
                                        switch (self.activitySelectorOutlet.selectedSegmentIndex) {
                                            case kBikeHR:
                                                NSLog(@"y value for %lu is %@", (unsigned long)idx, aerobicEvent.heartRate);
                                                return aerobicEvent.heartRate;
                                                break;
                                            case kBikeTime:
                                                NSLog(@"y value for %lu is %@", (unsigned long)idx, aerobicEvent.duration);
                                                return aerobicEvent.duration;
                                                break;
                                            case kBikeCadence:
                                                NSLog(@"y value for %lu is %@", (unsigned long)idx, aerobicEvent.cadenace);
                                                return aerobicEvent.cadenace;
                                                break;
                                            default:
                                                break;
                                        }
                                    }
                                    break;

                                    
                                default:
                                    break;
                            }
                        }
                        break;
                }
            }
            break;
        default:
            break;
    }
    return [NSDecimalNumber zero];
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
