//
//  PlantGraphViewController.h
//  GDD
//
//  Created by Ryan Nichols on 4/12/15.
//  Copyright (c) 2015 Ran0005. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface PlantGraphViewController : UIViewController <CPTPlotDataSource>
//@property (retain, nonatomic) NSMutableArray *gddPerPlant;
@property (copy, nonatomic) NSArray *plants;
@property (copy, nonatomic) NSArray *startValues;
@property (copy, nonatomic) NSArray *peakValues;
@property (copy, nonatomic) NSArray *baseValues;
@property (weak, nonatomic) NSString *plant;
@property (retain, nonatomic) NSMutableDictionary *averageTemps;
@property (nonatomic) NSInteger startUnix;
@property (nonatomic) NSInteger endUnix;

@property (nonatomic, readwrite, strong) NSMutableArray *plotData;

@end
