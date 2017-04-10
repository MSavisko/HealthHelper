//
//  MSStoreManager.m
//  HealthHelper
//
//  Created by Maksym Savisko on 4/10/17.
//  Copyright © 2017 Maksym Savisko. All rights reserved.
//

#import "MSStoreManager.h"

#import "MSStoreAppReceiptVerifier.h"
#import "MSStoreKeychainPersistence.h"
#import "MSStoreDownloadsPersistence.h"

#import "SKDownload+MS.h"
#import "SKPayment+MS.h"
#import "SKPaymentTransaction+MS.h"
#import "MSProductStatus.h"

@interface MSStoreManager() <RMStoreObserver>
{
    NSSet<NSString *> *_allProductIdentifiers;
}

@property (nonatomic, strong) MSStoreAppReceiptVerifier *receiptVerifier;
@property (nonatomic, strong) MSStoreKeychainPersistence *transactionPersistence;
@property (nonatomic, strong) MSStoreDownloadsPersistence *downloadPersistence;
@property (nonatomic, strong) RMStore *currentStore;
@property (nonatomic, strong) NSMutableDictionary *delayedTransactions;

@property (nonatomic, strong) NSMutableDictionary *productStatuses;

@property (nonatomic, assign) BOOL shouldDelayTransactions;
@property (nonatomic, assign) BOOL fetchingProducts;

@end

@implementation MSStoreManager

#pragma mark - Singleton

+ (instancetype)sharedInstance
{
    static dispatch_once_t pred;
    static id sharedInstance = nil;
    dispatch_once(&pred, ^{
        
        sharedInstance = [[super alloc] initUniqueInstance];
    });
    
    return sharedInstance;
}

- (instancetype)initUniqueInstance
{
    self = [super init];
    
    if ( self )
    {
        _receiptVerifier = [MSStoreAppReceiptVerifier new];
        _transactionPersistence = [MSStoreKeychainPersistence new];
        _downloadPersistence = [MSStoreDownloadsPersistence new];
        _shouldDelayTransactions = YES;
        //        [_transactionPersistence removeTransactions];
        //        [_downloadPersistence removeAllDownloads];
    }
    
    return self;
}

- (id)copy
{
    return self;
}

- (void)dealloc
{
    [_currentStore removeStoreObserver:self];
}

+ (BOOL)canMakePayments
{
    return [RMStore canMakePayments];
}

- (void)initializeStore
{
    if ( _currentStore )
    {
        return;
    }
    
    RMStore *initializedStore = [RMStore defaultStore];
    initializedStore.receiptVerifier = _receiptVerifier;
    initializedStore.transactionPersistor = _transactionPersistence;
    
    _currentStore = initializedStore;
    [_currentStore addStoreObserver:self];
    
    NSLog(@"Initialized store. Can make payments %@", [self.class canMakePayments]? @"YES" : @"NO");
}

- (void)processDelayedTransactions:(MSStoreCompletionBlock)completion
{
    _shouldDelayTransactions = NO;
    
    [self setupInitialStatesWithCompletion:completion];
    
}

- (void)setupInitialStatesWithCompletion:(MSStoreCompletionBlock)completion
{
    /*
    __weak typeof(self) wSelf = self;

    [MSDataManager setupInitialStateForPeriodsWithStateBlock:^NSString * _Nonnull(NSString * _Nonnull identifier) {
        
        return [wSelf purchaseStatusForProductWithIdentifier:identifier];
    }
                                                  completion:completion];
     */
}

/*
- (MSPurchaseStatus *)purchaseStatusForProductWithIdentifier:(NSString *)productId
{
    SKProduct *product = [self productWithIdentifier:productId];
    
    if ( !product )
    {
        return MSPurchaseStatusInvalid;
    }
    
    BOOL purchased = [self isProductPurchasedWithId:productId];
    
    NSString *status = purchased? MSPurchaseStatusPurchased : MSPurchaseStatusNotPurchased;
    
    return status;
}
*/

- (void)addStoreObserver:(__kindof NSObject<RMStoreObserver> *)observer
{
    if ( observer )
    {
        return;
    }
    
    NSLog(@"Adding store observer %@", observer);
    
    [_currentStore addStoreObserver:observer];
}

- (void)removeStoreObserver:(__kindof NSObject<RMStoreObserver> *)observer
{
    if ( !observer )
    {
        return;
    }
    
    NSLog(@"Removing store observer %@", observer);
    
    [_currentStore removeStoreObserver:observer];
}

- (void)fetchProducts
{
    [self fetchProductsWithCompletion:nil];
}

- (void)fetchProductsWithCompletion:(MSStoreProductsFetchCompletionBlock)completion
{
    if ( _fetchingProducts )
    {
        return;
    }
    
    _productStatuses = nil;
    
    /*
    _allProductIdentifiers = [MSDataManager fetchAllProductIdentifiers];
     */
    
    if ( !_allProductIdentifiers.count )
    {
        if ( completion )
        {
            completion (nil, nil);
            /*
            completion(nil, [MSErrorManager storeNoProductsError]);
             */
        }
        return;
    }
    
    NSLog(@"Requesting products\n%@", _allProductIdentifiers);
    
    _fetchingProducts = YES;
    
    __weak typeof(self) wSelf = self;
    [_currentStore requestProducts:_allProductIdentifiers
                           success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
                               
                               __strong typeof(self) sSelf = wSelf;
                               
                               sSelf.fetchingProducts = NO;
                               
                               [sSelf setupInitialStatesWithCompletion:^{
                                   
                                   if ( completion )
                                   {
                                       /*
                                       completion(products, products.count > 0? nil : [MSErrorManager storeNoProductsError]);
                                        */
                                       
                                       completion(products, products.count > 0? nil : nil);
                                   }
                               }];
                           }
                           failure:^(NSError *error) {
                               
                               wSelf.fetchingProducts = NO;
                               
                               if ( completion )
                               {
                                   /*
                                   completion(nil, [MSErrorManager storeUnavailableError]);
                                    */
                                   
                                   completion (nil, nil);
                               }
                           }];
}

- (void)restoreTransactions
{
    /*
    [MSDialogueManager showRestoringProgress];
     */
    
    [_currentStore restoreTransactions];
}

- (BOOL)isProductPurchasedWithId:(NSString *)productId
{
    return [_transactionPersistence isPurchasedProductOfIdentifier:productId] && [_downloadPersistence isDownloadPersistedForProductWithId:productId];
}

- (SKProduct *)productWithIdentifier:(NSString *)productId
{
    return [_currentStore productForIdentifier:productId];
}

- (void)buyProductWithIdentifier:(NSString *)productId
{
    if ( !productId.length )
    {
        return;
    }
    
    if ( ![self.class canMakePayments] )
    {
        /*
        [self handleError:[MSErrorManager storePaymentsUnavailableError]];
         */
        return;
    }
    
    if ( [self isProductPurchasedWithId:productId] )
    {
        NSLog(@"Product with id %@ is already purchased", productId);
        return;
    }
    
    [self updateProductStatusForProductId:productId state:MSProductStateIndeterminate error:nil];
    
    //__weak typeof(self) wSelf = self;
    [_currentStore addPayment:productId
                      success:nil
                      failure:^(SKPaymentTransaction *transaction, NSError *error) {
                          
                          if ( error.code == RMStoreErrorCodeUnknownProductIdentifier )
                          {
                              /*
                              [wSelf updateProductStatusForProductId:productId state:MSProductStateFailed error:error];
                               */
                          }
                      }];
}

- (void)registerChangeHandler:(MSProductStatusDidChangeBlock)statusDidChangeBlock forProductWithId:(NSString *)productId
{
    MSProductStatus *status = [self statusForProductWithProductId:productId];
    status.changeHandler = statusDidChangeBlock;
}

#pragma mark - Downloads

- (void)storeDownloadUpdated:(NSNotification *)notification
{
    [self processDownloadNotification:notification];
}

- (void)storeDownloadPaused:(NSNotification *)notification
{
    [self processDownloadNotification:notification];
}

- (void)storeDownloadCanceled:(NSNotification *)notification
{
    [self processDownloadNotification:notification];
}

- (void)storeDownloadFailed:(NSNotification *)notification
{
    [self processDownloadNotification:notification];
}

- (void)storeDownloadFinished:(NSNotification *)notification
{
    SKDownload *download = notification.rm_storeDownload;
    
    [_downloadPersistence persistDownload:download error:nil];
    
    [self processDownloadNotification:notification];
}

- (void)processDownloadNotification:(NSNotification *)notification
{
    [self updateProductStatusForDownload:notification.rm_storeDownload];
    
    [self handleError:notification.rm_storeError];
    
    [self logNotification:notification];
}

#pragma mark - Transaction

- (void)storePaymentTransactionDeferred:(NSNotification *)notification
{
    [self processPaymentTransaction:notification.rm_transaction notification:notification];
}

- (void)storePaymentTransactionFailed:(NSNotification *)notification
{
    [self processPaymentTransaction:notification.rm_transaction notification:notification];
}

- (void)storePaymentTransactionFinished:(NSNotification *)notification
{
    //NSArray<NSURL *> *downloadedContent = [_downloadPersistence fileURLsForDownloadedContentWithIdentifier:notification.rm_transaction.payment.productIdentifier];
    

//    [MSDataManager processDownloadedContentURLs:downloadedContent completion:^{
//        
//        //New delete process do not delete period from CD. It's just change status to deleted.
//        //That's why we do not need to parse it again.
//        /*
//         [self resetPeriodExceptionForTransactions:@[notification.rm_transaction] withCompletion:^{
//         [self processPaymentTransaction:notification.rm_transaction notification:notification];
//         }];
//         */
//        
//        [self processPaymentTransaction:notification.rm_transaction notification:notification];
//    }];
    
    [self processPaymentTransaction:notification.rm_transaction notification:notification];
}

- (void)processPaymentTransaction:(SKPaymentTransaction *)transaction notification:(NSNotification *)notification
{
    if ( transaction )
    {
        [self processTransactions:@[transaction]];
    }
    
    [self handleError:notification.rm_storeError];
    
    [self logNotification:notification];
}

#pragma mark Restore

- (void)storeRestoreTransactionsFailed:(NSNotification *)notification
{
    [self processRestoredTransactions:notification.rm_transactions notification:notification];
}

- (void)storeRestoreTransactionsFinished:(NSNotification *)notification
{
    //New delete process do not delete period from CD. It's just change status to deleted.
    //That's why we do not need to parse it again.
    /*
     [self resetPeriodExceptionForTransactions:notification.rm_transactions withCompletion:^{
     
     [self processRestoredTransactions:notification.rm_transactions notification:notification];
     
     [MSDialogueManager showRestoreSucceededWithCount:notification.rm_transactions.count];
     }];
     */
    
    [self processRestoredTransactions:notification.rm_transactions notification:notification];
    
    /*
    [MSDialogueManager showRestoreSucceededWithCount:notification.rm_transactions.count];
    */
}

- (void)processRestoredTransactions:(NSArray<SKPaymentTransaction *> *)transactions notification:(NSNotification *)notification
{
    [self processTransactions:transactions];
    
    [self handleError:notification.rm_storeError];
    
    [self logNotification:notification];
}

#pragma mark - Products

- (void)storeProductsRequestFailed:(NSNotification *)notification
{
    [self processProductsRequestNotification:notification];
}

- (void)storeProductsRequestFinished:(NSNotification *)notification
{
    [self processProductsRequestNotification:notification];
}

- (void)processProductsRequestNotification:(NSNotification *)notification
{
    [self updateProductStatusesForProducts:notification.rm_products];
    
    
    [self handleError:notification.rm_storeError];
    
    [self logNotification:notification];
}

#pragma mark - Receipt

- (void)storeRefreshReceiptFailed:(NSNotification *)notification
{
    [self handleError:notification.rm_storeError];
    
    [self logNotification:notification];
}

- (void)storeRefreshReceiptFinished:(NSNotification *)notification
{
    [self handleError:notification.rm_storeError];
    
    [self logNotification:notification];
}

#pragma mark - Transaction Processing

//New delete flow do not delete period from CD. It's just mark status as deleted.
/*
 - (void) resetPeriodExceptionForTransactions:(NSArray<SKPaymentTransaction *> *)transactions withCompletion:(void (^)())completion
 {
 NSArray<NSString *> *transactionIdentfiers = [transactions valueForKeyPath:@"@distinctUnionOfObjects.payment.productIdentifier"];
 
 [MSDataManager removePeriodParseExceptionForPurchaseIds:[NSSet setWithArray:transactionIdentfiers] withCompletion:^
 {
 [MSDataManager parseLocalChannelsWithCompletion:completion];
 }];
 }
 */

- (void)processTransactions:(NSArray<SKPaymentTransaction *> *)transactions
{
    [transactions enumerateObjectsUsingBlock:^(SKPaymentTransaction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [self updateProductStatusForTransaction:obj];
    }];
    
    /*
    NSArray<NSString *> *transactionIdentfiers = [transactions valueForKeyPath:@"@distinctUnionOfObjects.payment.productIdentifier"];
    
    __weak typeof(self) wSelf = self;
    [MSDataManager updatePeriodsWithProductIdentifiers:[NSSet setWithArray:transactionIdentfiers]
                                            stateBlock:^NSString * _Nonnull(NSString * _Nonnull identifier) {
                                                
                                                return [wSelf purchaseStatusForProductWithIdentifier:identifier];
                                            }
                                            completion:nil];
     */
}


#pragma mark - Product Statuses

- (NSMutableDictionary *)productStatuses
{
    if ( !_productStatuses )
    {
        _productStatuses = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    
    return _productStatuses;
}

- (void)updateProductStatusesForProducts:(NSArray<SKProduct *> *)products
{
    [_allProductIdentifiers enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        
        MSProductStatus *status = [self statusForProductWithProductId:obj];
        
        SKProduct *product = [[products filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K == %@", NSStringFromSelector(@selector(productIdentifier)), obj]] firstObject];
        
        [status updateWithProduct:product];
        
        NSLog(@"Status for product\n%@", status);
    }];
}

- (void)updateProductStatusForProductId:(NSString *)productId state:(MSProductState)state error:(nullable NSError *)error
{
    MSProductStatus *status = [self statusForProductWithProductId:productId];
    
    [status updateWithState:state error:error];
    
    NSLog(@"Status for product with id\n%@", status);
}

- (void)updateProductStatusForDownload:(SKDownload *)download
{
    NSString *productId = download.contentIdentifier;
    
    MSProductStatus *status = [self statusForProductWithProductId:productId];
    
    [status updateWithDownload:download];
    
    NSLog(@"Status for Download product\n%@", status);
}

- (void)updateProductStatusForTransaction:(SKPaymentTransaction *)transaction
{
    NSString *productId = transaction.payment.productIdentifier;
    
    MSProductStatus *status = [self statusForProductWithProductId:productId];
    
    [status updateWithTransaction:transaction];
    
    NSLog(@"Status for Transaction product\n%@", status);
}

- (MSProductStatus *)statusForProductWithProductId:(NSString *)productId
{
    MSProductStatus *status = self.productStatuses[productId];
    
    if ( !status )
    {
        status = [MSProductStatus productStatusForProductWithId:productId];
        
        _productStatuses[productId] = status;
    }
    
    return status;
}

#pragma mark - Error handling

- (void)handleError:(NSError *)error
{
    if ( !error )
    {
        return;
    }
    
    //Do not need to show error from iTunes Connect Store.
    if ([error.domain isEqualToString:SKErrorDomain])
    {
        return;
    }
    
    /*
    [MSDialogueManager showStoreError:error];
     */
}


#pragma mark - Logging

- (void)logObjects:(NSArray *)objects title:(NSString *)title
{
    if ( !objects.count )
    {
        return;
    }
    
    if ( title )
    {
        NSLog(@"%@", title);
    }
    
    NSLog(@"%@", [self stringFromObjects:objects]);
}

- (NSString *)stringFromObjects:(NSArray *)objects
{
    if ( !objects.count )
    {
        return @"";
    }
    
    NSMutableArray *components = [NSMutableArray arrayWithCapacity:0];
    
    [objects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ( [obj respondsToSelector:@selector(ms_detailedDescription)] )
        {
            [components addObject:[NSString stringWithFormat:@"{\n%@\n}",[obj performSelector:@selector(ms_detailedDescription)]]];
        }
        else
        {
            [components addObject:[obj description]];
        }
    }];
    
    return [components componentsJoinedByString:@",\n"];
}

- (void)logNotification:(NSNotification *)notification
{
    NSMutableArray *components = [NSMutableArray arrayWithCapacity:0];
    
    [components addObject:[NSString stringWithFormat:@"Notification - %@", notification.name]];
    
    if ( notification.rm_productIdentifier )
    {
        [components addObject:[NSString stringWithFormat:@"Product Identifier - %@", notification.rm_productIdentifier]];
    }
    
    if ( notification.rm_transaction )
    {
        [components addObject:[NSString stringWithFormat:@"\nTransaction - %@\n", notification.rm_transaction.ms_detailedDescription]];
    }
    
    if ( notification.rm_transactions.count )
    {
        [components addObject:[NSString stringWithFormat:@"\nTransactions [\n%@\n]\n", [self stringFromObjects:notification.rm_transactions]]];
    }
    
    if ( notification.rm_storeDownload )
    {
        [components addObject:[NSString stringWithFormat:@"\nDownload\n%@\n", notification.rm_storeDownload.ms_detailedDescription]];
    }
    
    if ( notification.rm_storeError )
    {
        [components addObject:[NSString stringWithFormat:@"Error - %@", notification.rm_storeError]];
    }
    
    if ( notification.rm_invalidProductIdentifiers.count )
    {
        [components addObject:[NSString stringWithFormat:@"\nInvalid Products [\n%@\n]\n", [self stringFromObjects:notification.rm_invalidProductIdentifiers]]];
    }
    
    if ( notification.rm_products.count )
    {
        [components addObject:[NSString stringWithFormat:@"\nProducts [\n%@\n]\n", [self stringFromObjects:notification.rm_products]]];
    }
    
    NSLog(@"%@", [components componentsJoinedByString:@"\n"]);
}

@end
