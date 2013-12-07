//
//  HudView.h
//  MyLocations
//
//  Created by Lienne Nguyen on 11/26/13.
//  Copyright (c) 2013 Lienne Nguyen. All rights reserved.
//

@interface HudView : UIView

+ (instancetype)hudInView:(UIView *)view animated:(BOOL)animated;

@property (nonatomic, strong) NSString *text;

@end
