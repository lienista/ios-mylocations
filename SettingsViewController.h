//
//  SettingsViewController.h
//  MyLocations
//
//  Created by Lien Nguyen on 12/7/13.
//  Copyright (c) 2013 Lienne Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UITableViewController <CLLocationManagerDelegate>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (IBAction)autoMapNow;

@end
