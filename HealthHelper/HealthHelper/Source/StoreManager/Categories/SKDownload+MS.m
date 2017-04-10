//
//  SKDownload+MS.m
//  HealthHelper
//
//  Created by Maksym Savisko on 4/10/17.
//  Copyright © 2017 Maksym Savisko. All rights reserved.
//

#import "SKDownload+MS.h"

@implementation SKDownload (MS)

- (BOOL)isDownloading
{
    SKDownloadState state = self.downloadState;
    
    return state != SKDownloadStateCancelled && state != SKDownloadStateFailed &&  state != SKDownloadStateFinished;
}

+ (NSString *)ms_stringFromDownloadState:(SKDownloadState)state
{
    switch (state)
    {
        case SKDownloadStateActive: return @"Active";
        case SKDownloadStateFailed: return @"Failed";
        case SKDownloadStatePaused: return @"Paused";
        case SKDownloadStateWaiting: return @"Waiting";
        case SKDownloadStateFinished: return @"Finished";
        case SKDownloadStateCancelled: return @"Cancelled";
    }
    
    return @"Unknown";
}

- (NSString *)ms_detailedDescription
{
    NSString *stateString = [self.class ms_stringFromDownloadState:self.downloadState];
    
    NSMutableArray *components = [NSMutableArray arrayWithCapacity:0];
    
    if (self.transaction.payment.productIdentifier )
    {
        [components addObject:[NSString stringWithFormat:@"Product Identifier - %@", self.transaction.payment.productIdentifier]];
    }
    
    if (stateString )
    {
        [components addObject:[NSString stringWithFormat:@"State - %@", stateString]];
    }
    
    [components addObject:[NSString stringWithFormat:@"Progress - %@", @(self.progress * 100)]];
    [components addObject:[NSString stringWithFormat:@"Time Remaining - %@", @(self.timeRemaining)]];
    
    if (self.contentIdentifier )
    {
        [components addObject:[NSString stringWithFormat:@"Content Identifier - %@", self.contentIdentifier]];
    }
    
    if (self.contentURL )
    {
        [components addObject:[NSString stringWithFormat:@"Content URL - %@", self.contentURL]];
    }
    
    if (self.contentVersion )
    {
        [components addObject:[NSString stringWithFormat:@"Content verison - %@", self.contentVersion]];
    }
    
    if ( self.error )
    {
        [components addObject:[NSString stringWithFormat:@"Error - %@", self.error]];
    }
    
    return [components componentsJoinedByString:@"\n"];
}

@end
