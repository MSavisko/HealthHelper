//
//  MSRequestManager+Private.h
//  HealthHelper
//
//  Created by Maksym Savisko on 4/7/17.
//  Copyright © 2017 Maksym Savisko. All rights reserved.
//

#import "MSRequestManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface MSRequestManager (Private)

#pragma mark - Private Base Methods

- (void) GET:(NSString *)URLString
  parameters:(nullable id)parameters
    progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
     success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
     failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

- (void) POST:(NSString *)URLString
   parameters:(nullable id)parameters
      success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
      failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

- (void) PUT:(NSString *)URLString
  parameters:(nullable id)parameters
     success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
     failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;


#pragma mark - Private Request Methods

- (void)addActiveRequest:(NSString *)URLString;
- (void)removeActiveRequest:(NSString *)URLString;
- (BOOL)isActiveRequest:(NSString *)URLString;

#pragma mark - Private Call Methods

- (NSString *) apiCall:(NSString *) call;

#pragma mark - Private Error Methods

- (NSInteger) statusCodeFromTask:(NSURLSessionDataTask *) task;

@end

NS_ASSUME_NONNULL_END
