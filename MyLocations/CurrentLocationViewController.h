//
//  CurrentLocationViewController.h
//  MyLocations
//
//  Created by Lienne Nguyen on 11/21/13.
//  Copyright (c) 2013 Lienne Nguyen. All rights reserved.
//

@interface CurrentLocationViewController : UIViewController <CLLocationManagerDelegate>

@property (nonatomic, weak) IBOutlet UILabel *messageLabel;
@property (nonatomic, weak) IBOutlet UILabel *latitudeLabel;
@property (nonatomic, weak) IBOutlet UILabel *longitudeLabel;
@property (nonatomic, weak) IBOutlet UILabel *addressLabel;
@property (nonatomic, weak) IBOutlet UIButton *tagButton;
@property (nonatomic, weak) IBOutlet UIButton *getButton;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, weak) IBOutlet UILabel *latitudeTextLabel;
@property (nonatomic, weak) IBOutlet UILabel *longitudeTextLabel;
@property (nonatomic, weak) IBOutlet UIView *containerView;

- (IBAction)getLocation:(id)sender;


@end
