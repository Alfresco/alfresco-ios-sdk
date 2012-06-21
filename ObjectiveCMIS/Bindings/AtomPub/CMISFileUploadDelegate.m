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

#import "CMISFileUploadDelegate.h"
#import "CMISErrors.h"
#import "CMISHttpUtil.h"


@interface CMISFileUploadDelegate ()

@property (nonatomic, strong) NSMutableData *data;
@property NSInteger statusCode;

@end

@implementation CMISFileUploadDelegate

@synthesize fileUploadCompletionBlock = _fileUploadCompletionBlock;
@synthesize fileUploadFailureBlock = _fileUploadFailureBlock;
@synthesize fileUploadProgressBlock = _fileUploadProgressBlock;
@synthesize fileUploadCleanupBlock = _fileUploadCleanupBlock;
@synthesize data = _data;
@synthesize statusCode = _statusCode;
@synthesize bytesExpected = _bytesExpected;

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.data = [[NSMutableData alloc] init];

    if ([response isKindOfClass: [NSHTTPURLResponse class]])
    {
        self.statusCode = [(NSHTTPURLResponse*) response statusCode];
    }
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten
            totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    if (self.fileUploadProgressBlock)
    {
        if (self.bytesExpected == nil)
        {
            self.fileUploadProgressBlock(totalBytesWritten, totalBytesExpectedToWrite);
        }
        else
        {
            self.fileUploadProgressBlock(totalBytesWritten, [self.bytesExpected intValue]);
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.data appendData:data];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (self.fileUploadFailureBlock)
    {
        NSError *cmisError = [CMISErrors cmisError:&error withCMISErrorCode:kCMISErrorCodeConnection];
        self.fileUploadFailureBlock(cmisError);
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (self.fileUploadCompletionBlock)
    {
        HTTPResponse *httpResponse = [[HTTPResponse alloc] init];
        httpResponse.data = self.data;
        httpResponse.statusCode = self.statusCode;
        self.fileUploadCompletionBlock(httpResponse);
    }

    if (self.fileUploadCleanupBlock)
    {
        self.fileUploadCleanupBlock();
    }
}

@end