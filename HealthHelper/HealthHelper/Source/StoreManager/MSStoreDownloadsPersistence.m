//
//  MSStoreDownloadsPersistence.m
//  HealthHelper
//
//  Created by Maksym Savisko on 4/10/17.
//  Copyright © 2017 Maksym Savisko. All rights reserved.
//

#import "MSStoreDownloadsPersistence.h"
#import "SKDownload+MS.h"
@import StoreKit;

static NSString *const MSDownloadDirectoryName = @"Downloads";
static NSString *const MSDownloadContentDirectoryName = @"Contents";

@implementation MSStoreDownloadsPersistence

- (BOOL)createDirectoryAtURL:(NSURL *)url
{
    if ( ![[NSFileManager defaultManager] fileExistsAtPath:url.path] )
    {
        NSError *error = nil;
        BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:url.path withIntermediateDirectories:YES attributes:nil error:&error];
        
        if ( error )
        {
            NSLog(@"Error creating directory at url %@\n%@", url, error);
        }
        
        return success;
    }
    
    return YES;
}

- (void)removeAllDownloads
{
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtURL:[self urlForDownloadedContent] error:&error];
    
    if ( error )
    {
        NSLog(@"Error removing all downloads %@", error);
    }
}

- (NSURL *)urlForDownloadedContent
{
    NSURL *documentsDirURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                     inDomains:NSUserDomainMask] lastObject];
    
    documentsDirURL = [documentsDirURL URLByAppendingPathComponent:MSDownloadDirectoryName];
    
    [self createDirectoryAtURL:documentsDirURL];
    
    return documentsDirURL;
}

- (NSURL *)urlForStoringContentOfDownloadWithContentIdentifier:(NSString *)contentIdentifier version:(nullable NSString *)version
{
    NSURL *downloadsDirURL = [self urlForDownloadedContent];
    
    NSURL *downloadContentURL = [downloadsDirURL URLByAppendingPathComponent:contentIdentifier];
    
    [self createDirectoryAtURL:downloadContentURL];
    
    if ( version.length )
    {
        downloadContentURL = [downloadContentURL URLByAppendingPathComponent:version];
    }
    
    return downloadContentURL;
}

- (BOOL)persistDownload:(SKDownload *)download error:(out NSError * _Nullable __autoreleasing *)error
{
    NSURL *downloadURL = [self urlForStoringContentOfDownloadWithContentIdentifier:download.contentIdentifier version:download.contentVersion];
    
    NSURL *contentURL = download.contentURL;
    
    if ( [[NSFileManager defaultManager] fileExistsAtPath:downloadURL.path] )
    {
        [[NSFileManager defaultManager] removeItemAtURL:downloadURL error:nil];
    }
    
    NSError *moveError = nil;
    
    BOOL success = [[NSFileManager defaultManager] moveItemAtURL:contentURL toURL:downloadURL error:&moveError];
    
    if ( moveError && error )
    {
        *error = moveError;
    }
    
    return success;
}

- (BOOL)isDownloadPersistedForProductWithId:(NSString *)productId
{
    return [self fileURLsForDownloadedContentWithIdentifier:productId].count > 0;
}

- (nullable NSArray<NSURL *> *)urlsForFolderAtURL:(NSURL *)folderURL recursive:(BOOL)recursive
{
    if ( !folderURL )
    {
        return nil;
    }
    
    BOOL isDirectory = NO;
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:folderURL.path isDirectory:&isDirectory];
    
    if ( !fileExists )
    {
        return nil;
    }
    
    if ( !isDirectory )
    {
        return @[folderURL];
    }
    
    NSMutableSet *contentURLs = [NSMutableSet setWithCapacity:0];
    
    NSDirectoryEnumerationOptions options = NSDirectoryEnumerationSkipsHiddenFiles;
    
    if ( !recursive )
    {
        options |= NSDirectoryEnumerationSkipsSubdirectoryDescendants;
    }
    
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtURL:folderURL
                                                             includingPropertiesForKeys:@[]
                                                                                options:options
                                                                           errorHandler:nil];
    
    NSURL *url = nil;
    
    while (url = [enumerator nextObject] )
    {
        [contentURLs addObject:url];
    }
    
    return contentURLs.allObjects;
}

- (nullable NSArray<NSString *> *)versionsForDownloadWithContentIdentifier:(NSString *)contentIdentifier
{
    NSURL *baseURL = [self urlForStoringContentOfDownloadWithContentIdentifier:contentIdentifier version:nil];
    
    NSArray<NSURL *> *versionURLs = [self urlsForFolderAtURL:baseURL recursive:NO];
    
    NSArray<NSString *> *versions = [versionURLs valueForKeyPath:[NSString stringWithFormat:@"@unionOfObjects.%@", NSStringFromSelector(@selector(lastPathComponent))]];
    
    return versions;
}

- (nullable NSArray<NSURL *> *)contentURLsForDownloadWithContentIdentifier:(NSString *)contentIdentifier version:(NSString *)version
{
    NSURL *baseURL =  [self urlForStoringContentOfDownloadWithContentIdentifier:contentIdentifier version:version];
    
    baseURL = [baseURL URLByAppendingPathComponent:MSDownloadContentDirectoryName];
    
    return [self urlsForFolderAtURL:baseURL recursive:YES];
}

- (NSArray<NSURL *> *)fileURLsForDownloadedContentWithIdentifier:(NSString *)contentIdentifier
{
    NSArray<NSString *> *versions = [self versionsForDownloadWithContentIdentifier:contentIdentifier];
    
    NSString *latestVersion = [[versions sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:nil ascending:NO]]] firstObject];
    
    return [self contentURLsForDownloadWithContentIdentifier:contentIdentifier version:latestVersion];
}

@end

