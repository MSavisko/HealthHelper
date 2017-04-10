//
//  SKProduct+MS.m
//  HealthHelper
//
//  Created by Maksym Savisko on 4/10/17.
//  Copyright © 2017 Maksym Savisko. All rights reserved.
//

#import "SKProduct+MS.h"

@implementation SKProduct (MS)

- (NSString *)ms_detailedDescription
{
    NSMutableArray *components = [NSMutableArray arrayWithCapacity:0];
    
    [components addObject:[NSString stringWithFormat:@"Product Identifier - %@", self.productIdentifier]];
    [components addObject:[NSString stringWithFormat:@"Title - %@", self.localizedTitle]];
    [components addObject:[NSString stringWithFormat:@"Description - %@", self.localizedDescription]];
    [components addObject:[NSString stringWithFormat:@"Price - %@", self.price]];
    [components addObject:[NSString stringWithFormat:@"Price Locale - %@", self.priceLocale.localeIdentifier]];
    [components addObject:[NSString stringWithFormat:@"Downloadable - %@", self.downloadable? @"YES" : @"NO"]];
    [components addObject:[NSString stringWithFormat:@"Download Content Version - %@", self.downloadContentVersion]];
    
    return [components componentsJoinedByString:@"\n"];
}


@end
