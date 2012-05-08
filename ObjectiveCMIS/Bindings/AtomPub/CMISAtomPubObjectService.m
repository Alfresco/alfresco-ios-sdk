//
//  CMISAtomPubObjectService.m
//
//  Created by Cornwell Gavin on 17/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISAtomPubObjectService.h"
#import "CMISAtomPubBaseService+Protected.h"
#import "HttpUtil.h"
#import "CMISAtomEntryWriter.h"
#import "CMISAtomEntryParser.h"

@interface CMISAtomPubObjectService() <NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSString *filePathForContentRetrieval;
@property (nonatomic, strong) CMISContentRetrievalCompletionBlock fileRetrievalCompletionBlock;
@property (nonatomic, strong) CMISContentRetrievalFailureBlock fileRetrievalFailureBlock;

@end

@implementation CMISAtomPubObjectService

@synthesize filePathForContentRetrieval = _filePathForContentRetrieval;
@synthesize fileRetrievalCompletionBlock = _fileRetrievalCompletionBlock;
@synthesize fileRetrievalFailureBlock = _fileRetrievalFailureBlock;

- (CMISObjectData *)retrieveObject:(NSString *)objectId error:(NSError **)error
{
    return [self retrieveObjectInternal:objectId error:error];
}

- (void)writeContentOfCMISObject:(NSString *)objectId toFile:(NSString *)filePath completionBlock:(CMISContentRetrievalCompletionBlock)completionBlock failureBlock:(CMISContentRetrievalFailureBlock)failureBlock
{
    NSError *objectRetrievalError = nil;
    CMISObjectData *objectData = [self retrieveObjectInternal:objectId error:&objectRetrievalError];

    if (objectRetrievalError)
    {
        log(@"Error while retrieving CMIS object for object id '%@' : %@", objectId, [objectRetrievalError description]);
        if (failureBlock)
        {
            failureBlock(objectRetrievalError);
        }
    }
    else
    {
        self.filePathForContentRetrieval = filePath;
        self.fileRetrievalCompletionBlock = completionBlock;
        self.fileRetrievalFailureBlock = failureBlock;
        [HttpUtil invokeGETAsynchronous:objectData.contentUrl withSession:self.session withDelegate:self];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [[NSFileManager defaultManager] createFileAtPath:self.filePathForContentRetrieval contents:nil attributes:nil];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
  NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:self.filePathForContentRetrieval];

  if (fileHandle) {
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:data];

    // Log out how much data was downloaded
//    log(@"%d bytes downloaded.", [data length]);
  }

  // Always clean up after the file is written to
  [fileHandle closeFile];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (self.fileRetrievalFailureBlock)
    {
        self.fileRetrievalFailureBlock(error);
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
}


- (NSString *)createDocumentFromFilePath:(NSString *)filePath withProperties:(NSDictionary *)properties inFolder:(NSString *)folderObjectId error:(NSError **)error
{
    CMISObjectData *folderData = [self retrieveObjectInternal:folderObjectId error:error];

    if (!*error)
    {
        NSString *downLink = [folderData.links objectForKey:@"down"];
        if (downLink)
        {
            NSURL *downUrl = [NSURL URLWithString:downLink];

            CMISAtomEntryWriter *atomEntryWriter = [[CMISAtomEntryWriter alloc] init];
            atomEntryWriter.filePath = filePath;
            atomEntryWriter.cmisProperties = properties;
            NSData *atomEntry = [atomEntryWriter generateAtomEntry];

            NSData *response = [HttpUtil invokePOSTSynchronous:downUrl
                                         withSession:self.session
                                         body:atomEntry
                                         headers:[NSDictionary dictionaryWithObject:@"application/atom+xml;type=entry" forKey:@"Content-type"]
                                         error:error];

            if (!*error)
            {
                CMISAtomEntryParser *atomEntryParser = [[CMISAtomEntryParser alloc] initWithData:response];
                [atomEntryParser parseAndReturnError:error];
                return atomEntryParser.objectData.identifier;
            }
        }
        else
        {
            log(@"Could not retrieve 'down' link for folder with object id %@", folderObjectId);
        }
    }
    return nil;
}

- (BOOL)deleteObject:(NSString *)objectId allVersions:(BOOL)allVersions error:(NSError * *)error
{
    CMISObjectData *objectData = [self retrieveObjectInternal:objectId error:error];
    if (!*error)
    {
        NSString *selfLink = [objectData.links objectForKey:@"self"];
        if (selfLink)
        {
            NSURL *selfUrl = [NSURL URLWithString:selfLink];
            [HttpUtil invokeDELETESynchronous:selfUrl withSession:self.session error:error];

            if (!*error)
            {
                return YES;
            }
        }
        else
        {
            log(@"Could not retrieve 'self' link for object with object id %@", objectId);
        }
    }
    return NO;
}


@end
