//
//  MSStoreAppReceiptVerifier.m
//  HealthHelper
//
//  Created by Maksym Savisko on 4/10/17.
//  Copyright © 2017 Maksym Savisko. All rights reserved.
//

#import "MSStoreAppReceiptVerifier.h"
#import "RMAppReceipt.h"

@implementation MSStoreAppReceiptVerifier

@synthesize bundleVersion = _bundleVersion, bundleIdentifier = _bundleIdentifier;

- (void)verifyTransaction:(SKPaymentTransaction*)transaction
                  success:(void (^)())successBlock
                  failure:(void (^)(NSError *error))failureBlock
{
    RMAppReceipt *receipt = [RMAppReceipt bundleReceipt];
    const BOOL verified = [self verifyTransaction:transaction inReceipt:receipt success:successBlock failure:nil]; // failureBlock is nil intentionally. See below.
    if (verified) return;
    
    // Apple recommends to refresh the receipt if validation fails on iOS
    [[RMStore defaultStore] refreshReceiptOnSuccess:^{
        RMAppReceipt *receipt = [RMAppReceipt bundleReceipt];
        [self verifyTransaction:transaction inReceipt:receipt success:successBlock failure:failureBlock];
    } failure:^(NSError *error) {
        [self failWithBlock:failureBlock error:error];
    }];
}

- (BOOL)verifyAppReceipt
{
    RMAppReceipt *receipt = [RMAppReceipt bundleReceipt];
    return [self verifyAppReceipt:receipt];
}

#pragma mark - Properties

- (NSString*)bundleIdentifier
{
    if (!_bundleIdentifier)
    {
        return [NSBundle mainBundle].bundleIdentifier;
    }
    return _bundleIdentifier;
}

- (NSString*)bundleVersion
{
    if (!_bundleVersion)
    {
#if TARGET_OS_IPHONE
        return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
#else
        return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
#endif
    }
    return _bundleVersion;
}

#pragma mark - Private

- (BOOL)verifyAppReceipt:(RMAppReceipt*)receipt
{
    if (!receipt) return NO;
    
    if (![receipt.bundleIdentifier isEqualToString:self.bundleIdentifier]) return NO;
    
    if (![receipt.appVersion isEqualToString:self.bundleVersion]) return NO;
    
    if (![receipt verifyReceiptHash]) return NO;
    
    return YES;
}

- (BOOL)verifyTransaction:(SKPaymentTransaction*)transaction
                inReceipt:(RMAppReceipt*)receipt
                  success:(void (^)())successBlock
                  failure:(void (^)(NSError *error))failureBlock
{
    const BOOL receiptVerified = [self verifyAppReceipt:receipt];
    if (!receiptVerified)
    {
        [self failWithBlock:failureBlock message:NSLocalizedStringFromTable(@"The app receipt failed verification", @"RMStore", nil)];
        return NO;
    }
    SKPayment *payment = transaction.payment;
    const BOOL transactionVerified = [receipt containsInAppPurchaseOfProductIdentifier:payment.productIdentifier];
    if (!transactionVerified)
    {
        [self failWithBlock:failureBlock message:NSLocalizedStringFromTable(@"The app receipt does not contain the given product", @"RMStore", nil)];
        return NO;
    }
    if (successBlock)
    {
        successBlock();
    }
    return YES;
}

- (void)failWithBlock:(void (^)(NSError *error))failureBlock message:(NSString*)message
{
    NSError *error = [NSError errorWithDomain:RMStoreErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : message}];
    [self failWithBlock:failureBlock error:error];
}

- (void)failWithBlock:(void (^)(NSError *error))failureBlock error:(NSError*)error
{
    if (failureBlock)
    {
        failureBlock(error);
    }
}

@end

