//
//  MSStoreManager.h
//  HealthHelper
//
//  Created by Maksym Savisko on 4/10/17.
//  Copyright © 2017 Maksym Savisko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSProductStatus.h"
#import <RMStore/RMStore.h>

@class SKProduct;

NS_ASSUME_NONNULL_BEGIN

typedef void (^MSStoreProductsFetchCompletionBlock)(NSArray<SKProduct *> *__nullable allProducts, NSError *__nullable error);
typedef void (^MSStoreProductsFetchCompletionBlock)(NSArray<SKProduct *> *__nullable allProducts, NSError *__nullable error);
typedef void (^MSStoreCompletionBlock)();

@interface MSStoreManager : NSObject

// clue for improper use (produces compile time error)
+ (instancetype)alloc __attribute__((unavailable("alloc not available, call sharedInstance instead")));
+ (instancetype)new __attribute__((unavailable("new not available, call sharedInstance instead")));
- (instancetype)init __attribute__((unavailable("init not available, call sharedInstance instead")));
- (instancetype)copy __attribute__((unavailable("copy not available, call sharedInstance instead")));

/**
 *  Creates and returns singleton instance
 *
 *  @return Singleton Instance of this class.
 */
+ (instancetype)sharedInstance;

+ (BOOL)canMakePayments;

- (void)initializeStore;
- (void)fetchProducts;
- (void)fetchProductsWithCompletion:(nullable MSStoreProductsFetchCompletionBlock)completion;
- (void)restoreTransactions;

- (void)addStoreObserver:(__kindof NSObject<RMStoreObserver> *)observer;
- (void)removeStoreObserver:(__kindof NSObject<RMStoreObserver> *)observer;


- (void)processDelayedTransactions:(MSStoreCompletionBlock)completion;

- (nullable SKProduct *)productWithIdentifier:(NSString *)productId;

- (BOOL)isProductPurchasedWithId:(NSString *)productId;
- (void)buyProductWithIdentifier:(NSString *)productId;

- (void)registerChangeHandler:(MSProductStatusDidChangeBlock)statusDidChangeBlock forProductWithId:(NSString *)productId;

- (nullable MSProductStatus *)statusForProductWithProductId:(NSString *)productId;

@end

NS_ASSUME_NONNULL_END
