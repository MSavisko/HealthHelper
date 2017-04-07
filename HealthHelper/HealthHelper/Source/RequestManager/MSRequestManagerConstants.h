//
//  MSRequestManagerConstants.h
//  HealthHelper
//
//  Created by Maksym Savisko on 4/7/17.
//  Copyright © 2017 Maksym Savisko. All rights reserved.
//

#ifndef MSRequestManagerConstants_h
#define MSRequestManagerConstants_h

@class MSRequestResponse;

#warning Check, that server address exit
static NSString *const MSRequestManagerServerAddressStage = @"";
static NSString *const MSRequestManagerServerAddressProduction = @"";

static NSString *const MSRequestManagerBackgroundSessionConfigurationIdetifier = @"com.MaksymSavisko.HealthHelper.session.background.main";
static NSString *const MSRequestManagerNotificationBackgroundSessionDidFinishedKey = @"MSRequestManagerNotificationBackgroundSessionDidFinished";

static NSString *const MSRequestManagerAccessTokenField = @"Authorization";
static NSString *const MSRequestManagerContentTypeField = @"Content-Type";
static NSString *const MSRequestManagerContentType = @"application/json";

static NSString *const MSRequestManagerCallPrefix = @"/api/";

typedef void (^MSRequestManagerVoidCompletionBlock)();
typedef void (^MSRequestManagerResponseCompletionBlock)(MSRequestResponse *response);

#endif /* MSRequestManagerConstants_h */
