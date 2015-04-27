//
//  SaveCellsViewController.m
//  Weed Genie
//
//  Created by Ryan Nichols on 4/25/15.
//  Copyright (c) 2015 Ran0005. All rights reserved.
//

#import "SaveCellsViewController.h"

@interface SaveCellsViewController ()
@property (copy, nonatomic) NSArray *plants;
@property (retain, nonatomic) NSMutableDictionary *notifyOfPlants;
@end

@implementation SaveCellsViewController

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
    self.notifyOfPlants = [[NSMutableDictionary alloc]initWithDictionary:[self dictionaryWithPropertyListAtPath:[self getPath]]];
    if(!self.notifyOfPlants) {
        self.notifyOfPlants = [[NSMutableDictionary alloc] init];
    }
    
    
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
    NSString * simpleTableIdentifier = @"simple";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    if ([self.notifyOfPlants objectForKey:[self.plants objectAtIndex:indexPath.row]]) {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    cell.textLabel.text = [self.plants objectAtIndex:indexPath.row];
    return cell;
}

-(NSString*) getPath {
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory =  [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"plantsToNotify.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath: path])
    {
        NSString *bundle =[[NSBundle mainBundle] pathForResource:@"plantsToNotify" ofType:@"plist"];
        
        [fileManager copyItemAtPath:bundle toPath: path error:&error];
    }
    return path;
}

- (NSMutableDictionary*) readDataFromPlist {
    NSMutableDictionary *plistData;
    NSString *path = [self getPath];
    plistData = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    
    return plistData;
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *selectedCell= (UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    NSString *message = @"Would you like to unfollow alerts about ";
    [message stringByAppendingString:[self.plants objectAtIndex:indexPath.row]];
    [message stringByAppendingString:@"?"];
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:message
                                  message:@""
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"Yes"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             selectedCell.accessoryType = UITableViewCellAccessoryNone;
                             [self.notifyOfPlants removeObjectForKey:[self.plants objectAtIndex:indexPath.row]];
                             [self saveDictionary:self.notifyOfPlants toPropertyListAtPath:[self getPath]];
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    UITableViewCell *selectedCell= (UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    selectedCell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSString *message = @"Would you like to recieve alerts about ";
    message = [message stringByAppendingString:[self.plants objectAtIndex:indexPath.row]];
    message = [message stringByAppendingString:@"?"];
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:message
                                  message:@""
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"Yes"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
                             [self.notifyOfPlants setObject:[self.plants objectAtIndex:indexPath.row] forKey:[self.plants objectAtIndex:indexPath.row]];
                             [self saveDictionary:self.notifyOfPlants toPropertyListAtPath:[self getPath]];
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [tableView deselectRowAtIndexPath:indexPath animated:YES];
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
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
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}



@end
