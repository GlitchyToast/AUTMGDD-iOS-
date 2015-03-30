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
static NSString *serverAddress = @"https://api.forecast.io/forecast/331224fc1ce6b64e7cf56e15164bcf33/";
static NSString *params = @"?units=si&exclude=[currently,minutely,hourly,alerts,flags]";
static NSInteger secondsPerDay = 86400;
@interface PlantsViewController ()
@property (copy, nonatomic) NSArray *plants;
@property (copy, nonatomic) NSDictionary *gdd;
@property (copy, nonatomic) NSArray *startValues;
@property (copy, nonatomic) NSArray *peakValues;
@property (copy, nonatomic) NSMutableArray *realGDD;
@property (copy, nonatomic) NSDictionary *averageTemps;
@property (retain, nonatomic) NSMutableArray *gddPerPlant;
@property (copy, nonatomic) NSArray *baseValues;
@property (retain, nonatomic) NSMutableDictionary *zips;
@end

@implementation PlantsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.plants = [NSArray arrayWithObjects:
                   @"Tropical Signalgrass",
                   @"Smooth Crabgrass",
                   @"Henbit",
                   @"Common Chickweed",
                   @"Giant Foxtail",
                   @"Yellow Foxtail",
                   @"Green Foxtail",
                   @"Woolly Cupgrass",
                   @"Field Sandbur",
                   @"Goosegrass",
                   nil];
    
    self.peakValues = [NSArray arrayWithObjects:@"156", @"140", @"3200", @"3200", @"245", @"249", @"318", @"219", @"286", @"550", nil];
    self.startValues = [NSArray arrayWithObjects:@"73", @"42", @"2300", @"2300", @"83", @"121", @"116", @"106", @"99", @"450", nil];
    self.baseValues = [NSArray arrayWithObjects:@"13", @"12", @"0", @"0", @"9", @"9", @"9", @"9", @"9", @"10", nil];
    self.gdd = [NSDictionary dictionaryWithObjects:self.startValues forKeys:self.plants];
    if (!self.gddPerPlant)
    {
        self.gddPerPlant = [[NSMutableArray alloc] init];
        for (int i = 0; i < [self.plants count]; i++)
        {
            [self.gddPerPlant addObject:[NSNumber numberWithDouble:0]];
        }
    }
    self.zips = [self dictionaryWithPropertyListAtPath:[self getPath]];
    if (self.zips == nil)
        self.zips = [[NSMutableDictionary alloc] init];
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
    cell.GDDthreshold.text = self.startValues[indexPath.row];
    cell.actuallGDD.text = [NSString stringWithFormat:@"%.2f", [self.gddPerPlant[indexPath.row] doubleValue]];
    return cell;
}

- (void) getTemp {
    long start = self.startUnix;
    if (!([self checkIfZipCodeExists:self.zips])) {
        [self addZipCode:self.zips];
    }
    while (start <= self.endUnix) {
        NSURL *url = [self returnFormattedURL:start];
        NSString *responseString = [self returnResponseFromWebsite:url];
        NSArray *maxMin = [self returnMaxMinTemps:responseString];
        double average = [self calculateAverage:maxMin];
        [self addAverageTempToDict:self.zips :average :start];
        for (int i = 0; i < [self.startValues count]; i++)
        {
            NSNumber *gdd = [NSNumber numberWithDouble:(average - [self.baseValues[i] doubleValue])];
            if (!(gdd.doubleValue < 0)) {
            self.gddPerPlant[i] = [NSNumber numberWithDouble:([self.gddPerPlant[i] doubleValue] + gdd.doubleValue)];
            }
        }
        start = start + secondsPerDay;
    }
    [self saveDictionary:self.zips toPropertyListAtPath:[self getPath]];
}

-(NSURL *) returnFormattedURL: (long) start {
    NSString *temp = [NSString stringWithFormat:@"%f", self.lat];
    NSString *temp2 = [NSString stringWithFormat:@"%f", self.lon];
    NSString *time = [NSString stringWithFormat:@"%ld", start];
    temp = [temp stringByAppendingString:@","];
    temp = [temp stringByAppendingString:temp2];
    temp = [temp stringByAppendingString:@","];
    temp = [temp stringByAppendingString:time];
    temp = [temp stringByAppendingString:params];
    temp2 = serverAddress;
    temp2 = [temp2 stringByAppendingString:temp];
    NSURL *url = [NSURL URLWithString:temp2];
    return url;
}

-(NSString *)returnResponseFromWebsite: (NSURL*) url {
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLResponse *response;
    NSError *error;
    //send it synchronous
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    return responseString;
}

-(NSArray*) returnMaxMinTemps: (NSString*) responseString {
    NSNumber  *max;
    NSNumber *min;
    NSArray *splitTemperatureMax;
    NSArray *splitTemperatureMin;
    NSArray *splitResponse = [responseString componentsSeparatedByString:@","];
    Boolean maxSet = FALSE;
    Boolean minSet = FALSE;
    
    for (int i = 0; i < [splitResponse count]; i++)
    {
        if (!([splitResponse[i] rangeOfString:@"\"temperatureMax\":"].location == NSNotFound)) {
            splitTemperatureMax = [splitResponse[i] componentsSeparatedByString:@":"];
            max = [NSNumber numberWithDouble:([[splitTemperatureMax[1] stringByReplacingOccurrencesOfString:@"," withString:@""] doubleValue])];
            maxSet = TRUE;
            if (minSet) break;
        }
        
        else if (!([splitResponse[i] rangeOfString:@"\"temperatureMin\":"].location == NSNotFound)) {
            splitTemperatureMin = [splitResponse[i] componentsSeparatedByString:@":"];
            min = [NSNumber numberWithDouble:([[splitTemperatureMin[1] stringByReplacingOccurrencesOfString:@"," withString:@""] doubleValue])];
            minSet = TRUE;
            if (maxSet) break;
        }
    }
    NSArray *maxMin = [NSArray arrayWithObjects:max, min, nil];
    return maxMin;
}

- (double) calculateAverage: (NSArray*) maxMin {
    double max = [maxMin[0] doubleValue];
    double min = [maxMin[1] doubleValue];
    double average = (max - min) / 2;
    return average;
}

- (Boolean) checkIfZipCodeExists: (NSMutableDictionary*) dict {
    if ([dict objectForKey:[self doubleToString:self.lat]] != nil)
    {
        return TRUE;
    }
    
    return FALSE;
}

-(void) addZipCode: (NSMutableDictionary*) dict  {
    NSMutableDictionary *dates = [[NSMutableDictionary alloc] init];
    if ([dict objectForKey:[self doubleToString:self.lat]] == nil)
    {
        [dict setObject:dates forKey:[self doubleToString:self.lat]];
    }
}
-(void) addAverageTempToDict: (NSMutableDictionary*) dict :(double) temp :(long) date {
    NSString *key= [self doubleToString:self.lat];
    NSString *avgTemp = [self doubleToString:temp];
    NSString *unixDate = [NSString stringWithFormat:@"%ld", date];
    if ([dict objectForKey:unixDate] == nil) {
        [[self.zips objectForKey:key]
         setObject:avgTemp forKey:unixDate];
    }
}
     
- (NSString*) doubleToString: (double) value {
    return [NSString stringWithFormat:@"%f", value];
}

- (NSMutableDictionary *) dictionaryWithPropertyListAtPath: (NSString *) path {
    NSString *error = nil;
    NSPropertyListFormat format;
    NSData *plistXML = [ [NSFileManager defaultManager] contentsAtPath: path];
    
    NSMutableDictionary *result = (NSMutableDictionary *) [NSPropertyListSerialization propertyListFromData: plistXML
                mutabilityOption:
                NSPropertyListMutableContainersAndLeaves
                format: &format
                errorDescription: &error];
    if (error != nil) {
        NSLog(@"Error while reading plist: %@", error);
    }
    return result;
}

- (void) saveDictionary: (NSMutableDictionary *) dictionary toPropertyListAtPath: (NSString *) path {
    NSString *error = nil;
    
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList: dictionary
                        format: NSPropertyListXMLFormat_v1_0
                        errorDescription: &error];
    
    if (plistData != nil) {
        [plistData writeToFile: path atomically: YES];
    } else {
        NSLog(@"Error while writing plist: %@", error);
    }
}

-(NSString*) getPath {
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory =  [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"historicalData.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath: path])
    {
        NSString *bundle =[[NSBundle mainBundle] pathForResource:@"historicalData" ofType:@"plist"];
        
        [fileManager copyItemAtPath:bundle toPath: path error:&error];
    }
    return path;
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
