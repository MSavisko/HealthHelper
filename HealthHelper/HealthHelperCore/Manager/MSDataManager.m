//
//  MSDataManager.m
//  HealthHelper
//
//  Created by Maksym Savisko on 4/7/17.
//  Copyright © 2017 Maksym Savisko. All rights reserved.
//

#import "MSDataManager.h"

#import <MagicalRecord/MagicalRecord.h>

@implementation MSDataManager

@synthesize mainContext = _mainContext;

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
        [NSFetchedResultsController deleteCacheWithName:nil];
        
    }
    
    return self;
}

- (id)copy
{
    return self;
}

@end
