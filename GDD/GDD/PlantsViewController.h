//
//  PlantsViewController.h
//  GDD
//
//  Created by Ryan Nichols on 2/18/15.
//  Copyright (c) 2015 Ran0005. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableViewCell.h"
@interface PlantsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) NSInteger startUnix;
@property (nonatomic) NSInteger endUnix;
@property (nonatomic) double lat;
@property (nonatomic) double lon;
@end
