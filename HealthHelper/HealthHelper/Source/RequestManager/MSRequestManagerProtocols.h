//
//  MSRequestManagerProtocols.h
//  HealthHelper
//
//  Created by Maksym Savisko on 4/7/17.
//  Copyright © 2017 Maksym Savisko. All rights reserved.
//

@import Foundation;

@class MSRequestToken;

NS_ASSUME_NONNULL_BEGIN

@protocol MSRequestManagerProtocol <NSObject>

@property (nonatomic, copy, nullable) MSRequestToken *accessToken;
@property (nonatomic, readonly, copy) NSString *serverAddress;

@property (nonatomic, getter = isAuthorize, readonly) BOOL authorize;
@property (nonatomic, getter = isOffline, readonly) BOOL offline;

@end

NS_ASSUME_NONNULL_END
