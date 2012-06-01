//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

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