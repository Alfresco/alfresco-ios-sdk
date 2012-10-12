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

#import "CMISFileDownloadDelegate.h"
#import "CMISErrors.h"
#import "CMISFileUtil.h"

@interface CMISFileDownloadDelegate ()

@property unsigned long long bytesTotal;
@property unsigned long long bytesDownloaded;

@end


@implementation CMISFileDownloadDelegate

@synthesize filePathForContentRetrieval = _filePathForContentRetrieval;
@synthesize fileRetrievalCompletionBlock = _fileRetrievalCompletionBlock;
@synthesize fileRetrievalFailureBlock = _fileRetrievalFailureBlock;
@synthesize fileRetrievalProgressBlock = _fileRetrievalProgressBlock;
@synthesize bytesTotal = _bytesTotal;
@synthesize bytesDownloaded = _bytesDownloaded;
@synthesize contentStreamLength = _contentStreamLength;

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // Create file for file that is downloaded
    BOOL fileCreated = [[NSFileManager defaultManager] createFileAtPath:self.filePathForContentRetrieval contents:nil attributes:nil];

    if (!fileCreated)
    {
        [connection cancel];

        if (self.fileRetrievalFailureBlock)
        {
            NSError *cmisError = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeStorage
                    withDetailedDescription:[NSString stringWithFormat:@"Could not create file at path %@", self.filePathForContentRetrieval]];
            self.fileRetrievalFailureBlock(cmisError);
        }
    }
    else
    {
        self.bytesDownloaded = 0;
        if (NSURLResponseUnknownLength == response.expectedContentLength && nil != self.contentStreamLength)
        {
            self.bytesTotal = [self.contentStreamLength unsignedLongLongValue];
        }
        else
        {
            self.bytesTotal = (unsigned long long) response.expectedContentLength;            
        }
        
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [FileUtil appendToFileAtPath:self.filePathForContentRetrieval data:data];

    // Pass progress to progressBlock
    self.bytesDownloaded += data.length;
    if (self.fileRetrievalProgressBlock != nil)
    {
        self.fileRetrievalProgressBlock(self.bytesDownloaded, self.bytesTotal);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (self.fileRetrievalFailureBlock)
    {
        NSError *cmisError = [CMISErrors cmisError:&error withCMISErrorCode:kCMISErrorCodeConnection];
        self.fileRetrievalFailureBlock(cmisError);
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Fire completion to block
    if (self.fileRetrievalCompletionBlock)
    {
        self.fileRetrievalCompletionBlock();
    }

    // Cleanup
    self.filePathForContentRetrieval = nil;
    self.fileRetrievalCompletionBlock = nil;
    self.fileRetrievalFailureBlock = nil;
    self.fileRetrievalProgressBlock = nil;
}

@end