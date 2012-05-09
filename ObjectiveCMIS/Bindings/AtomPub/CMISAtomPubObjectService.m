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
#import "FileUtil.h"
#import "CMISConstants.h"

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
      // Log out how much data was downloaded
//    log(@"%d bytes downloaded.", [data length]);

    [FileUtil appendToFileAtPath:self.filePathForContentRetrieval data:data];
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

- (NSString *)createDocumentFromFilePath:(NSString *)filePath withMimeType:(NSString *)mimeType
                  withProperties:(NSDictionary *)properties inFolder:(NSString *)folderObjectId error:(NSError * *)error
{
    // Validate params
    if (!mimeType)
    {
        *error = [[NSError alloc] init];         // TODO: proper init error
        log(@"Must provide a mimetype when creating a cmis document");
    }

    // Fetch object
    CMISObjectData *folderData = [self retrieveObjectInternal:folderObjectId error:error];

    // Use down link to create the document
    if (!*error)
    {
        NSString *downLink = [folderData.links objectForKey:kCMISLinkRelationDown];
        return [self postAtomEntryXmlToDownLink:downLink withProperties:properties withContentFilePath:filePath withContentMimeType:mimeType error:error];
    }
    return nil;
}

- (BOOL)deleteObject:(NSString *)objectId allVersions:(BOOL)allVersions error:(NSError * *)error
{
    CMISObjectData *objectData = [self retrieveObjectInternal:objectId error:error];
    if (!*error)
    {
        NSString *selfLink = [objectData.links objectForKey:kCMISLinkRelationSelf];
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

- (NSString *)createFolderInParentFolder:(NSString *)folderObjectId withProperties:(NSDictionary *)properties error:(NSError **)error
{
      // Validate params
    if (!folderObjectId)
    {
        *error = [[NSError alloc] init];         // TODO: proper init error
        log(@"Must provide a parent folder object id when creating a new folder");
    }

    // Fetch folder data
    CMISObjectData *parentFolderData = [self retrieveObjectInternal:folderObjectId error:error];

    // Use down link to create the folder
    if (*error == nil)
    {
        NSString *downLink = [parentFolderData.links objectForKey:kCMISLinkRelationDown];
        return [self postAtomEntryXmlToDownLink:downLink withProperties:properties withContentFilePath:nil withContentMimeType:nil error:error];
    }
    return nil;
}

- (NSArray *)deleteTree:(NSString *)folderObjectId error:(NSError * *)error
{
    // Validate params
    if (!folderObjectId)
    {
        *error = [[NSError alloc] init];         // TODO: proper init error
        log(@"Must provide a folder object id when deleting a folder tree");
    }

    // Fetch folder data
    CMISObjectData *folderData = [self retrieveObjectInternal:folderObjectId error:error];

    // Use foldertree link to delete the folder and its subfolders
    if (*error == nil)
    {
        NSString *folderTreeLink = [folderData.links objectForKey:kCMISLinkRelationFolderTree];
        [HttpUtil invokeDELETESynchronous:[NSURL URLWithString:folderTreeLink] withSession:self.session error:error];

        // TODO: handle response status code (see opencmis impl)
    }

    // TODO: retrieve failed folders and files and return
    return [NSArray array];
}


#pragma mark Helper methods

- (NSString *)postAtomEntryXmlToDownLink:(NSString *)downLink withProperties:(NSDictionary *)properties
                                                        withContentFilePath:(NSString *)contentFilePath
                                                        withContentMimeType:(NSString *)contentMimeType
                                                        error:(NSError * *)error
{
    // Validate properties
    if ([properties objectForKey:kCMISPropertyName] == nil || [properties objectForKey:kCMISPropertyObjectTypeId] == nil)
    {
        *error = [[NSError alloc] init]; // TODO: proper error initialisation
        log(@"Must provide %@ and %@ as properties", kCMISPropertyName, kCMISPropertyObjectTypeId);
        return nil;
    }

    if (*error == nil && downLink != nil)
    {
        NSURL *downUrl = [NSURL URLWithString:downLink];

        // Atom entry XML can become huge, as the whole file is stored as base64 in the XML itself
        // Hence, we're storing the atom entry xml in a temporary file and stream the body of the http post
        CMISAtomEntryWriter *atomEntryWriter = [[CMISAtomEntryWriter alloc] init];
        atomEntryWriter.contentFilePath = contentFilePath;
        atomEntryWriter.mimeType = contentMimeType;
        atomEntryWriter.cmisProperties = properties;
        NSString *filePathToGeneratedAtomEntry = [atomEntryWriter filePathToGeneratedAtomEntry];

        NSInputStream *bodyStream = [NSInputStream inputStreamWithFileAtPath:filePathToGeneratedAtomEntry];
        NSData *response = [HttpUtil invokePOSTSynchronous:downUrl
                                               withSession:self.session
                                               bodyStream:bodyStream
                                               headers:[NSDictionary dictionaryWithObject:@"application/atom+xml;type=entry" forKey:@"Content-type"]
                                               error:error];

        // Close stream and delete temporary file
        [bodyStream close];

        [[NSFileManager defaultManager] removeItemAtPath:filePathToGeneratedAtomEntry error:error];

        // Parse the returned response (ie the newly created document)
        if (*error == nil)
        {
            CMISAtomEntryParser *atomEntryParser = [[CMISAtomEntryParser alloc] initWithData:response];
            [atomEntryParser parseAndReturnError:error];
            return atomEntryParser.objectData.identifier;
        }
    } else {
        *error = [[NSError alloc] init]; //TODO proper init
        log(@"Could not retrieve 'down' link");
    }
    return nil;
}


@end
