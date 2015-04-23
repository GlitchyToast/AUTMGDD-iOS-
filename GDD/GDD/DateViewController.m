//
//  DateViewController.m
//  GDD
//
//  Created by Ryan Nichols on 2/20/15.
//  Copyright (c) 2015 Ran0005. All rights reserved.
//

#import "DateViewController.h"
#import "PlantsViewController.h"

@interface DateViewController ()
@property (weak, nonatomic) IBOutlet UIDatePicker *startDate;
@property (weak, nonatomic) IBOutlet UIDatePicker *endDate;

@end

@implementation DateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDate *currentDate = _startDate.date;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* currentComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:currentDate];
    [currentComponents setDay:1];
    [currentComponents setMonth:1];
    [currentComponents setMinute:0];
    [currentComponents setSecond:0];
    NSDate *jan = [calendar dateFromComponents:currentComponents];
    [self.startDate setDate:jan];
    self.view.backgroundColor = [UIColor colorWithRed:0/256.0 green:220/256.0 blue:255/256.0 alpha:1];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"toPlantCells"] )
    {
        
        NSInteger startUnix = [self.startDate.date timeIntervalSince1970];
        NSInteger endUnix = [self.endDate.date timeIntervalSince1970];
        PlantsViewController *plantView = (PlantsViewController *)[segue destinationViewController];
        plantView.startUnix = startUnix;
        plantView.endUnix = endUnix;
        plantView.lat = self.lat;
        plantView.lon = self.lon;
    }
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}



@end
