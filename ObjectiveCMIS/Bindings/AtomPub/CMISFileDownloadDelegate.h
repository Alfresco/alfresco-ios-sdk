//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISTypeDefs.h"

/**
 * Delegate object that will take care of asynchronous downloading a file.
 * The reason for having a separate object, is because potentially multiple threads
 * could initiate the download of a file. By giving each download a specific
 * 'delegate handling object', all threads can happily churn away at downloading the file.
 */
@interface CMISFileDownloadDelegate : NSObject <NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSString *filePathForContentRetrieval;
@property (nonatomic, strong) CMISVoidCompletionBlock fileRetrievalCompletionBlock;
@property (nonatomic, strong) CMISErrorFailureBlock fileRetrievalFailureBlock;
@property (nonatomic, strong) CMISProgressBlock fileRetrievalProgressBlock;

@end