//
//  MSRequestManager.m
//  HealthHelper
//
//  Created by Maksym Savisko on 4/7/17.
//  Copyright © 2017 Maksym Savisko. All rights reserved.
//

#import "MSRequestManager.h"
#import "MSRequestManagerConstants.h"
#import "MSRequestToken.h"
#import "MSRequestResponse.h"

#import "MSRequestManager+Private.h"

#import <AFNetworking/AFNetworking.h>
#import "AFNetworkActivityIndicatorManager.h"

@interface MSRequestManager ()

@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, strong) NSMutableArray *activeRequests;

@property (nonatomic, strong) MSRequestToken *primitiveAccessToken;

@end

@implementation MSRequestManager

@synthesize accessToken = _accessToken, serverAddress = _serverAddress, authorize = _authorize, offline = _offline;

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
        
    }
    
    return self;
}

- (id)copy
{
    return self;
}

#pragma mark - Private Base Methods

- (void) GET:(NSString *)URLString
  parameters:(nullable id)parameters
    progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
     success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
     failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
{
    [self addActiveRequest:URLString];
    
    [self.manager GET:URLString parameters:parameters progress:downloadProgress
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
    {
        if (success)
        {
            success (task, responseObject);
        }
    }
              failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
    {
        [self removeActiveRequest:URLString];
        
        if (failure)
        {
            failure (task, error);
        }
        
    }];
    
}

- (void) POST:(NSString *)URLString
   parameters:(nullable id)parameters
      success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
      failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
{
    [self addActiveRequest:URLString];
    
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         if (success)
         {
             success (task, responseObject);
         }
         
     }
               failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         [self removeActiveRequest:URLString];
         
         if (failure)
         {
             failure (task, error);
         }
         
     }];
}

- (void) PUT:(NSString *)URLString
  parameters:(nullable id)parameters
     success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
     failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
{
    [self addActiveRequest:URLString];
    
    [self.manager PUT:URLString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         if (success)
         {
             success (task, responseObject);
         }
         
     }
              failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         [self removeActiveRequest:URLString];
         
         if (failure)
         {
             failure (task, error);
         }
         
     }];
}

#pragma mark - Private Request Methods

- (void)addActiveRequest:(NSString *)URLString
{
    [self.activeRequests addObject:URLString];
}

- (void)removeActiveRequest:(NSString *)URLString
{
    if ([self.activeRequests containsObject:URLString])
    {
        [self.activeRequests removeObject:URLString];
    }
}

- (BOOL)isActiveRequest:(NSString *)URLString
{
    return ([self.activeRequests containsObject:URLString]);
}

#pragma mark - Private Call Methods

- (NSString *) apiCall:(NSString *) call
{
    return [NSString stringWithFormat:@"%@%@%@", self.serverAddress,MSRequestManagerCallPrefix, call];
}

- (NSInteger) statusCodeFromTask:(NSURLSessionDataTask *) task
{
    NSInteger statusCode = 0;
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
    
    if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]])
    {
        statusCode = httpResponse.statusCode;
    }
    
    return statusCode;
}

#pragma mark - MSRequestManagerProtocol

- (void) setAccessToken:(MSRequestToken *)accessToken
{
    _primitiveAccessToken = accessToken;
    [self.manager.requestSerializer setValue:accessToken.info forHTTPHeaderField:MSRequestManagerAccessTokenField];
}

- (MSRequestToken *) accessToken
{
    NSString *info = _primitiveAccessToken.info;
    NSString *headerInfo = [self.manager.requestSerializer.HTTPRequestHeaders valueForKey:MSRequestManagerAccessTokenField];
    
    if ([info isEqualToString:headerInfo])
    {
        return _primitiveAccessToken;
    }
    else
    {
        _primitiveAccessToken = nil;
        [self.manager.requestSerializer setValue:nil forHTTPHeaderField:MSRequestManagerAccessTokenField];
    }
    
    return nil;
}

- (NSString *)serverAddress
{
    
#ifdef DEBUG
    return MSRequestManagerServerAddressStage;
#else
    return MSRequestManagerServerAddressProduction;
#endif
    
}

- (BOOL) isAuthorize
{
    return (self.accessToken.info.length);
}

- (BOOL) isOffline
{
    //TODO: Add Reachability
    return NO;
}


@end
