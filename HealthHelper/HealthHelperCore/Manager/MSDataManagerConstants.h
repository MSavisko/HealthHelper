//
//  MSDataManagerConstants.h
//  HealthHelper
//
//  Created by Maksym Savisko on 4/7/17.
//  Copyright © 2017 Maksym Savisko. All rights reserved.
//

#ifndef MSDataManagerConstants_h
#define MSDataManagerConstants_h

@class NSManagedObjectContext;

typedef void (^MSDataManagerVoidCompletionBlock)();

typedef void (^MSDataManagerExecuteOnContextBlock)(NSManagedObjectContext *__nonnull context);

#endif /* MSDataManagerConstants_h */
