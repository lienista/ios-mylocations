//
//  LocationCell.h
//  MyLocations
//
//  Created by Lienne Nguyen on 11/27/13.
//  Copyright (c) 2013 Lienne Nguyen. All rights reserved.
//
//heheh

@interface LocationCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

@end

