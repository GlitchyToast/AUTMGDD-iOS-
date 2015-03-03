//
//  TableViewCell.h
//  GDD
//
//  Created by Ryan Nichols on 2/28/15.
//  Copyright (c) 2015 Ran0005. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *plantLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentGDD;
@property (weak, nonatomic) IBOutlet UILabel *GDDthreshold;
@property (weak, nonatomic) IBOutlet UILabel *actuallGDD;

@end
