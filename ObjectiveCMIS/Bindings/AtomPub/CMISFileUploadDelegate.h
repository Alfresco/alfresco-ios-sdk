/*
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
 */
#import <Foundation/Foundation.h>
#import "CMISTypeDefs.h"


@interface CMISFileUploadDelegate : NSObject <NSURLConnectionDataDelegate>

/** Asynchronous handling blocks */

@property (nonatomic, strong) CMISHttpResponseCompletionBlock fileUploadCompletionBlock; // Called when the file is uploaded

@property (nonatomic, strong) CMISErrorFailureBlock fileUploadFailureBlock; // Called when something went wrong

@property (nonatomic, strong) CMISProgressBlock fileUploadProgressBlock; // Called whenever progress in the upload has been made

@property (nonatomic, strong) CMISVoidCompletionBlock fileUploadCleanupBlock; // Executed when the file is uploaded. Use this to cleanup resources (files, streams, etc.)


/** Optional properties */

/**
 * Set this property if the bytes to upload is know up front.
 * If set, the 'expected bytes' received during upload callbacks will be ignored.
 */
@property (nonatomic, strong) NSNumber *bytesExpected;


@end