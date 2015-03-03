//
//  PlantsViewController.m
//  GDD
//
//  Created by Ryan Nichols on 2/18/15.
//  Copyright (c) 2015 Ran0005. All rights reserved.
//

#import "PlantsViewController.h"
#import "TableViewCell.h"

static NSString *simpleTableIdentifier = @"CellTableIdentifier";
static NSString *serverAddress = @"https://api.forecast.io/forecast/331224fc1ce6b64e7cf56e15164bcf33";
@interface PlantsViewController ()
@property (copy, nonatomic) NSArray *plants;
@property (copy, nonatomic) NSDictionary *gdd;
@property (copy, nonatomic) NSArray *values;
@property (copy, nonatomic) NSMutableArray *realGDD;
@end

@implementation PlantsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.plants = [NSArray arrayWithObjects:
                   @"Tropical Signalgrass",
                   @"Smooth Crabgrass",
                   @"Large Crabgrass",
                   @"Giant Foxtail",
                   @"Yellow Foxtail",
                   @"Henbit",
                   @"Common Chickweed",
                   @"Giant Foxtail",
                   @"Yellow Foxtail",
                   @"Green Foxtail",
                   @"Woolly Cupgrass",
                   @"Field Sandbur",
                   @"Goosegrass",
                   nil];
    
    //UITableView *tableView = (id)[self.view viewWithTag:1];
    //[tableView registerClass:[TableViewCell class] forCellReuseIdentifier:simpleTableIdentifier];
    
    //UINib *nib = [UINib nibWithNibName:@"CustomCell" bundle:nil];
    //[tableView registerNib:nib forCellReuseIdentifier:simpleTableIdentifier];
    //UIEdgeInsets contentInset = tableView.contentInset;
    //contentInset.top = 20;
    //[tableView setContentInset:contentInset];
    
    self.values = [NSArray arrayWithObjects:@"156", @"140", @"580", @"365", @"360", @"3200", @"3200", @"245", @"249", @"318", @"219", @"286", @"550", nil];
    self.gdd = [NSDictionary dictionaryWithObjects:self.values forKeys:self.plants];

    [self getTemp];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.plants count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    TableViewCell *cell = (TableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CustomCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        //cell = [[TableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
          //                     reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.plantLabel.text = self.plants[indexPath.row];
    cell.GDDthreshold.text = self.values[indexPath.row];
    return cell;
}

- (void) getTemp {
    NSString *temp = [NSString stringWithFormat:@"%f", self.lat];
    NSString *temp2 = [NSString stringWithFormat:@"%f", self.lon];
    temp = [temp stringByAppendingString:@","];
    temp = [temp stringByAppendingString:temp2];
    serverAddress = [serverAddress stringByAppendingString:temp];
    NSURL *url = [NSURL URLWithString:serverAddress];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLResponse *response;
    NSError *error;
    //send it synchronous
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    // check for an error. If there is a network error, you should handle it here.
    if(!error)
    {
        //log response
        NSLog(@"Response from server = %@", responseString);
    }
    
    
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
