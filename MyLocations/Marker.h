//
//  Marker.h
//  MyLocations
//
//  Created by Lien Nguyen on 12/7/13.
//  Copyright (c) 2013 Lienne Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Marker : NSManagedObject

@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSDate * date;

@end
