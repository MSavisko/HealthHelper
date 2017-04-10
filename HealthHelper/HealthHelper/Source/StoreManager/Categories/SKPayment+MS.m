//
//  SKPayment+MS.m
//  HealthHelper
//
//  Created by Maksym Savisko on 4/10/17.
//  Copyright © 2017 Maksym Savisko. All rights reserved.
//

#import "SKPayment+MS.h"

@implementation SKPayment (MS)

- (NSString *)ms_detailedDescription
{
    return [NSString stringWithFormat:@"%@ x%@", self.productIdentifier, @(self.quantity)];
}

@end
