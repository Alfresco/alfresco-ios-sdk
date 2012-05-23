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
    NSError *internalError = nil;
    CMISObjectData *cmisObjData = [self retrieveObjectInternal:objectId error:&internalError];
    if (internalError) {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeObjectNotFound];
    }
    return cmisObjData;
}

- (CMISObjectData *)retrieveObjectByPath:(NSString *)path error:(NSError **)error
{
    NSError *internalError = nil;
    CMISObjectData *cmisObjData = [self retrieveObjectByPathInternal:path error:&internalError];
    if (internalError) {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeObjectNotFound];
    }
    return cmisObjData;
}

- (void)downloadContentOfObject:(NSString *)objectId toFile:(NSString *)filePath completionBlock:(CMISContentRetrievalCompletionBlock)completionBlock failureBlock:(CMISContentRetrievalFailureBlock)failureBlock
{
    NSError *objectRetrievalError = nil;
    CMISObjectData *objectData = [self retrieveObjectInternal:objectId error:&objectRetrievalError];

    if (objectRetrievalError)
    {
        log(@"Error while retrieving CMIS object for object id '%@' : %@", objectId, [objectRetrievalError description]);
        NSError *cmisError = [CMISErrors cmisError:&objectRetrievalError withCMISErrorCode:kCMISErrorCodeObjectNotFound];
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
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
      // Log out how much data was downloaded
//    log(@"%d bytes downloaded.", [data length]);

    [FileUtil appendToFileAtPath:self.filePathForContentRetrieval data:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSError *cmisError = [CMISErrors cmisError:&error withCMISErrorCode:kCMISErrorCodeObjectNotFound];

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
                  withProperties:(CMISProperties *)properties inFolder:(NSString *)folderObjectId error:(NSError * *)error
{
    // Validate properties
    if ([properties propertyValueForId:kCMISPropertyName] == nil || [properties propertyValueForId:kCMISPropertyObjectTypeId] == nil)
    {
        *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument withDetailedDescription:nil];
        log(@"Must provide %@ and %@ as properties", kCMISPropertyName, kCMISPropertyObjectTypeId);
        return nil;
    }

    // Validate mimetype
    if (!mimeType)
    {
        *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument withDetailedDescription:nil];
        log(@"Must provide a mimetype when creating a cmis document");
        return nil;
    }

    // Fetch object
    NSError *internalError = nil;
    CMISObjectData *folderData = [self retrieveObjectInternal:folderObjectId error:&internalError];
    
    if (internalError) {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeObjectNotFound];
        return nil;
    }
    NSString *downLink = [folderData.linkRelations linkHrefForRel:kCMISLinkRelationDown type:kCMISMediaTypeChildren];

    return [self sendAtomEntryXmlToLink:downLink withHttpRequestMethod:HTTP_POST
                         withProperties:properties
                         withContentFilePath:filePath
                         withContentMimeType:mimeType
                         storeInMemory:NO
                         error:error].identifier;
}

- (BOOL)deleteObject:(NSString *)objectId allVersions:(BOOL)allVersions error:(NSError * *)error
{
    NSError *internalError = nil;
    CMISObjectData *objectData = [self retrieveObjectInternal:objectId error:&internalError];
    if (internalError) {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeObjectNotFound];
        return NO;        
    }
    NSString *selfLink = [objectData.linkRelations linkHrefForRel:kCMISLinkRelationSelf];
    if (!selfLink) {
        *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument withDetailedDescription:nil];
        return NO;
    }
    NSURL *selfUrl = [NSURL URLWithString:selfLink];
    [HttpUtil invokeDELETESynchronous:selfUrl withSession:self.session error:&internalError];
    if (internalError) {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeUpdateConflict];
        return NO;
    }
    return YES;
}

- (NSString *)createFolderInParentFolder:(NSString *)folderObjectId withProperties:(CMISProperties *)properties error:(NSError **)error
{
    if ([properties propertyValueForId:kCMISPropertyName] == nil || [properties propertyValueForId:kCMISPropertyObjectTypeId] == nil)
    {
        *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument withDetailedDescription:nil];
        log(@"Must provide %@ and %@ as properties", kCMISPropertyName, kCMISPropertyObjectTypeId);
        return nil;
    }

    // Validate parent folder id
    if (!folderObjectId)
    {
        *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeObjectNotFound withDetailedDescription:nil];
        log(@"Must provide a parent folder object id when creating a new folder");
    }

    // Fetch folder data
    NSError *internalError = nil;
    CMISObjectData *parentFolderData = [self retrieveObjectInternal:folderObjectId error:&internalError];
    if (internalError) {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeObjectNotFound];
        return nil;
    }

    NSString *downLink = [parentFolderData.linkRelations linkHrefForRel:kCMISLinkRelationDown type:kCMISMediaTypeChildren];
    return [self sendAtomEntryXmlToLink:downLink
                         withHttpRequestMethod:HTTP_POST
                         withProperties:properties
                         withContentFilePath:nil
                         withContentMimeType:nil
                         storeInMemory:YES
                         error:error].identifier;
}


- (NSArray *)deleteTree:(NSString *)folderObjectId error:(NSError * *)error
{
    // Validate params
    if (!folderObjectId)
    {
        *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeObjectNotFound withDetailedDescription:nil];
        log(@"Must provide a folder object id when deleting a folder tree");
    }

    // Fetch folder data
    NSError *internalError = nil;
    CMISObjectData *folderData = [self retrieveObjectInternal:folderObjectId error:&internalError];
    if (internalError) {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeObjectNotFound];
        return nil;//should we return nil or an empty array here?
    }

    NSString *folderTreeLink = [folderData.linkRelations linkHrefForRel:kCMISLinkRelationFolderTree];
    [HttpUtil invokeDELETESynchronous:[NSURL URLWithString:folderTreeLink] withSession:self.session error:&internalError];
    
    if (internalError) {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeConnection];
        return nil;//should we return nil or an empty array here?
    }

    // TODO: retrieve failed folders and files and return
    return [NSArray array];
}

- (void)updatePropertiesForObject:(CMISStringInOutParameter *)objectId withProperties:(CMISProperties *)properties
                  withChangeToken:(CMISStringInOutParameter *)changeToken error:(NSError **)error
{
    // Validate params
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

    // Get self link
    NSString *selfLink = [objectData.linkRelations linkHrefForRel:kCMISLinkRelationSelf];

    // Append optional params
    if (changeToken != nil && changeToken.inParameter != nil)
    {
        selfLink = [URLUtil urlStringByAppendingParameter:kCMISParameterChangeToken
                                                withValue:changeToken.inParameter toUrlString:selfLink];
    }

    // Execute request
    [self sendAtomEntryXmlToLink:selfLink
                  withHttpRequestMethod:HTTP_PUT
                  withProperties:properties
                  withContentFilePath:nil
                  withContentMimeType:nil
                  storeInMemory:YES
                  error:error];

    // Create XML needed as body of html

    CMISAtomEntryWriter *xmlWriter = [[CMISAtomEntryWriter alloc] init];
    xmlWriter.cmisProperties = properties;
    xmlWriter.generateXmlInMemory = YES;

    NSError *internalError = nil;
    HTTPResponse *response = [HttpUtil invokePUTSynchronous:[NSURL URLWithString:selfLink]
                                withSession:self.session
                                body:[xmlWriter.generateAtomEntryXml dataUsingEncoding:NSUTF8StringEncoding]
                                headers:[NSDictionary dictionaryWithObject:kCMISMediaTypeEntry forKey:@"Content-type"]
                                error:&internalError];

    // Object id and changeToken might have changed because of this operation
    if (internalError == nil)
    {
        CMISAtomEntryParser *atomEntryParser = [[CMISAtomEntryParser alloc] initWithData:response.data];
        if ([atomEntryParser parseAndReturnError:error])
        {
            objectId.outParameter = [[atomEntryParser.objectData.properties propertyForId:kCMISPropertyObjectId] firstValue];

            if (changeToken != nil)
            {
                changeToken.outParameter = [[atomEntryParser.objectData.properties propertyForId:kCMISPropertyChangeToken] firstValue];
            }
        }
    }
    else
    {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeConnection];
    }
}


#pragma mark Helper methods

- (CMISObjectData *)sendAtomEntryXmlToLink:(NSString *)link
                            withHttpRequestMethod:(HTTPRequestMethod)httpRequestMethod
                            withProperties:(CMISProperties *)properties
                            withContentFilePath:(NSString *)contentFilePath
                            withContentMimeType:(NSString *)contentMimeType
                            storeInMemory:(BOOL)isXmlStoredInMemory
                            error:(NSError * *)error
{
    
    if (link == nil) {
        *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument withDetailedDescription:nil];
        log(@"Could not retrieve link from object to do creation or update");
        return nil;
    }

    NSError *internalError = nil;
    NSURL *url = [NSURL URLWithString:link];
    
    // Atom entry XML can become huge, as the whole file is stored as base64 in the XML itself
    // Hence, we're storing the atom entry xml in a temporary file and stream the body of the http post
    CMISAtomEntryWriter *atomEntryWriter = [[CMISAtomEntryWriter alloc] init];
    atomEntryWriter.contentFilePath = contentFilePath;
    atomEntryWriter.mimeType = contentMimeType;
    atomEntryWriter.cmisProperties = properties;
    atomEntryWriter.generateXmlInMemory = isXmlStoredInMemory;
    NSString *writeResult = [atomEntryWriter generateAtomEntryXml];

    NSData *responseData = nil;
    if (isXmlStoredInMemory)
    {
        responseData = [HttpUtil invokeSynchronous:url
                withHttpMethod:httpRequestMethod
                withSession:self.session
                body:[writeResult dataUsingEncoding:NSUTF8StringEncoding]
                headers:[NSDictionary dictionaryWithObject:kCMISMediaTypeEntry forKey:@"Content-type"]
                error:&internalError].data;
    }
    else
    {
        NSInputStream *bodyStream = [NSInputStream inputStreamWithFileAtPath:writeResult];
        responseData = [HttpUtil invokeSynchronous:url
                                           withHttpMethod:httpRequestMethod
                                           withSession:self.session
                                           bodyStream:bodyStream
                                           headers:[NSDictionary dictionaryWithObject:kCMISMediaTypeEntry forKey:@"Content-type"]
                                           error:&internalError].data;

        // Close stream and delete temporary file
        [bodyStream close];

        [[NSFileManager defaultManager] removeItemAtPath:writeResult error:&internalError];
        if (internalError) {
            *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeStorage];
            return nil;
        }
    }

    if (internalError) {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeConnection];
        return nil;
    }        

    CMISAtomEntryParser *atomEntryParser = [[CMISAtomEntryParser alloc] initWithData:responseData];
    [atomEntryParser parseAndReturnError:&internalError];
    if (internalError) 
    {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeUpdateConflict];
        return nil;
    }
        
    return atomEntryParser.objectData;
}


@end
