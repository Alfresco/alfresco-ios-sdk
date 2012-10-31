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

#import "CMISHttpRequest.h"

@interface CMISHttpDownloadRequest : CMISHttpRequest

@property (nonatomic, strong) NSOutputStream *outputStream;     // if outputStream is nil download goes to httpResponse.data
@property (nonatomic, assign) unsigned long long bytesExpected; // optional; if not set, expected content length from HTTP header is used
@property (nonatomic, readonly) unsigned long long bytesDownloaded;

+ (CMISHttpDownloadRequest*)startRequest:(NSMutableURLRequest*)urlRequest
                          withHttpMethod:(CMISHttpRequestMethod)httpRequestMethod
                            outputStream:(NSOutputStream*)outputStream
                           bytesExpected:(unsigned long long)bytesExpected
                         completionBlock:(void (^)(CMISHttpResponse *httpResponse, NSError *error))completionBlock
                           progressBlock:(void (^)(unsigned long long bytesDownloaded, unsigned long long bytesTotal))progressBlock;

- (id)initWithHttpMethod:(CMISHttpRequestMethod)httpRequestMethod
         completionBlock:(void (^)(CMISHttpResponse *httpResponse, NSError *error))completionBlock
           progressBlock:(void (^)(unsigned long long bytesDownloaded, unsigned long long bytesTotal))progressBlock;

@end
