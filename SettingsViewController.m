//
//  SettingsViewController.m
//  MyLocations
//
//  Created by Lien Nguyen on 12/7/13.
//  Copyright (c) 2013 Lienne Nguyen. All rights reserved.
//

#import "SettingsViewController.h"
#import "Marker.h"

@interface SettingsViewController ()
{
    NSTimer *_autoTimer;
}
@property (weak, nonatomic) IBOutlet UISwitch *AutoMapOn;
@end



@implementation SettingsViewController
{
    CLLocationManager *_locationManager;
    CLLocation *_location;
    NSDate *_date;
    
    
    BOOL _updatingLocation;
    NSError *_lastLocationError;

}

- (void) showAlert:(id)obj {
    //Marker *marker = nil;
    
    // actually, create a pin in CoreData!!!!!!!!!
    
    if (self.managedObjectContext == nil)
    {
        NSLog(@"Ruh Roh Marker Nil");
    } else
    {
        NSLog(@"Not nil-what gives?");
    }
    [self startLocationManager];
    
    /*if (_updatingLocation) {
        [self stopLocationManager];
    } else {
        _location = nil;
        _lastLocationError = nil;
        [self startLocationManager];
    }*/

    //marker = [NSEntityDescription insertNewObjectForEntityForName:@"Marker" inManagedObjectContext:self.managedObjectContext];
    
    //self.coordinate = CLLocationCoordinate2DMake( [_locationToEdit.latitude doubleValue], [_locationToEdit.longitude doubleValue]);
    
    _date = [NSDate date];
    
    //marker.latitude = @(self.coordinate.latitude);
    //marker.longitude = @(self.coordinate.longitude);

    
    //marker.date = _date;
    
    //double temp_lat = [_location.coordinate.latitude doubleValue];
    //double temp_long = _location.coordinate.longitude;
    //[NSString stringWithFormat:@"%f,%f", _location.coordinate.latitude,
    //_location.coordinate.longitude]

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location Captured"
                                                    message:@""
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss"otherButtonTitles:nil];
    [alertView show];
    
}
- (IBAction)autoMapNow {
    if (_AutoMapOn.on)
    {
        
        // drop a pin every 5 seconds!!
        
        _autoTimer = [NSTimer scheduledTimerWithTimeInterval:10.0
                                         target:self
                                       selector:@selector(showAlert:)
                                       userInfo:nil
                                        repeats:YES];
        
    } else {
        [_autoTimer invalidate];
        _autoTimer = nil;
    }
}




- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError %@", error);
    
    if (error.code == kCLErrorLocationUnknown) {
        return;
    }
    
    [self stopLocationManager];
    _lastLocationError = error;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = [locations lastObject];
    NSLog(@"didUpdateLocations %@", newLocation);
    
    
    if ([newLocation.timestamp timeIntervalSinceNow] < -5.0) {
        return;
    }
    if (newLocation.horizontalAccuracy < 0) {
        return;
    }
    
    CLLocationDistance distance = MAXFLOAT;
    if (_location != nil) {
        distance = [newLocation distanceFromLocation:_location];
    }
    
    if (_location == nil || _location.horizontalAccuracy > newLocation.horizontalAccuracy) {
        _lastLocationError = nil;
        _location = newLocation;
        
        if (newLocation.horizontalAccuracy <= _locationManager.desiredAccuracy) {
            NSLog(@"*** We're done!");
            [self stopLocationManager];
        }
        
    } else if (distance < 1.0) {
        NSTimeInterval timeInterval = [newLocation.timestamp timeIntervalSinceDate:_location.timestamp];
        if (timeInterval > 10) {
            NSLog(@"*** Force done!");
            [self stopLocationManager];
            // Esther - Temp hack!
            //[self updateLabels];
            //[self configureGetButton];
        }
    }
}

- (void)startLocationManager {
    if ([CLLocationManager locationServicesEnabled]) {
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters; [_locationManager startUpdatingLocation];
        _updatingLocation = YES;
        
        [self performSelector:@selector(didTimeOut:) withObject:nil afterDelay:60];
    }
}

- (void)stopLocationManager {
    if (_updatingLocation) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(didTimeOut:) object:nil];
        
        [_locationManager stopUpdatingLocation];
        _locationManager.delegate = nil;
        _updatingLocation = NO;
    }
}

- (void)didTimeOut:(id)obj {
    NSLog(@"*** Time out");
    if (_location == nil) {
        [self stopLocationManager];
        _lastLocationError = [NSError errorWithDomain: @"MyLocationsErrorDomain" code:1 userInfo:nil];
    }
}






#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0)
    {
        return 2;
    } else if (section == 1)
    {
        return 2;
    } else if (section == 2)
    {
        return 3;
    }
    return 0;
}

/*- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
