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

@protocol MSDataManagerSetupProtocol <NSObject>

+ (void) setupWithCompletion:(MSDataManagerVoidCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
