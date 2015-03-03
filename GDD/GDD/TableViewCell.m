//
//  TableViewCell.m
//  GDD
//
//  Created by Ryan Nichols on 2/28/15.
//  Copyright (c) 2015 Ran0005. All rights reserved.
//

#import "TableViewCell.h"

@implementation TableViewCell
@synthesize plantLabel = _plantLabel;
@synthesize currentGDD = _currentGDD;
@synthesize GDDthreshold = _GDDthreshold;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
