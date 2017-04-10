//
//  MSProductStatus.m
//  HealthHelper
//
//  Created by Maksym Savisko on 4/10/17.
//  Copyright © 2017 Maksym Savisko. All rights reserved.
//

#import "MSProductStatus.h"
#import "SKProduct+MS.h"
#import "SKPaymentTransaction+MS.h"

@import StoreKit;

@implementation MSProductStatus


#pragma mark - Inits

+ (instancetype)productStatusForProduct:(SKProduct *)product
{
    return [[self alloc] initWithProductId:product.productIdentifier product:product];
}

+ (instancetype)productStatusForProductWithId:(NSString *)productId
{
    return [[self alloc] initWithProductId:productId product:nil];
}

- (instancetype)initWithProductId:(NSString *)productId product:(nullable SKProduct *)product
{
    self = [super init];
    
    if ( self )
    {
        _productId = [productId copy];
        _state = MSProductStateIndeterminate;
        _percentDownloaded = 0.f;
        _product = product;
        _error = nil;
    }
    
    return self;
}


#pragma mark - Setters

- (void)setPercentDownloaded:(CGFloat)percentDownloaded
{
    _percentDownloaded = percentDownloaded;
}


#pragma mark - Updating

- (void)updateWithState:(MSProductState)state
{
    [self updateWithState:state error:nil];
}

- (void)updateWithState:(MSProductState)state error:(NSError *)error
{
    if ( _state == state && state != MSProductStateDownloading && !_error && !error )
    {
        return;
    }
    
    _state = state;
    _error = error;
    
    [self invokeStateChangeHandler];
}

- (void)updateWithProduct:(SKProduct *)product
{
    _product = product;
    
    if ( !_product )
    {
        [self updateWithState:MSProductStateFailed];
    }
    else
    {
        [self updateWithState:MSProductStateLoaded];
    }
}

- (void)updateWithDownload:(SKDownload *)download
{
    if ( ![download.contentIdentifier isEqualToString:_productId] )
    {
        return;
    }
    
    _percentDownloaded = download.progress;
    _timeRemaining = download.timeRemaining;
    
    switch (download.downloadState)
    {
        case SKDownloadStateWaiting: {
            
            [self updateWithState:MSProductStateIndeterminate];
            break;
        }
        case SKDownloadStateActive: {
            
            [self updateWithState:MSProductStateDownloading];
            break;
        }
        case SKDownloadStatePaused: {
            
            [self updateWithState:MSProductStatePaused];
            break;
        }
        case SKDownloadStateFinished: {
            
            [self updateWithState:MSProductStateIndeterminate];
            break;
        }
        case SKDownloadStateFailed: {
            
            [self updateWithState:MSProductStateFailed error:download.error];
            break;
        }
        case SKDownloadStateCancelled: {
            
            [self updateWithState:MSProductStateCancelled];
            break;
        }
    }
}

- (void)updateWithTransaction:(SKPaymentTransaction *)transaction
{
    if ( ![transaction.payment.productIdentifier isEqualToString:_productId] )
    {
        return;
    }
    
    switch (transaction.transactionState)
    {
        case SKPaymentTransactionStatePurchasing: {
            
            [self updateWithState:MSProductStateIndeterminate];
            break;
        }
        case SKPaymentTransactionStateRestored:
        case SKPaymentTransactionStatePurchased: {
            
            [self updateWithState:[transaction ms_hasPendingDownloads]? MSProductStateIndeterminate : MSProductStateFinished];
            break;
        }
        case SKPaymentTransactionStateFailed: {
            
            [self updateWithState:MSProductStateFailed error:transaction.error];
            break;
        }
            
        case SKPaymentTransactionStateDeferred: {
            
            [self updateWithState:MSProductStateLoaded];
            break;
        }
    }
}

- (void)invokeStateChangeHandler
{
    if ( _changeHandler )
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            _changeHandler([self copy]);
        });
    }
}


#pragma mark - NSObject

- (NSString *)description
{
    NSMutableArray *components = [NSMutableArray arrayWithCapacity:0];
    
    if ( _product )
    {
        [components addObject:_product.ms_detailedDescription];
    }
    else
    {
        [components addObject:[NSString stringWithFormat:@"ProductId - %@", _productId]];
    }
    
    NSString *stateString = nil;
    
    switch (_state) {
        case MSProductStateIndeterminate: {
            stateString = @"Indeterminate";
            break;
        }
        case MSProductStateLoaded: {
            stateString = @"Loaded";
            break;
        }
        case MSProductStateFailed: {
            stateString = @"Failed";
            break;
        }
        case MSProductStateDownloading: {
            stateString = @"Downloading";
            break;
        }
        case MSProductStateFinished: {
            stateString = @"Finished";
            break;
        }
        case MSProductStateCancelled: {
            stateString = @"Cancelled";
            break;
        }
        case MSProductStatePaused: {
            stateString = @"Paused";
            break;
        }
    }
    
    [components addObject:[NSString stringWithFormat:@"State - %@", stateString]];
    [components addObject:[NSString stringWithFormat:@"Percent Downloaded - %@", @(_percentDownloaded)]];
    
    if ( _error )
    {
        [components addObject:[NSString stringWithFormat:@"Error - %@", _error]];
    }
    
    return [components componentsJoinedByString:@"\n"];
}


#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    MSProductStatus *status = [[self.class allocWithZone:zone] initWithProductId:_productId product:_product];
    [status updateWithState:_state error:_error];
    status.percentDownloaded = _percentDownloaded;
    
    return status;
}


@end

