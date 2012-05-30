//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HTTPResponse;

typedef void (^CMISVoidCompletionBlock)(void);
typedef void (^CMISStringCompletionBlock)(NSString *result);
typedef void (^CMISDataCompletionBlock)(NSData *data);
typedef void (^CMISHttpResponseCompletionBlock)(HTTPResponse *httpResponse);
typedef void (^CMISErrorFailureBlock)(NSError *error);
typedef void (^CMISProgressBlock)(NSInteger bytesDownloaded, NSInteger bytesTotal);