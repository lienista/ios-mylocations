//
//  MapViewController.m
//  MyLocations
//
//  Created by Lienne Nguyen on 11/28/13.
//  Copyright (c) 2013 Lienne Nguyen. All rights reserved.
//

#import "MapViewController.h"
#import "Location.h"
#import "LocationDetailsViewController.h"
#import "Village.h"
#import "VillageDetailsViewController.h"


@interface MapViewController () <MKMapViewDelegate, UINavigationBarDelegate>

@property (strong, nonatomic) IBOutlet UITextField *searchText;
@property (strong, nonatomic) NSMutableArray *matchingItems;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) IBOutlet UITextField *newcoordinate;

- (IBAction)textFieldReturn:(id)sender;
@end

@implementation MapViewController
{
    NSArray *_locations;
    NSArray *_villages;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contextDidChange:)
                                                     name:NSManagedObjectContextObjectsDidChangeNotification
                                                   object:self.managedObjectContext];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)showUser
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 20000, 20000);
    
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
}

- (IBAction)showLocations
{
    MKCoordinateRegion region = [self regionForAnnotations:_locations withVillages:_villages];
    [self.mapView setRegion:region animated:YES];

}



- (void)updateLocations
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:self.managedObjectContext]; NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *foundObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (foundObjects == nil) {
        FATAL_CORE_DATA_ERROR(error);
        return;
    }
    if (_locations != nil) {
        [self.mapView removeAnnotations:_locations];
    }
    _locations = foundObjects;
    [self.mapView addAnnotations:_locations];
    
    NSEntityDescription *entity_village = [NSEntityDescription entityForName:@"Village" inManagedObjectContext:self.managedObjectContext]; NSFetchRequest *fetchRequestVillage = [[NSFetchRequest alloc] init];
    [fetchRequestVillage setEntity:entity_village];
    
    NSError *error_village;
    NSArray *foundVillageObjects = [self.managedObjectContext executeFetchRequest:fetchRequestVillage error:&error_village];
    
    if (foundVillageObjects == nil) {
        FATAL_CORE_DATA_ERROR(error_village);
        return;
    }
    if (_villages != nil) {
        [self.mapView removeAnnotations:_villages];
    }
    _villages = foundVillageObjects;
    [self.mapView addAnnotations:_villages];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateLocations];

    if ([_locations count] > 0 || [_villages count] > 0) {
        [self showLocations];
    }
}

- (MKCoordinateRegion)regionForAnnotations:(NSArray *)annotations withVillages:(NSArray *)villages
{
    MKCoordinateRegion region;
    
    if ([annotations count] == 0) {
        region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 20000, 20000);
        
    } else if ([annotations count] == 1) {
        id <MKAnnotation> annotation = [annotations lastObject];
        region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 20000, 20000);
        
    } else {
        CLLocationCoordinate2D topLeftCoord;
        topLeftCoord.latitude = -90;
        topLeftCoord.longitude = 180;
        
        CLLocationCoordinate2D bottomRightCoord;
        bottomRightCoord.latitude = 90;
        bottomRightCoord.longitude = -180;
        
        for (id <MKAnnotation> annotation in annotations) {
            topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
            topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
            bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
            bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        }
        
        const double extraSpace = 1.1;
        region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) / 2.0;
        region.center.longitude = topLeftCoord.longitude - (topLeftCoord.longitude - bottomRightCoord.longitude) / 2.0;
        region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * extraSpace;
        region.span.longitudeDelta = fabs(topLeftCoord.longitude - bottomRightCoord.longitude) * extraSpace;
    }
    
    return [self.mapView regionThatFits:region];
}

#pragma mark - MKMapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // 1
    if ([annotation isKindOfClass:[Location class]]) {
        // 2
        static NSString *identifier = @"Location";
        MKPinAnnotationView *annotationView =
        (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc]
                              initWithAnnotation:annotation reuseIdentifier:identifier];
            // 3
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
            annotationView.animatesDrop = NO;
            annotationView.pinColor = MKPinAnnotationColorGreen;
            annotationView.tintColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
            
            // 4
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [rightButton addTarget:self
                            action:@selector(showLocationDetails:)
                  forControlEvents:UIControlEventTouchUpInside];
            annotationView.rightCalloutAccessoryView = rightButton;
        } else {
            annotationView.annotation = annotation;
        }
        // 5
        UIButton *button = (UIButton *)annotationView.rightCalloutAccessoryView;
        button.tag = [_locations indexOfObject:(Location *)annotation];
        
        return annotationView;
    } else if ([annotation isKindOfClass:[Village class]]) {
        // 2
        static NSString *identifier = @"Village";
        MKPinAnnotationView *annotationView =
        (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc]
                              initWithAnnotation:annotation reuseIdentifier:identifier];
            // 3
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
            annotationView.animatesDrop = NO;
            annotationView.pinColor = MKPinAnnotationColorRed;
            annotationView.tintColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
            
            // 4
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [rightButton addTarget:self
                            action:@selector(showVillageDetails:)
                  forControlEvents:UIControlEventTouchUpInside];
            annotationView.rightCalloutAccessoryView = rightButton;
        } else {
            annotationView.annotation = annotation;
        }
        // 5
        UIButton *button = (UIButton *)annotationView.rightCalloutAccessoryView;
        button.tag = [_villages indexOfObject:(Village *)annotation];
        
        return annotationView;
    }

    return nil;
}

- (void)showLocationDetails:(UIButton *)button
{
    [self performSegueWithIdentifier:@"EditLocation" sender:button];
}
- (void)showVillageDetails:(UIButton *)button
{
    [self performSegueWithIdentifier:@"EditVillage" sender:button];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EditLocation"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        
        LocationDetailsViewController *controller = (LocationDetailsViewController *) navigationController.topViewController;
        controller.managedObjectContext = self.managedObjectContext;
        
        UIButton *button = (UIButton *)sender;
        
        Location *location = _locations[button.tag];
        controller.locationToEdit = location;
    } else if ([segue.identifier isEqualToString:@"EditVillage"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        
        VillageDetailsViewController *controller = (VillageDetailsViewController *) navigationController.topViewController;
        controller.managedObjectContext = self.managedObjectContext;
        
        UIButton *button = (UIButton *)sender;
        
        Village *village = _villages[button.tag];
        controller.VillageToEdit = village;
    }

}

 - (void)contextDidChange:(NSNotification *)notification
{
    if ([self isViewLoaded]) {
        [self updateLocations];
    }
}

#pragma mark - UINavigationBarDelegate
- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

- (IBAction)textFieldReturn:(id)sender {
    [sender resignFirstResponder];
        // esther
    //[_mapView removeAnnotations:[_mapView annotations]];
    NSArray * annotations =[_mapView annotations];
    NSMutableArray * annotationsToRemove = [annotations mutableCopy ] ;
    for (id annotation in annotations)
    {
        if ([annotation isKindOfClass:[Location class]]) {
            [ annotationsToRemove removeObject:annotation];
        } else if ([annotation isKindOfClass:[Village class]]) {
            [ annotationsToRemove removeObject:annotation];
        }
    }
    [_mapView removeAnnotations:annotationsToRemove ] ;
    
    [self performSearch];
    
}

- (void) performSearch {
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = _searchText.text;
    request.region = _mapView.region;
    _matchingItems = [[NSMutableArray alloc] init];
    MKLocalSearch *search = [[MKLocalSearch alloc]initWithRequest:request];
    
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        if (response.mapItems.count == 0)
            NSLog(@"No Matches");
        else
            for (MKMapItem *item in response.mapItems) {
                [_matchingItems addObject:item];
                MKPointAnnotation *annotation = [[MKPointAnnotation alloc]init];
                annotation.coordinate = item.placemark.coordinate;
                annotation.title = item.name;
                [_mapView addAnnotation:annotation];
            } }];
}

- (IBAction)coordinateReturn:(id)sender {
    [sender resignFirstResponder];
    // esther
    //[_mapView removeAnnotations:[_mapView annotations]];
    NSArray * annotations =[_mapView annotations];
    NSMutableArray * annotationsToRemove = [annotations mutableCopy ] ;
    for (id annotation in annotations)
    {
        if ([annotation isKindOfClass:[Location class]]) {
            [ annotationsToRemove removeObject:annotation];
        } else if ([annotation isKindOfClass:[Village class]]) {
            [ annotationsToRemove removeObject:annotation];
        }
    }
    [_mapView removeAnnotations:annotationsToRemove ] ;

    [self coordinateSearch];
    
}

- (void) coordinateSearch {
    NSString *string = _newcoordinate.text;
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@","];
    NSMutableArray *coord = [[NSMutableArray alloc]initWithArray:[string componentsSeparatedByCharactersInSet:set]];
    
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [[coord objectAtIndex:0] floatValue];
    coordinate.longitude= [[coord objectAtIndex:1] floatValue];
    
    NSLog(@"%g, %g", coordinate.latitude, coordinate.longitude);
    
    
    MKCoordinateSpan span = {0.05, 0.05};
    MKCoordinateRegion region = {coordinate, span};
    [_mapView setRegion:region];
    
    MKPointAnnotation *annotationPoint2 = [[MKPointAnnotation alloc] init];
    
    annotationPoint2.coordinate = coordinate;
    annotationPoint2.title = @"Destination";
    annotationPoint2.subtitle = @"Your End Point";
    [_mapView addAnnotation:annotationPoint2];
    
}

@end