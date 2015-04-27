//
//  ViewController.m
//  GDD
//
//  Created by Ryan Nichols on 1/27/15.
//  Copyright (c) 2015 Ran0005. All rights reserved.
//

#import "ViewController.h"
#import "PlantsViewController.h"
#import "DateViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *zipCode;
@property (weak, nonatomic) IBOutlet UIButton *submitZip;
@property (nonatomic) double lat;
@property (nonatomic) double lon;
@property (retain, nonatomic) NSMutableDictionary *zip;
- (IBAction)saveZipCode:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *zipCodeSwitch;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:255.0/256 green:153.0/256 blue:51.0/256 alpha:1];
    self.zip = [[NSMutableDictionary alloc]initWithDictionary:[self dictionaryWithPropertyListAtPath:[self getPath]]];
    [self.zipCodeSwitch setOn:false];
    if(!self.zip) {
        self.zip = [[NSMutableDictionary alloc] init];
    }
    if([self.zip objectForKey:@"zip"] != nil) {
        self.zipCode.text = [self.zip objectForKey:@"zip"];
        [self.zipCodeSwitch setOn:true];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.zipCode resignFirstResponder];
}
- (IBAction)getLatLong:(id)sender {
    if (!self.geocoder) {
        self.geocoder = [[CLGeocoder alloc] init];
    }
    
    NSString *address = [NSString stringWithFormat:@"%@", self.zipCode.text];
    
    [self.geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error) {
        if ([placemarks count] > 0) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            CLLocation *location = placemark.location;
            CLLocationCoordinate2D coordinate = location.coordinate;
            NSLog(@"Lat,Long: %f,%f",coordinate.latitude, coordinate.longitude);
            self.lat = coordinate.latitude;
            self.lon = coordinate.longitude;
        }
        DateViewController *dateView;
        dateView.lat = self.lat;
        dateView.lon = self.lon;
        if ([self.zipCode.text  isEqual: @""])
        {
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Error"
                                          message:@"Invalid zip code."
                                          preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* cancel = [UIAlertAction
                                     actionWithTitle:@"Cancel"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                         
                                     }];
            [alert addAction:cancel];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else {
            [self saveZipCode:self];
            [self performSegueWithIdentifier:@"toDate" sender:sender];
        }
    }];
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"toDate"] )
    {
        DateViewController *dateView = (DateViewController *)[segue destinationViewController];
        dateView.lat = self.lat;
        dateView.lon = self.lon;
    }
}

- (NSMutableDictionary*) dictionaryWithPropertyListAtPath: (NSString *) path {
    NSError *error = nil;
    NSPropertyListFormat format;
    NSData *plistXML = [ [NSFileManager defaultManager] contentsAtPath: path];
    
    NSMutableDictionary *result = [NSPropertyListSerialization propertyListWithData:plistXML options:NSPropertyListMutableContainersAndLeaves format:&format error:&error];
    if (error != nil) {
        NSLog(@"Error while reading plist: %@", error);
    }
    return result;
}

- (void) saveDictionary: (NSMutableDictionary *) dictionary toPropertyListAtPath: (NSString *) path {
    NSError *error = nil;
    
    NSData *plistData = [NSPropertyListSerialization dataWithPropertyList:dictionary format:NSPropertyListXMLFormat_v1_0 options: NSPropertyListMutableContainersAndLeaves error:&error];
    
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
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"zipCode.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath: path])
    {
        NSString *bundle =[[NSBundle mainBundle] pathForResource:@"zipCode" ofType:@"plist"];
        
        [fileManager copyItemAtPath:bundle toPath: path error:&error];
    }
    return path;
}

- (IBAction)saveZipCode:(id)sender {
    if (self.zipCodeSwitch.on) {
        if ([self.zipCode.text length] > 0) {
            [self.zip setObject:self.zipCode.text forKey:@"zip"];
            [self saveDictionary:self.zip toPropertyListAtPath:[self getPath]];
        }
    }
    
    else if (!self.zipCodeSwitch.on) {
        [self.zip removeObjectForKey:@"zip"];
        [self saveDictionary:self.zip toPropertyListAtPath:[self getPath]];
    }
    
}
@end
