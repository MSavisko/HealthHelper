//
//  MSProductStatus.h
//  HealthHelper
//
//  Created by Maksym Savisko on 4/10/17.
//  Copyright © 2017 Maksym Savisko. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

typedef NS_ENUM(NSInteger, MSProductState){
    
    MSProductStateIndeterminate = 0,
    MSProductStateLoaded,
    MSProductStateFailed,
    MSProductStateDownloading,
    MSProductStatePaused,
    MSProductStateCancelled,
    MSProductStateFinished
};

@class SKProduct, SKDownload, SKPaymentTransaction, MSProductStatus;

NS_ASSUME_NONNULL_BEGIN

typedef void (^MSProductStatusDidChangeBlock)(MSProductStatus *currentStatus);

@interface MSProductStatus : NSObject <NSCopying>

@property (nonatomic, assign, readonly) MSProductState state;
@property (nonatomic, copy, readonly) NSString *productId;
@property (nonatomic, readonly) CGFloat percentDownloaded;
@property (nonatomic, strong, nullable, readonly) SKProduct *product;
@property (nonatomic, strong, nullable, readonly) NSError *error;
@property (nonatomic, copy, nullable) MSProductStatusDidChangeBlock changeHandler;
@property (nonatomic, readonly) NSTimeInterval timeRemaining;

+ (instancetype)productStatusForProduct:(SKProduct *)product;
+ (instancetype)productStatusForProductWithId:(NSString *)productId;

- (void)updateWithProduct:(nullable SKProduct *)product;
- (void)updateWithDownload:(SKDownload *)download;
- (void)updateWithTransaction:(SKPaymentTransaction *)transaction;
- (void)updateWithState:(MSProductState)state error:(nullable NSError *)error;

@end

NS_ASSUME_NONNULL_END

