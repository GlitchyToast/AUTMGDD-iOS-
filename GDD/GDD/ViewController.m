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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        [self performSegueWithIdentifier:@"toDate" sender:sender];
    }];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"toDate"] )
    {
        DateViewController *dateView = (DateViewController *)[segue destinationViewController];
        dateView.lat = self.lat;
        dateView.lon = self.lon;
        //dateView.zip = self.zipCode.text;
    }
    
}


@end
