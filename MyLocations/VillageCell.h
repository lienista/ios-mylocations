//
//  VillageCell.h
//  MyLocations
//
//  Created by Esther Resendiz on 12/7/13.
//  Copyright (c) 2013 Lienne Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VillageCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

@end
