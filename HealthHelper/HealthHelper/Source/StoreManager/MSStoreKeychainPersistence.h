//
//  MSStoreKeychainPersistence.h
//  HealthHelper
//
//  Created by Maksym Savisko on 4/10/17.
//  Copyright © 2017 Maksym Savisko. All rights reserved.
//

@import Foundation;
#import <RMStore/RMStore.h>

@protocol MSStoreTransactionPersistor <RMStoreTransactionPersistor>

/** Remove all persisted transactions from the keychain.
 */
- (void)removeTransactions;

/** Consume the given product if available. Intended for consumable products.
 @param productIdentifier Identifier of the product to be consumed.
 @return YES if the product was consumed, NO otherwise.
 */
- (BOOL)consumeProductOfIdentifier:(NSString*)productIdentifier;

/** Returns the number of persisted transactions for the given product that have not been consumed. Intended for consumable products.
 @param productIdentifier Identifier of the product to be counted.
 @return The number of persisted transactions for the given product that have not been consumed.
 */
- (NSInteger)countProductOfdentifier:(NSString*)productIdentifier;

/**
 Indicates wheter the given product has been purchased. Intended for non-consumables.
 @param productIdentifier Identifier of the product.
 @return YES if there is at least one transaction for the given product, NO otherwise. Note that if the product is consumable this method will still return YES even if all transactions have been consumed.
 */
- (BOOL)isPurchasedProductOfIdentifier:(NSString*)productIdentifier;

/** Returns the product identifiers of all products whose transactions have been persisted.
 */
@property (nonatomic, readonly, copy) NSSet *purchasedProductIdentifiers;

@end

/** Transaction persistence using the keychain.
 */
@interface MSStoreKeychainPersistence : NSObject <MSStoreTransactionPersistor>

@end
