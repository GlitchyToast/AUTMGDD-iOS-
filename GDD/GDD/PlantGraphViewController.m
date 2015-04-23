//
//  PlantGraphViewController.m
//  GDD
//
//  Created by Ryan Nichols on 4/12/15.
//  Copyright (c) 2015 Ran0005. All rights reserved.
//

#import "PlantGraphViewController.h"

@interface PlantGraphViewController ()
@property (nonatomic, readwrite, strong) CPTXYGraph *graph;

@end

@implementation PlantGraphViewController
@synthesize plotData;
@synthesize graph;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSDate *refDate            = [NSDate dateWithTimeIntervalSince1970:self.startUnix];
    NSTimeInterval oneDay      = 24 * 60 * 60;
    
    CPTXYGraph *newGraph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CPTTheme *theme      = [CPTTheme themeNamed:kCPTDarkGradientTheme];
    [newGraph applyTheme:theme];
    self.graph = newGraph;
    
    CPTGraphHostingView *hostingView = (CPTGraphHostingView *)self.view;
    hostingView.collapsesLayers = NO; // Setting to YES reduces GPU memory usage, but can slow drawing/scrolling
    hostingView.allowPinchScaling = YES;
    hostingView.hostedGraph     = newGraph;
    
    newGraph.paddingLeft   = 10.0;
    newGraph.paddingTop    = 20.0;
    newGraph.paddingRight  = 10.0;
    newGraph.paddingBottom = 10.0;
    
    // Setup plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)newGraph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    plotSpace.xRange                = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0) length:CPTDecimalFromDouble(oneDay * 30.0)];
    plotSpace.yRange                = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0) length:CPTDecimalFromDouble(100.0)];
    
    // Axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)newGraph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.majorIntervalLength         = CPTDecimalFromFloat(oneDay * 10);
    x.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0");
    x.minorTicksPerInterval       = 10;
    x.tickDirection = CPTSignPositive;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = kCFDateFormatterShortStyle;
    CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];
    timeFormatter.referenceDate = refDate;
    axisSet.xAxis.labelFormatter = timeFormatter;
    
    CPTXYAxis *y = axisSet.yAxis;
    y.majorIntervalLength         = CPTDecimalFromDouble(10.0);
    y.minorTicksPerInterval       = 1;
    y.orthogonalCoordinateDecimal = CPTDecimalFromFloat(oneDay);
    y.tickDirection = CPTSignPositive;

    //Lock axis to side
    x.axisConstraints = [CPTConstraints constraintWithLowerOffset:0.0];
    y.axisConstraints = [CPTConstraints constraintWithLowerOffset:0.0];
    y.delegate             = self;
    
     // Create a blue plot area
     CPTScatterPlot *boundLinePlot  = [[CPTScatterPlot alloc] init];
     CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
     lineStyle.miterLimit        = 1.0;
     lineStyle.lineWidth         = 3.0;
     lineStyle.lineColor         = [CPTColor blueColor];
     boundLinePlot.dataLineStyle = lineStyle;
     boundLinePlot.identifier    = @"Blue Plot";
     boundLinePlot.dataSource    = self;
     [newGraph addPlot:boundLinePlot];
    
    /*
     NSString *tileDirectory = [[NSBundle mainBundle] resourcePath];
     CPTImage *fillImage = [CPTImage imageNamed:@"BlueTexture"];
     fillImage.tiled = YES;
     CPTFill *areaImageFill = [CPTFill fillWithImage:fillImage];
     boundLinePlot.areaFill      = areaImageFill;
     boundLinePlot.areaBaseValue = [[NSDecimalNumber zero] decimalValue];
     */
    
    /*
     
     // Animate in the new plot, as an example
     dataSourceLinePlot.opacity = 0.0;
     [newGraph addPlot:dataSourceLinePlot];
     
     CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
     fadeInAnimation.duration            = 1.0;
     fadeInAnimation.removedOnCompletion = NO;
     fadeInAnimation.fillMode            = kCAFillModeForwards;
     fadeInAnimation.toValue             = @1.0;
     [dataSourceLinePlot addAnimation:fadeInAnimation forKey:@"animateOpacity"];
     */
    
    
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
    dataSourceLinePlot.identifier = @"Date Plot";
    dataSourceLinePlot.delegate = self;
    
    
    dataSourceLinePlot.dataSource = self;
    [newGraph addPlot:dataSourceLinePlot];
    
    // Add some initial data
    NSMutableArray *contentArray = [[NSMutableArray alloc] init];
    contentArray = [self dataToDisplay];

    self.plotData = contentArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *) dataToDisplay {
    long start = self.startUnix;
    int position = [self getPosition];
    double base = [[self.baseValues objectAtIndex:position] doubleValue];
    NSMutableArray* cumulativeGdd = [[NSMutableArray alloc] init];
    Boolean firstAdded = false;
    double oneDay = 60 * 60 * 24;
    
    for (int i = 0; i < [self.averageTemps count]; i++) {
        double gdd = [[self.averageTemps objectForKey:[NSString stringWithFormat:@"%ld", start]] doubleValue] - base;
        NSTimeInterval xVal = oneDay * i;
        if (!firstAdded) {
            if (gdd > 0) {
                [cumulativeGdd addObject:@{ @"x": @(xVal),
                                            @"y": @(gdd) }];
                firstAdded = true;
            }
            else {
                [cumulativeGdd addObject:@{ @"x": @(xVal),
                                            @"y": @(0) }];
            }
        }
        else {
            NSDictionary *temp = [cumulativeGdd objectAtIndex:(i-1)];
            NSNumber *toAdd = [temp objectForKey:@"y"];
            if (gdd > 0) {
                [cumulativeGdd addObject:@{ @"x": @(xVal),
                                            @"y": @(gdd + [toAdd doubleValue]) }];
            }
            else {
                [cumulativeGdd addObject:@{ @"x": @(xVal),
                                            @"y": @([toAdd doubleValue]) }];
            }
        }
        //seconds in a day
        start = start + 86400;
    }
    return cumulativeGdd;
}

- (int) getPosition {
    int position = 0;
    Boolean found = false;
    while (!found) {
        if (self.plants[position] == self.plant) {
            found = true;
        }
        position++;
    }
    
    
    return position-1;
}
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [self.plotData count];
}



-(id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSString *key = (fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y");
    NSNumber *num = self.plotData[index][key];
    
    return num;
}

- (CPTPlotRange *)plotSpace:(CPTPlotSpace *)space
      willChangePlotRangeTo:(CPTPlotRange *)newRange
              forCoordinate:(CPTCoordinate)coordinate {
    
    CPTPlotRange *updatedRange = nil;
    
    switch ( coordinate ) {
        case CPTCoordinateX:
            if (newRange.locationDouble < 0.0F) {
                CPTMutablePlotRange *mutableRange = [newRange mutableCopy];
                mutableRange.location = CPTDecimalFromFloat(0.0);
                updatedRange = mutableRange;
            }
            else {
                updatedRange = newRange;
            }
            break;
        case CPTCoordinateY:
            updatedRange = ((CPTXYPlotSpace *)space).yRange;
            break;
    }
    return updatedRange;
}


@end
