//
//  MSRequestToken.m
//  HealthHelper
//
//  Created by Maksym Savisko on 4/7/17.
//  Copyright © 2017 Maksym Savisko. All rights reserved.
//

#import "MSRequestToken.h"

@implementation MSRequestToken

#pragma mark - Public Class Methods

+ (instancetype) defaultTokenWithShortInfo:(NSString *) info
{
    return [self tokenWithType:MSRequestTokenTypeBearer andShortInfo:info];
}

+ (instancetype) tokenWithType:(MSRequestTokenType)type andShortInfo:(NSString *) info
{
    return [[self alloc] initWithTokenType:type andShortInfo:info];
}

#pragma mark - Initialization

- (instancetype) initWithTokenType:(MSRequestTokenType) type andShortInfo:(NSString *) info
{
    self = [super init];
    
    if (self)
    {
        _tokenType = type;
        _shortInfo = info;
        _info = [NSString stringWithFormat:@"%@ %@", [self stringFromTokenType:type], info];
    }
    
    return self;
}

#pragma mark - Private Helpers Methods

- (NSString *) stringFromTokenType:(MSRequestTokenType) type
{
    switch (type)
    {
        case MSRequestTokenTypeBearer:
            return @"Bearer";
            break;
    }
}

@end
