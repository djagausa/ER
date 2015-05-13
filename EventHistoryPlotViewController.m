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

@end

id gestureRecognizerDelegate;

@implementation EventHistoryPlotViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        gestureRecognizerDelegate = self.navigationController.interactivePopGestureRecognizer.delegate;
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    self.yMin = [[NSNumber alloc] initWithInt:1000];
    self.yMax = [[NSNumber alloc] initWithInt:0];

    // Do any additional setup after loading the view.
    self.navigationItem.title = [NSString stringWithFormat:@"%@", self.selectedEvent.eventName];
    
    [self initPlot];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = gestureRecognizerDelegate;
    }

    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return NO;
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
    switch (self.selectedEvent.eventCategory) {
        case kWeights:
            for (WeightLiftingEvent *weightEvent in self.coreDataHelper.fetchedResultsController.fetchedObjects) {
                NSNumber *weight = weightEvent.weight;
                if (weight < self.yMin) {
                    self.yMin = weight;
                }
                if (weight > self.yMax) {
                    self.yMax = weight;
                }
            }

            break;
            
        default:
            for (AerobicEvent *aerobicEvent in self.coreDataHelper.fetchedResultsController.fetchedObjects) {
                NSNumber *hr = aerobicEvent.heartRate;
                if (hr < self.yMin) {
                    self.yMin = hr;
                }
                if (hr > self.yMax) {
                    self.yMax = hr;
                }
            }
            break;
    }
}
- (void)confingureHost
{
    CGRect windowRect = self.view.bounds;
    CGSize navBarSize = self.navigationController.navigationBar.bounds.size;
    windowRect = CGRectMake(windowRect.origin.x, windowRect.origin.y+navBarSize.height, windowRect.size.width, windowRect.size.height-60); // making space for period
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
    
//    //Set the graph title
//    NSString *title = self.selectedEvent.eventName;
//    graph.title = title;
//    
//    // Create and set the text style
//    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
//    titleStyle.color = [CPTColor whiteColor];
//    titleStyle.fontName = @"Helvetica-Bold";
//    titleStyle.fontSize = 16.0f;
//    graph.titleTextStyle = titleStyle;
//    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
//    graph.titleDisplacement = CGPointMake(0.0f, -10.0f);
//    
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
    [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.2f)];
    plotSpace.yRange = yRange;
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInt([self.yMin intValue]-15) length:CPTDecimalFromInt([self.yMax intValue] - [self.yMin intValue] + 20 )];
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
//    x.title = @"Set";
    x.titleTextStyle = axisTitleStyle;
    x.titleOffset = -20.0f;
    x.axisLineStyle = axisLineStyle;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    x.labelTextStyle = axisTextStyle;
    x.majorTickLineStyle = axisLineStyle;
    x.majorTickLength = 4.0f;
    x.tickDirection = CPTSignNegative;
    CGFloat eventCount = self.coreDataHelper.fetchedResultsController.fetchedObjects.count;
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
    CPTAxis *y = axisSet.yAxis;
    y.title = @"Weight";
    y.titleTextStyle = axisTitleStyle;
    y.titleOffset = -40.0f;
    y.axisLineStyle = axisLineStyle;
    y.majorGridLineStyle = gridLineStyle;
    y.labelingPolicy = CPTAxisLabelingPolicyNone;
    y.labelTextStyle = axisTextStyle;
    y.labelOffset = 20.0f;
    y.majorTickLineStyle = axisLineStyle;
    y.majorTickLength = 4.0f;
    y.minorTickLength = 2.0f;
    y.tickDirection = CPTSignPositive;
    NSInteger majorIncrement = 5;
    NSInteger minorIncrement = 1;
    CGFloat yMax = [self.yMax floatValue] + 5.0;  // should determine dynamically based on max
    CGFloat yMin = [self.yMin floatValue] - 5.0;  // should determine dynamically based on max

    NSMutableSet *yLabels = [NSMutableSet set];
    NSMutableSet *yMajorLocations = [NSMutableSet set];
    NSMutableSet *yMinorLocations = [NSMutableSet set];
    for (NSInteger j = yMin; j <= yMax; j += minorIncrement) {
        NSUInteger mod = j % majorIncrement;
        if (mod == 0) {
            CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%li", (long)j] textStyle:y.labelTextStyle];
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
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return self.coreDataHelper.fetchedResultsController.fetchedObjects.count;
}

- (NSString *)dateToFormatMMddyyy:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSString *convertedDate = [dateFormatter stringFromDate:date];
    NSString *formattedDate = [[NSString alloc] initWithFormat:@"%@", convertedDate];
    
    return formattedDate;
}

-(NSString *)plotDate:(NSUInteger)plotPoint
{
    NSString *date;
    switch (self.selectedEvent.eventCategory) {
        case kWeights:
        {
            WeightLiftingEvent *weightEvent = self.coreDataHelper.fetchedResultsController.fetchedObjects[plotPoint];
            date = [self dateToFormatMMddyyy:weightEvent.date];
        }
            break;
            
        default:
        {
            AerobicEvent *aerobicEvent = self.coreDataHelper.fetchedResultsController.fetchedObjects[plotPoint];
            date = [self dateToFormatMMddyyy:aerobicEvent.date];
        }
            break;
    }
    NSLog(@"Date: %@ for %lu", date, (unsigned long)plotPoint);
    return date;
}

-(id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx
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
                            WeightLiftingEvent *weightEvent = self.coreDataHelper.fetchedResultsController.fetchedObjects[idx];
                            NSLog(@"x value for %lu is %@", (unsigned long)idx, weightEvent.weight);

                            return weightEvent.weight;
                        }
                        break;
                        
                    default:
                        {
                            AerobicEvent *aerobicEvent = self.coreDataHelper.fetchedResultsController.fetchedObjects[idx];
                            NSLog(@"y value for %lu is %@", (unsigned long)idx, aerobicEvent.heartRate);

                            return aerobicEvent.heartRate;
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
