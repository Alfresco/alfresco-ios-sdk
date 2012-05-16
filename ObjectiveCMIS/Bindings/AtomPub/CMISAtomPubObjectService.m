//
//  CMISAtomPubObjectService.m
//
//  Created by Cornwell Gavin on 17/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISAtomPubObjectService.h"
#import "CMISAtomPubBaseService+Protected.h"
#import "CMISHttpUtil.h"
#import "CMISAtomEntryWriter.h"
#import "CMISAtomEntryParser.h"
#import "CMISFileUtil.h"
#import "CMISConstants.h"
#import "CMISErrors.h"

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

- (void)downloadContentOfCMISObject:(NSString *)objectId toFile:(NSString *)filePath completionBlock:(CMISContentRetrievalCompletionBlock)completionBlock failureBlock:(CMISContentRetrievalFailureBlock)failureBlock
{
    NSError *objectRetrievalError = nil;
    CMISObjectData *objectData = [self retrieveObjectInternal:objectId error:&objectRetrievalError];

    if (objectRetrievalError)
    {
        log(@"Error while retrieving CMIS object for object id '%@' : %@", objectId, [objectRetrievalError description]);
        NSMutableDictionary *errorInfo = [NSMutableDictionary dictionaryWithCapacity:[[[objectRetrievalError userInfo]allKeys]count]];
        [errorInfo setDictionary:[objectRetrievalError userInfo]];
        [errorInfo setObject:NSLocalizedString(kCMISObjectNotFoundErrorDescription, kCMISObjectNotFoundErrorDescription) forKey:NSLocalizedDescriptionKey];
        [errorInfo setObject:[NSString stringWithFormat:@"Error while retrieving CMIS object for object id '%@'", objectId] forKey:NSLocalizedFailureReasonErrorKey];
        NSError *cmisError = [NSError errorWithDomain:kCMISErrorDomainName code:kCMISObjectNotFoundError userInfo:errorInfo];
        
        if (failureBlock)
        {
            failureBlock(cmisError);
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
    NSMutableDictionary *errorInfo = [NSMutableDictionary dictionaryWithCapacity:[[[error userInfo]allKeys]count]];
    [errorInfo setDictionary:[error userInfo]];
    [errorInfo setObject:NSLocalizedString(kCMISConstraintErrorDescription, kCMISConstraintErrorDescription) forKey:NSLocalizedDescriptionKey];
    [errorInfo setObject:@"Requesting object deletion asynchronously failed" forKey:NSLocalizedFailureReasonErrorKey];
    NSError *cmisError = [NSError errorWithDomain:kCMISErrorDomainName code:kCMISConstraintError userInfo:errorInfo];                 

    if (self.fileRetrievalFailureBlock)
    {
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
}

- (NSString *)createDocumentFromFilePath:(NSString *)filePath withMimeType:(NSString *)mimeType
                  withProperties:(NSDictionary *)properties inFolder:(NSString *)folderObjectId error:(NSError * *)error
{
    // Validate params
    if (!mimeType)
    {
        NSMutableDictionary *errorInfo = [NSMutableDictionary dictionaryWithCapacity:[[[*error userInfo]allKeys]count]];
        [errorInfo setDictionary:[*error userInfo]];
        [errorInfo setObject:NSLocalizedString(kCMISConstraintErrorDescription, kCMISConstraintErrorDescription) forKey:NSLocalizedDescriptionKey];
        [errorInfo setObject:@"Mime Type is missing" forKey:NSLocalizedFailureReasonErrorKey];
        *error = [NSError errorWithDomain:kCMISErrorDomainName code:kCMISConstraintError userInfo:errorInfo];         
        // TODO: proper init error
        log(@"Must provide a mimetype when creating a cmis document");
    }

    // Fetch object
    CMISObjectData *folderData = [self retrieveObjectInternal:folderObjectId error:error];

    // Use down link to create the document
    if (!*error)
    {
        NSString *downLink = [folderData.linkRelations linkHrefForRel:kCMISLinkRelationDown type:kCMISMediaTypeChildren];
        //[folderData.links objectForKey:kCMISLinkRelationDown];
        return [self postAtomEntryXmlToDownLink:downLink withProperties:properties withContentFilePath:filePath withContentMimeType:mimeType error:error];
    }
    else 
    {
        //TODO handle error
    }
    return nil;
}

- (BOOL)deleteObject:(NSString *)objectId allVersions:(BOOL)allVersions error:(NSError * *)error
{
    NSError *retrieveError = nil;
    CMISObjectData *objectData = [self retrieveObjectInternal:objectId error:&retrieveError];
    if (!retrieveError)
    {
        NSString *selfLink = [objectData.linkRelations linkHrefForRel:kCMISLinkRelationSelf];
        if (selfLink)
        {
            NSURL *selfUrl = [NSURL URLWithString:selfLink];
            [HttpUtil invokeDELETESynchronous:selfUrl withSession:self.session error:&retrieveError];

            if (!retrieveError)
            {
                return YES;
            }
            else
            {
                NSMutableDictionary *errorInfo = [NSMutableDictionary dictionaryWithCapacity:[[[retrieveError userInfo]allKeys]count]];
                [errorInfo setDictionary:[retrieveError userInfo]];
                [errorInfo setObject:NSLocalizedString(kCMISConstraintErrorDescription, kCMISConstraintErrorDescription) forKey:NSLocalizedDescriptionKey];
                [errorInfo setObject:@"Error deleting object in repository" forKey:NSLocalizedFailureReasonErrorKey];
                *error = [NSError errorWithDomain:kCMISErrorDomainName code:kCMISConstraintError userInfo:errorInfo];                 
            }
        }
        else
        {
            log(@"Could not retrieve 'self' link for object with object id %@", objectId);
        }
    }
    else
    {
        NSMutableDictionary *errorInfo = [NSMutableDictionary dictionaryWithCapacity:[[[retrieveError userInfo]allKeys]count]];
        [errorInfo setDictionary:[retrieveError userInfo]];
        [errorInfo setObject:NSLocalizedString(kCMISConstraintErrorDescription, kCMISConstraintErrorDescription) forKey:NSLocalizedDescriptionKey];
        [errorInfo setObject:@"Error retrieving the Object to be deleted" forKey:NSLocalizedFailureReasonErrorKey];
        *error = [NSError errorWithDomain:kCMISErrorDomainName code:kCMISConstraintError userInfo:errorInfo];                 
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
        NSString *downLink = [parentFolderData.linkRelations linkHrefForRel:kCMISLinkRelationDown type:kCMISMediaTypeChildren];
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
        NSString *folderTreeLink = [folderData.linkRelations linkHrefForRel:kCMISLinkRelationFolderTree];
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
                                               headers:[NSDictionary dictionaryWithObject:kCMISMediaTypeEntry forKey:@"Content-type"]
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
