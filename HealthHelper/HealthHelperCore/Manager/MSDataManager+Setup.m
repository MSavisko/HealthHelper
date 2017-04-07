//
//  MSDataManager+Setup.m
//  HealthHelper
//
//  Created by Maksym Savisko on 4/7/17.
//  Copyright © 2017 Maksym Savisko. All rights reserved.
//

#import "MSDataManager+Setup.h"

#import <MagicalRecord/MagicalRecord+Setup.h>
#import <MagicalRecord/MagicalRecord+Options.h>

@implementation MSDataManager (Setup)

#pragma mark - MSDataManagerSetupProtocol

+ (void) setupWithCompletion:(MSDataManagerVoidCompletionBlock) completion
{
    [self setupAtStoreURL:[[self sharedInstance] applicationDatabaseURL] completion:completion];
}

+ (void) setupAtStoreURL:(nonnull NSURL *) storeUrl completion:(nullable MSDataManagerVoidCompletionBlock) completion
{
    [[self sharedInstance] setupAtStoreURL:storeUrl completion:completion];
}

#pragma mark - Private

- (void) setupAtStoreURL:(nonnull NSURL *) storeURL completion:(nullable MSDataManagerVoidCompletionBlock) completion
{
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreAtURL:storeURL];
    
    [MagicalRecord setLoggingLevel:MagicalRecordLoggingLevelAll];
    
    if (completion)
    {
        completion ();
    }
}

- (NSURL *) applicationDatabaseURL
{
    NSURL *documentsDirURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    return [documentsDirURL URLByAppendingPathComponent:@"HealthHelper.sqlite"];
}

@end
