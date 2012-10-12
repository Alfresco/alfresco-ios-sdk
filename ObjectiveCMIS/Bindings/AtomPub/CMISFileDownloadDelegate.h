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
@property (nonatomic, strong) NSNumber * contentStreamLength;
@end