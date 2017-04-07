//
//  MSDataManager+Private.m
//  HealthHelper
//
//  Created by Maksym Savisko on 4/7/17.
//  Copyright © 2017 Maksym Savisko. All rights reserved.
//

#import "MSDataManager+Private.h"

@implementation MSDataManager (Private)

+ (dispatch_queue_t)savingSerialQueue
{
    static dispatch_once_t onceToken;
    
    static dispatch_queue_t savingQueue = nil;
    dispatch_once(&onceToken, ^{
        
        savingQueue = dispatch_queue_create("com.MaksymSavisko.HealthHelper.coredata.serial.save.queue", DISPATCH_QUEUE_SERIAL);
    });
    
    return savingQueue;
}

+ (void) saveWithBlock:(MSDataManagerExecuteOnContextBlock) executionBlock
{
    [self saveWithBlock:executionBlock useSerialQueue:YES];
}

+ (void) saveWithBlock:(MSDataManagerExecuteOnContextBlock) executionBlock useSerialQueue:(BOOL) useSerialQueue
{
    [self saveWithBlock:executionBlock serialQueue:useSerialQueue completion:nil];
}

+ (void) saveWithBlock:(MSDataManagerExecuteOnContextBlock) executionBlock completion:(nullable MSDataManagerVoidCompletionBlock) completion
{
    [self saveWithBlock:executionBlock serialQueue:YES completion:completion];
}

+ (void) saveWithBlock:(MSDataManagerExecuteOnContextBlock) executionBlock serialQueue:(BOOL)useSerialQueue completion:(nullable MSDataManagerVoidCompletionBlock) completion
{
    MSDataManagerVoidCompletionBlock executeBlock = ^{
        
        //TODO: Add check
        //NSDate *date = [NSDate date];
        
        //NSLog(@"Start saving to persistent store..");
        [MagicalRecord saveWithBlockAndWait:executionBlock];
        //NSLog(@"Finish saving to persistent store. Time taken %@", @([[NSDate date] timeIntervalSinceDate:date]));
        
        if ( completion )
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    };
    
    if ( useSerialQueue )
    {
        dispatch_sync([self savingSerialQueue], executeBlock);
    }
    else
    {
        executeBlock();
    }
}


@end
