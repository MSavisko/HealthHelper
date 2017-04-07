//
//  MSDataManagerProtocols.h
//  HealthHelper
//
//  Created by Maksym Savisko on 4/7/17.
//  Copyright © 2017 Maksym Savisko. All rights reserved.
//

#import "MSDataManagerConstants.h"

@class NSManagedObjectContext;

NS_ASSUME_NONNULL_BEGIN

@protocol MSDataManagerProtocol <NSObject>

@property (nonatomic, readonly) NSManagedObjectContext *mainContext;

@end

@protocol MSDataManagerPrivateProtocol <MSDataManagerProtocol>

+ (void) saveWithBlock:(MSDataManagerExecuteOnContextBlock) executionBlock;
+ (void) saveWithBlock:(MSDataManagerExecuteOnContextBlock) executionBlock useSerialQueue:(BOOL) useSerialQueue;
+ (void) saveWithBlock:(MSDataManagerExecuteOnContextBlock) executionBlock completion:(nullable MSDataManagerVoidCompletionBlock) completion;
+ (void) saveWithBlock:(MSDataManagerExecuteOnContextBlock) executionBlock serialQueue:(BOOL)useSerialQueue completion:(nullable MSDataManagerVoidCompletionBlock) completion;

@end

@protocol MSDataManagerSetupProtocol <MSDataManagerProtocol>

+ (void) setupWithCompletion:(nullable MSDataManagerVoidCompletionBlock) completion;
+ (void) setupAtStoreURL:(NSURL *) storeUrl completion:(nullable MSDataManagerVoidCompletionBlock) completion;

@end

NS_ASSUME_NONNULL_END
