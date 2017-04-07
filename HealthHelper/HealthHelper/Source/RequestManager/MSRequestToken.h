//
//  MSRequestToken.h
//  HealthHelper
//
//  Created by Maksym Savisko on 4/7/17.
//  Copyright © 2017 Maksym Savisko. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, MSRequestTokenType)
{
    MSRequestTokenTypeBearer
};

@interface MSRequestToken : NSObject

@property (nonatomic, readonly, copy) NSString *info;
@property (nonatomic, readonly, copy) NSString *shortInfo;
@property (nonatomic, readonly) MSRequestTokenType tokenType;

+ (instancetype) defaultTokenWithShortInfo:(NSString *) info;
+ (instancetype) tokenWithType:(MSRequestTokenType) type andShortInfo:(NSString *) info;

@end
