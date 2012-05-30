//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISTypeDefs.h"


@interface CMISFileUploadDelegate : NSObject <NSURLConnectionDataDelegate>

@property (nonatomic, strong) CMISHttpResponseCompletionBlock fileUploadCompletionBlock; // Called when the file is uploaded
@property (nonatomic, strong) CMISErrorFailureBlock fileUploadFailureBlock; // Called when something went wrong
@property (nonatomic, strong) CMISProgressBlock fileUploadProgressBlock; // Called whenever progress in the upload has been made
@property (nonatomic, strong) CMISVoidCompletionBlock fileUploadCleanupBlock; // Executed when the file is uploaded. Use this to cleanup resources (files, streams, etc.)

@end