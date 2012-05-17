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
#import "CMISStringInOutParameter.h"
#import "CMISURLUtil.h"

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

- (CMISObjectData *)retrieveObjectByPath:(NSString *)path error:(NSError **)error
{
    return [self retrieveObjectByPathInternal:path error:error];
}

- (void)downloadContentOfObject:(NSString *)objectId toFile:(NSString *)filePath completionBlock:(CMISContentRetrievalCompletionBlock)completionBlock failureBlock:(CMISContentRetrievalFailureBlock)failureBlock
{
    NSError *objectRetrievalError = nil;
    CMISObjectData *objectData = [self retrieveObjectInternal:objectId error:&objectRetrievalError];

    if (objectRetrievalError)
    {
        log(@"Error while retrieving CMIS object for object id '%@' : %@", objectId, [objectRetrievalError description]);
        NSError *cmisError = [CMISErrors cmisError:&objectRetrievalError withCMISErrorCode:kCMISObjectNotFoundError withCMISLocalizedDescription:kCMISObjectNotFoundErrorDescription];
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
    NSError *cmisError = [CMISErrors cmisError:&error withCMISErrorCode:kCMISObjectNotFoundError withCMISLocalizedDescription:kCMISObjectNotFoundErrorDescription];

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

- (void)deleteContentOfObject:(CMISStringInOutParameter *)objectId withChangeToken:(CMISStringInOutParameter *)changeToken error:(NSError **)error
{
    // Validate object id param
    if (objectId == nil || objectId.inParameter == nil)
    {
        log(@"Object id is nil or inParameter of objectId is nil");
        *error = [[NSError alloc] init]; // TODO: properly init error (CmisInvalidArgumentException)
        return;
    }

        // Get object data
    CMISObjectData *objectData = [self retrieveObjectInternal:objectId.inParameter error:error];
    if (objectData == nil || (error != NULL && *error != nil))
    {
        log(@"Could not retrieve object with id %@", objectId.inParameter);
        *error = [[NSError alloc] init]; // TODO: properly init error (CmisInvalidArgumentException)
        return;
    }

    // Get edit media link
    NSString *editMediaLink = [objectData.linkRelations linkHrefForRel:kCMISLinkEditMedia];

    // Append optional change token parameters
    if (changeToken != nil && changeToken.inParameter != nil)
    {
        editMediaLink = [URLUtil urlStringByAppendingParameter:kCMISParameterChangeToken
                                                     withValue:changeToken.inParameter toUrlString:editMediaLink];
    }

    [HttpUtil invokeDELETESynchronous:[NSURL URLWithString:editMediaLink] withSession:self.session error:error];

    // Atompub DOES NOT SUPPORT returning the new object id and change token
    // See http://docs.oasis-open.org/cmis/CMIS/v1.0/cs01/cmis-spec-v1.0.html#_Toc243905498
    objectId.outParameter = nil;
    changeToken.outParameter = nil;
}

- (void)changeContentOfObject:(CMISStringInOutParameter *)objectId toContentOfFile:(NSString *)filePath
        withOverwriteExisting:(BOOL)overwrite withChangeToken:(CMISStringInOutParameter *)changeToken error:(NSError **)error
{
    // Validate object id param
    if (objectId == nil || objectId.inParameter == nil)
    {
        log(@"Object id is nil or inParameter of objectId is nil");
        *error = [[NSError alloc] init]; // TODO: properly init error (CmisInvalidArgumentException)
        return;
    }

    // Validate file path param
    if (filePath == nil || ![[NSFileManager defaultManager] isReadableFileAtPath:filePath])
    {
        log(@"Invalid file path: '%@' is not valid", filePath);
        *error = [[NSError alloc] init]; // TODO: properly init error (CmisInvalidArgumentException)
        return;
    }

    // Get object data
    CMISObjectData *objectData = [self retrieveObjectInternal:objectId.inParameter error:error];
    if (objectData == nil || (error != NULL && *error != nil))
    {
        log(@"Could not retrieve object with id %@", objectId.inParameter);
        *error = [[NSError alloc] init]; // TODO: properly init error (CmisInvalidArgumentException)
        return;
    }

    // Get edit media link
    NSString *editMediaLink = [objectData.linkRelations linkHrefForRel:kCMISLinkEditMedia];

    // Append optional change token parameters
    if (changeToken != nil && changeToken.inParameter != nil)
    {
        editMediaLink = [URLUtil urlStringByAppendingParameter:kCMISParameterChangeToken
                                                     withValue:changeToken.inParameter toUrlString:editMediaLink];
    }

    // Append overwrite flag
    editMediaLink = [URLUtil urlStringByAppendingParameter:kCMISParameterOverwriteFlag
                                                 withValue:(overwrite ? @"true" : @"false") toUrlString:editMediaLink];

    // Execute HTTP call on edit media link, passing the a stream to the file
    NSDictionary *additionalHeader = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"attachment; filename=%@", [filePath lastPathComponent]] forKey:@"Content-Disposition"];
    HTTPResponse *response = [HttpUtil invokePUTSynchronous:[NSURL URLWithString:editMediaLink]
                               withSession:self.session
                               bodyStream:[NSInputStream inputStreamWithFileAtPath:filePath]
                               headers:additionalHeader
                               error:error];

    // Check response status
    if (response.statusCode != 200 && response.statusCode != 201 && response.statusCode != 204)
    {
        log(@"Invalid http response status code when updating content: %d", response.statusCode);
        *error = [[NSError alloc] init]; // TODO: properly init error (CmisInvalidArgumentException)
        return;
    }

    // Atompub DOES NOT SUPPORT returning the new object id and change token
    // See http://docs.oasis-open.org/cmis/CMIS/v1.0/cs01/cmis-spec-v1.0.html#_Toc243905498
    objectId.outParameter = nil;
    changeToken.outParameter = nil;
}


- (NSString *)createDocumentFromFilePath:(NSString *)filePath withMimeType:(NSString *)mimeType
                  withProperties:(NSDictionary *)properties inFolder:(NSString *)folderObjectId error:(NSError * *)error
{
    // Validate params
    if (!mimeType)
    {
        NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
        [errorInfo setObject:NSLocalizedString(kCMISInvalidArgumentErrorDescription, kCMISInvalidArgumentErrorDescription) forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:kCMISErrorDomainName code:kCMISInvalidArgumentError userInfo:errorInfo];         
        // TODO: proper init error
        log(@"Must provide a mimetype when creating a cmis document");
        return nil;
    }

    // Fetch object
    NSError *internalError = nil;
    CMISObjectData *folderData = [self retrieveObjectInternal:folderObjectId error:&internalError];
    
    if (internalError) {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISObjectNotFoundError withCMISLocalizedDescription:kCMISObjectNotFoundErrorDescription];
        return nil;
    }
    NSString *downLink = [folderData.linkRelations linkHrefForRel:kCMISLinkRelationDown type:kCMISMediaTypeChildren];
    //[folderData.links objectForKey:kCMISLinkRelationDown];
    return [self postAtomEntryXmlToDownLink:downLink withProperties:properties withContentFilePath:filePath withContentMimeType:mimeType error:error];

}

- (BOOL)deleteObject:(NSString *)objectId allVersions:(BOOL)allVersions error:(NSError * *)error
{
    NSError *internalError = nil;
    CMISObjectData *objectData = [self retrieveObjectInternal:objectId error:&internalError];
    if (internalError) {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISObjectNotFoundError withCMISLocalizedDescription:kCMISObjectNotFoundErrorDescription];
        return NO;        
    }
    NSString *selfLink = [objectData.linkRelations linkHrefForRel:kCMISLinkRelationSelf];
    if (!selfLink) {
        NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
        [errorInfo setValue:NSLocalizedString(kCMISInvalidArgumentErrorDescription, kCMISInvalidArgumentErrorDescription) forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:kCMISErrorDomainName code:kCMISInvalidArgumentError userInfo:errorInfo];
        return NO;
    }
    NSURL *selfUrl = [NSURL URLWithString:selfLink];
    [HttpUtil invokeDELETESynchronous:selfUrl withSession:self.session error:&internalError];
    if (internalError) {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISUpdateConflictError withCMISLocalizedDescription:kCMISUpdateConflictErrorDescription];
        return NO;
    }
    return YES;
}

- (NSString *)createFolderInParentFolder:(NSString *)folderObjectId withProperties:(NSDictionary *)properties error:(NSError **)error
{
      // Validate params
    if (!folderObjectId)
    {
        NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
        [errorInfo setObject:NSLocalizedString(kCMISObjectNotFoundErrorDescription, kCMISObjectNotFoundErrorDescription) forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:kCMISErrorDomainName code:kCMISObjectNotFoundError userInfo:errorInfo];         
        log(@"Must provide a parent folder object id when creating a new folder");
    }

    // Fetch folder data
    NSError *internalError = nil;
    CMISObjectData *parentFolderData = [self retrieveObjectInternal:folderObjectId error:&internalError];
    if (internalError) {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISObjectNotFoundError withCMISLocalizedDescription:kCMISObjectNotFoundErrorDescription];
        return nil;
    }

    NSString *downLink = [parentFolderData.linkRelations linkHrefForRel:kCMISLinkRelationDown type:kCMISMediaTypeChildren];
    return [self postAtomEntryXmlToDownLink:downLink withProperties:properties withContentFilePath:nil withContentMimeType:nil error:error];
}


- (NSArray *)deleteTree:(NSString *)folderObjectId error:(NSError * *)error
{
    // Validate params
    if (!folderObjectId)
    {
        NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
        [errorInfo setObject:NSLocalizedString(kCMISObjectNotFoundErrorDescription, kCMISObjectNotFoundErrorDescription) forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:kCMISErrorDomainName code:kCMISObjectNotFoundError userInfo:errorInfo];         
        log(@"Must provide a folder object id when deleting a folder tree");
    }

    // Fetch folder data
    NSError *internalError = nil;
    CMISObjectData *folderData = [self retrieveObjectInternal:folderObjectId error:&internalError];
    if (internalError) {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISObjectNotFoundError withCMISLocalizedDescription:kCMISObjectNotFoundErrorDescription];
        return nil;//should we return nil or an empty array here?
    }

    NSString *folderTreeLink = [folderData.linkRelations linkHrefForRel:kCMISLinkRelationFolderTree];
    [HttpUtil invokeDELETESynchronous:[NSURL URLWithString:folderTreeLink] withSession:self.session error:&internalError];
    
    if (internalError) {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISConnectionError withCMISLocalizedDescription:kCMISConnectionErrorDescription];
        return nil;//should we return nil or an empty array here?
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
        NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
        [errorInfo setObject:NSLocalizedString(kCMISInvalidArgumentErrorDescription, kCMISInvalidArgumentErrorDescription) forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:kCMISErrorDomainName code:kCMISInvalidArgumentError userInfo:errorInfo];         
        log(@"Must provide %@ and %@ as properties", kCMISPropertyName, kCMISPropertyObjectTypeId);
        return nil;
    }
    
    if (downLink == nil) {
        NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
        [errorInfo setObject:NSLocalizedString(kCMISInvalidArgumentErrorDescription, kCMISInvalidArgumentErrorDescription) forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:kCMISErrorDomainName code:kCMISInvalidArgumentError userInfo:errorInfo];         
        log(@"Could not retrieve 'down' link");
        return nil;
    }

    NSError *internalError = nil;
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
                                                 error:&internalError].data;
    
    // Close stream and delete temporary file
    [bodyStream close];
    if (internalError) {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISConnectionError withCMISLocalizedDescription:kCMISConnectionErrorDescription];
        return nil;
    }        
    
    [[NSFileManager defaultManager] removeItemAtPath:filePathToGeneratedAtomEntry error:&internalError];
    if (internalError) {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISStorageError withCMISLocalizedDescription:kCMISStorageErrorDescription];
        return nil;
    }
    CMISAtomEntryParser *atomEntryParser = [[CMISAtomEntryParser alloc] initWithData:response];
    [atomEntryParser parseAndReturnError:&internalError];
    if (internalError) 
    {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISUpdateConflictError withCMISLocalizedDescription:kCMISUpdateConflictErrorDescription];
        return nil;
    }
        
    return atomEntryParser.objectData.identifier;
                        

}


@end
