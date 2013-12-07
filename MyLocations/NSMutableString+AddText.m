//
//  NSMutableString+AddText.m
//  MyLocations
//
//  Created by Lienne Nguyen on 12/2/13.
//  Copyright (c) 2013 Lienne Nguyen. All rights reserved.
//

#import "NSMutableString+AddText.h"

@implementation NSMutableString (AddText)

- (void)addText:(NSString *)text withSeparator:(NSString *)separator
{
    if (text != nil) {
        if ([self length] > 0) {
            [self appendString:separator];
        }
        [self appendString:text];
    }
}

@end
