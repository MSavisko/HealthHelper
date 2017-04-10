//
//  MSStoreDownloadsPersistence.h
//  HealthHelper
//
//  Created by Maksym Savisko on 4/10/17.
//  Copyright © 2017 Maksym Savisko. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SKDownload;

NS_ASSUME_NONNULL_BEGIN

@protocol MSStoreDownloadsPersistenceProtocol <NSObject>

- (void)removeAllDownloads;

- (BOOL)persistDownload:(SKDownload *)download error:(out NSError *__autoreleasing __nullable *)error;
- (BOOL)isDownloadPersistedForProductWithId:(NSString *)productId;

- (nullable NSArray<NSURL *> *)fileURLsForDownloadedContentWithIdentifier:(NSString *)contentIdentifier;

@end

@interface MSStoreDownloadsPersistence : NSObject <MSStoreDownloadsPersistenceProtocol>

@end

NS_ASSUME_NONNULL_END

