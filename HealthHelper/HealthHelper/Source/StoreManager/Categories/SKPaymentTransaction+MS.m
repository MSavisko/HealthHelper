//
//  SKPaymentTransaction+MS.m
//  HealthHelper
//
//  Created by Maksym Savisko on 4/10/17.
//  Copyright © 2017 Maksym Savisko. All rights reserved.
//

#import "SKPaymentTransaction+MS.h"
#import "SKPayment+MS.h"
#import "SKDownload+MS.h"

@implementation SKPaymentTransaction (MS)

- (BOOL)ms_hasPendingDownloads
{
    for (SKDownload *download in self.downloads)
    {
        switch (download.downloadState)
        {
            case SKDownloadStateActive:
            case SKDownloadStatePaused:
            case SKDownloadStateWaiting:
                return YES;
                
            case SKDownloadStateCancelled:
            case SKDownloadStateFailed:
            case SKDownloadStateFinished:
                continue;
        }
    }
    
    return NO;
}

+ (NSString *)ms_stringFromTransactionState:(SKPaymentTransactionState)state
{
    switch (state)
    {
        case SKPaymentTransactionStatePurchasing: return @"Purchasing";
        case SKPaymentTransactionStatePurchased: return @"Purchased";
        case SKPaymentTransactionStateFailed: return @"Failed";
        case SKPaymentTransactionStateRestored: return @"Restored";
        case SKPaymentTransactionStateDeferred: return @"Deferred";
    }
    
    return @"Unknown";
}

- (NSString *)ms_detailedDescription
{
    static NSString *const PVSeparator = @"\n";
    
    NSString *stateString = [self.class ms_stringFromTransactionState:self.transactionState];
    
    NSMutableArray *components = [NSMutableArray arrayWithCapacity:0];
    
    if (self.transactionIdentifier )
    {
        [components addObject:[NSString stringWithFormat:@"Transaction Identifier - %@", self.transactionIdentifier]];
    }
    
    if (stateString )
    {
        [components addObject:[NSString stringWithFormat:@"State - %@", stateString]];
    }
    
    NSString *paymentDescription = self.payment.ms_detailedDescription;
    
    if (paymentDescription )
    {
        [components addObject:[NSString stringWithFormat:@"Payment - %@", paymentDescription]];
    }
    
    NSString *originalTransaction = self.originalTransaction.ms_detailedDescription;
    
    if (originalTransaction )
    {
        [components addObject:[NSString stringWithFormat:@"Original Transaction - %@", originalTransaction]];
    }
    
    if ( self.downloads.count )
    {
        [components addObject:@"Downloads"];
        
        NSMutableArray *downloadsDescription = [NSMutableArray arrayWithCapacity:0];
        
        [self.downloads enumerateObjectsUsingBlock:^(SKDownload * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            [downloadsDescription addObject:obj.ms_detailedDescription];
        }];
        
        [components addObject:[downloadsDescription componentsJoinedByString:PVSeparator]];
    }
    
    if ( self.transactionDate )
    {
        [components addObject:[NSString stringWithFormat:@"Date - %@", self.transactionDate]];
    }
    
    if ( self.error )
    {
        [components addObject:[NSString stringWithFormat:@"Error - %@", self.error]];
    }
    
    
    return [components componentsJoinedByString:PVSeparator];
}


@end
