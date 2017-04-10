//
//  SKDownload+MS.h
//  HealthHelper
//
//  Created by Maksym Savisko on 4/10/17.
//  Copyright © 2017 Maksym Savisko. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import "MSDetailedDescriptionProtocol.h"

@interface SKDownload (MS) <MSDetailedDescriptionProtocol>

- (BOOL)isDownloading;

@end
