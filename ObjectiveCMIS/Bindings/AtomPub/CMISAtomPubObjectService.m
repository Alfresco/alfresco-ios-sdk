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
#import "CMISConstants.h"
#import "CMISErrors.h"
#import "CMISStringInOutParameter.h"
#import "CMISURLUtil.h"
#import "CMISFileDownloadDelegate.h"
#import "CMISFileUploadDelegate.h"

@implementation CMISAtomPubObjectService

- (CMISObjectData *)retrieveObject:(NSString *)objectId
           withFilter:(NSString *)filter
           andIncludeRelationShips:(CMISIncludeRelationship)includeRelationship
           andIncludePolicyIds:(BOOL)includePolicyIds
           andRenditionFilder:(NSString *)renditionFilter
           andIncludeACL:(BOOL)includeACL
           andIncludeAllowableActions:(BOOL)includeAllowableActions
           error:(NSError * *)error
{
    NSError *internalError = nil;
    CMISObjectData *objData = [self retrieveObjectInternal:objectId
                                         withReturnVersion:LATEST
                                                withFilter:filter
                                   andIncludeRelationShips:includeRelationship
                                       andIncludePolicyIds:includePolicyIds
                                        andRenditionFilder:renditionFilter
                                             andIncludeACL:includeACL
                                andIncludeAllowableActions:includeAllowableActions
                                                     error:&internalError];
    if (internalError)
    {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeObjectNotFound];
    }
    return objData;
}

- (CMISObjectData *)retrieveObjectByPath:(NSString *)path
                              withFilter:(NSString *)filter
                 andIncludeRelationShips:(CMISIncludeRelationship)includeRelationship
                     andIncludePolicyIds:(BOOL)includePolicyIds
                      andRenditionFilder:(NSString *)renditionFilter
                           andIncludeACL:(BOOL)includeACL
              andIncludeAllowableActions:(BOOL)includeAllowableActions
                                   error:(NSError **)error
{
    NSError *internalError = nil;
    CMISObjectData *cmisObjData = [self retrieveObjectByPathInternal:path
                                                          withFilter:filter
                                             andIncludeRelationShips:includeRelationship
                                                 andIncludePolicyIds:includePolicyIds
                                                  andRenditionFilder:renditionFilter
                                                       andIncludeACL:includeACL
                                          andIncludeAllowableActions:includeAllowableActions
                                                               error:&internalError];
    if (internalError) {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeObjectNotFound];
    }
    return cmisObjData;
}

- (void)downloadContentOfObject:(NSString *)objectId
                   withStreamId:(NSString *)streamId
                         toFile:(NSString *)filePath
                completionBlock:(CMISVoidCompletionBlock)completionBlock
                   failureBlock:(CMISErrorFailureBlock)failureBlock
                  progressBlock:(CMISProgressBlock)progressBlock;
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
        // We create a specific delegate object, as potentially multiple threads can be downloading a file.
        CMISFileDownloadDelegate *dataDelegate = [[CMISFileDownloadDelegate alloc] init];
        dataDelegate.filePathForContentRetrieval = filePath;
        dataDelegate.fileRetrievalCompletionBlock = completionBlock;
        dataDelegate.fileRetrievalFailureBlock = failureBlock;
        dataDelegate.fileRetrievalProgressBlock = progressBlock;

        NSURL *contentUrl = objectData.contentUrl;

        // This is not spec-compliant!! Took me half a day to find this in opencmis ...
        if (streamId != nil) {
            contentUrl = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterStreamId withValue:streamId toUrl:contentUrl];
        }

        [HttpUtil invokeGETAsynchronous:contentUrl withSession:self.bindingSession withDelegate:dataDelegate];
    }
}

- (void)deleteContentOfObject:(CMISStringInOutParameter *)objectIdParam withChangeToken:(CMISStringInOutParameter *)changeTokenParam error:(NSError **)error
{
    // Validate object id param
    if (objectIdParam == nil || objectIdParam.inParameter == nil)
    {
        log(@"Object id is nil or inParameter of objectId is nil");
        *error = [[NSError alloc] init]; // TODO: properly init error (CmisInvalidArgumentException)
        return;
    }

    // Get edit media link
    NSString *editMediaLink = [self loadLinkForObjectId:objectIdParam.inParameter andRelation:kCMISLinkEditMedia error:error];
    if (editMediaLink == nil){
        log(@"Could not retrieve %@ link for object '%@'", kCMISLinkEditMedia, objectIdParam.inParameter);
        return;
    }

    // Append optional change token parameters
    if (changeTokenParam != nil && changeTokenParam.inParameter != nil)
    {
        editMediaLink = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterChangeToken
                                                     withValue:changeTokenParam.inParameter toUrlString:editMediaLink];
    }

    [HttpUtil invokeDELETESynchronous:[NSURL URLWithString:editMediaLink] withSession:self.bindingSession error:error];

    // Atompub DOES NOT SUPPORT returning the new object id and change token
    // See http://docs.oasis-open.org/cmis/CMIS/v1.0/cs01/cmis-spec-v1.0.html#_Toc243905498
    objectIdParam.outParameter = nil;
    changeTokenParam.outParameter = nil;
}

- (void)changeContentOfObject:(CMISStringInOutParameter *)objectIdParam toContentOfFile:(NSString *)filePath
        withOverwriteExisting:(BOOL)overwrite withChangeToken:(CMISStringInOutParameter *)changeTokenParam
              completionBlock:(CMISVoidCompletionBlock)completionBlock
                 failureBlock:(CMISErrorFailureBlock)failureBlock
                progressBlock:(CMISProgressBlock)progressBlock
{
    // Validate object id param
    if (objectIdParam == nil || objectIdParam.inParameter == nil)
    {
        log(@"Object id is nil or inParameter of objectId is nil");
        if (failureBlock)
        {
            failureBlock([CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument withDetailedDescription:@"Must provide object id"]);
        }
        return;
    }

    // Validate file path param
    if (filePath == nil || ![[NSFileManager defaultManager] isReadableFileAtPath:filePath])
    {
        log(@"Invalid file path: '%@' is not valid", filePath);
        if (failureBlock)
        {
            if (failureBlock)
            {
                failureBlock([CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument withDetailedDescription:@"Invalid file path"]);
            }
        }
        return;
    }

    // Atompub DOES NOT SUPPORT returning the new object id and change token
    // See http://docs.oasis-open.org/cmis/CMIS/v1.0/cs01/cmis-spec-v1.0.html#_Toc243905498
    objectIdParam.outParameter = nil;
    changeTokenParam.outParameter = nil;

    // Get edit media link
    NSError *internalError = nil;
    NSString *editMediaLink = [self loadLinkForObjectId:objectIdParam.inParameter andRelation:kCMISLinkEditMedia error:&internalError];
    if (editMediaLink == nil){
        log(@"Could not retrieve %@ link for object '%@'", kCMISLinkEditMedia, objectIdParam.inParameter);
        if (failureBlock != nil)
        {
            failureBlock([CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeObjectNotFound]);
        }
        return;
    }

    // Append optional change token parameters
    if (changeTokenParam != nil && changeTokenParam.inParameter != nil)
    {
        editMediaLink = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterChangeToken
                                                     withValue:changeTokenParam.inParameter toUrlString:editMediaLink];
    }

    // Append overwrite flag
    editMediaLink = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterOverwriteFlag
                                                 withValue:(overwrite ? @"true" : @"false") toUrlString:editMediaLink];

    // Create delegate to handle the async file upload
    CMISFileUploadDelegate *uploadDelegate = [[CMISFileUploadDelegate alloc] init];
    uploadDelegate.fileUploadFailureBlock = failureBlock;
    uploadDelegate.fileUploadProgressBlock = progressBlock;
    uploadDelegate.fileUploadCompletionBlock = ^ (HTTPResponse *httpResponse) {

        // Check response status
        if (httpResponse.statusCode != 200 && httpResponse.statusCode != 201 && httpResponse.statusCode != 204)
        {
            log(@"Invalid http response status code when updating content: %d", httpResponse.statusCode);
            if (failureBlock)
            {
                failureBlock([CMISErrors createCMISErrorWithCode:kCMISErrorCodeRuntime
                     withDetailedDescription:[NSString stringWithFormat:@"Could not update content: http status code %d", httpResponse.statusCode]]);
            }
        }
        else {
            if (completionBlock)
            {
                completionBlock();
            }
        }
    };

    // Execute HTTP call on edit media link, passing the a stream to the file
    NSDictionary *additionalHeader = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"attachment; filename=%@",
                                                           [filePath lastPathComponent]] forKey:@"Content-Disposition"];
    [HttpUtil invokePUTAsynchronous:[NSURL URLWithString:editMediaLink]
                                                withSession:self.bindingSession
                                                 bodyStream:[NSInputStream inputStreamWithFileAtPath:filePath]
                                                    headers:additionalHeader
                                               withDelegate:uploadDelegate];
}


- (void)createDocumentFromFilePath:(NSString *)filePath withMimeType:(NSString *)mimeType
                          withProperties:(CMISProperties *)properties inFolder:(NSString *)folderObjectId
                         completionBlock:(CMISStringCompletionBlock)completionBlock
                            failureBlock:(CMISErrorFailureBlock)failureBlock
                           progressBlock:(CMISProgressBlock)progressBlock
{
    // Validate properties
    if ([properties propertyValueForId:kCMISPropertyName] == nil || [properties propertyValueForId:kCMISPropertyObjectTypeId] == nil)
    {
        log(@"Must provide %@ and %@ as properties", kCMISPropertyName, kCMISPropertyObjectTypeId);
        if (failureBlock)
        {
            failureBlock([CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument withDetailedDescription:nil]);
        }
        return;
    }

    // Validate mimetype
    if (!mimeType)
    {
        log(@"Must provide a mimetype when creating a cmis document");
        if (failureBlock)
        {
            failureBlock([CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument withDetailedDescription:nil]);
        }
        return;
    }

    // Get Down link
    NSError *internalError = nil;
    NSString *downLink = [self loadLinkForObjectId:folderObjectId andRelation:kCMISLinkRelationDown
                                             andType:kCMISMediaTypeChildren error:&internalError];
    if (internalError != nil)
    {
        log(@"Could not retrieve down link: %@", [internalError description]);
        if (failureBlock != nil)
        {
            failureBlock([CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeObjectNotFound]);
        }
        return;
    }

    [self asyncSendAtomEntryXmlToLink:downLink withHttpRequestMethod:HTTP_POST
                         withProperties:properties
                         withContentFilePath:filePath
                         withContentMimeType:mimeType
                         storeInMemory:NO
                         completionBlock:completionBlock
                         failureBlock:failureBlock
                         progressBlock:progressBlock];

}

- (BOOL)deleteObject:(NSString *)objectId allVersions:(BOOL)allVersions error:(NSError * *)error
{
    NSError *internalError = nil;
    NSString *selfLink = [self loadLinkForObjectId:objectId andRelation:kCMISLinkRelationSelf error:error];
    if (!selfLink) {
        *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument withDetailedDescription:nil];
        return NO;
    }

    NSURL *selfUrl = [NSURL URLWithString:selfLink];
    [HttpUtil invokeDELETESynchronous:selfUrl withSession:self.bindingSession error:&internalError];

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

    // Get Down link
    NSError *internalError = nil;
    NSString *downLink = [self loadLinkForObjectId:folderObjectId andRelation:kCMISLinkRelationDown
                                             andType:kCMISMediaTypeChildren error:&internalError];
    if (internalError != nil)
    {
        log(@"Could not retrieve down link: %@", [internalError description]);
        return nil;
    }

    return [self syncSendAtomEntryXmlToLink:downLink
                         withHttpRequestMethod:HTTP_POST
                         withProperties:properties
                         withContentFilePath:nil
                         withContentMimeType:nil
                         storeInMemory:YES
                         error:error].identifier;
}


- (NSArray *)deleteTree:(NSString *)folderObjectId
             allVersion:(BOOL)allVersions
          unfileObjects:(CMISUnfileObject)unfileObjects
      continueOnFailure:(BOOL)continueOnFailure
                  error:(NSError * *)error;
{
    // Validate params
    if (!folderObjectId)
    {
        *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeObjectNotFound withDetailedDescription:nil];
        log(@"Must provide a folder object id when deleting a folder tree");
    }

    NSError *internalError = nil;
    NSString *link = [self loadLinkForObjectId:folderObjectId andRelation:kCMISLinkRelationDown andType:kCMISMediaTypeDescendants error:&internalError];

    if (internalError != nil)
    {
        log(@"Error while fetching %@ link : %@", kCMISLinkRelationDown, [internalError description]);
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeRuntime];
    }

    if (link == nil)
    {
        link = [self loadLinkForObjectId:folderObjectId andRelation:kCMISLinkRelationFolderTree error:&internalError];
    }
    if (internalError != nil)
      {
          log(@"Error while fetching %@ link : %@", kCMISLinkRelationFolderTree, [internalError description]);
          *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeRuntime];
      }

    if (link == nil)
    {
        log(@"Could not retrieve %@ nor %@ link", kCMISLinkRelationDown, kCMISLinkRelationFolderTree);
        return nil;
    }

    link = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterAllVersions withValue:(allVersions ? @"true" : @"false") toUrlString:link];
    link = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterUnfileObjects withValue:[CMISEnums stringForUnfileObject:unfileObjects] toUrlString:link];
    link = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterContinueOnFailure withValue:(continueOnFailure ? @"true" : @"false") toUrlString:link];

    [HttpUtil invokeDELETESynchronous:[NSURL URLWithString:link] withSession:self.bindingSession error:&internalError];
    if (internalError) {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeConnection];
        return nil;//should we return nil or an empty array here?
    }

    // TODO: retrieve failed folders and files and return
    return [NSArray array];
}

- (void)updatePropertiesForObject:(CMISStringInOutParameter *)objectIdParam withProperties:(CMISProperties *)properties
                  withChangeToken:(CMISStringInOutParameter *)changeTokenParam error:(NSError **)error
{
    // Validate params
    if (objectIdParam == nil || objectIdParam.inParameter == nil)
    {
        log(@"Object id is nil or inParameter of objectId is nil");
        *error = [[NSError alloc] init]; // TODO: properly init error (CmisInvalidArgumentException)
        return;
    }

    // Get self link
    NSString *selfLink = [self loadLinkForObjectId:objectIdParam.inParameter andRelation:kCMISLinkRelationSelf error:error];
    if (selfLink == nil)
    {
        log(@"Could not retrieve %@ link", kCMISLinkRelationSelf);
        return;
    }

    // Append optional params
    if (changeTokenParam != nil && changeTokenParam.inParameter != nil)
    {
        selfLink = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterChangeToken
                                                withValue:changeTokenParam.inParameter toUrlString:selfLink];
    }

    // Execute request
    [self syncSendAtomEntryXmlToLink:selfLink
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
                                withSession:self.bindingSession
                                body:[xmlWriter.generateAtomEntryXml dataUsingEncoding:NSUTF8StringEncoding]
                                headers:[NSDictionary dictionaryWithObject:kCMISMediaTypeEntry forKey:@"Content-type"]
                                error:&internalError];

    // Object id and changeToken might have changed because of this operation
    if (internalError == nil)
    {
        CMISAtomEntryParser *atomEntryParser = [[CMISAtomEntryParser alloc] initWithData:response.data];
        if ([atomEntryParser parseAndReturnError:error])
        {
            objectIdParam.outParameter = [[atomEntryParser.objectData.properties propertyForId:kCMISPropertyObjectId] firstValue];

            if (changeTokenParam != nil)
            {
                changeTokenParam.outParameter = [[atomEntryParser.objectData.properties propertyForId:kCMISPropertyChangeToken] firstValue];
            }
        }
    }
    else
    {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeConnection];
    }
}


- (NSArray *)retrieveRenditions:(NSString *)objectId withRenditionFilter:(NSString *)renditionFilter
                   withMaxItems:(NSNumber *)maxItems withSkipCount:(NSNumber *)skipCount error:(NSError * *)error;
{
    // Only fetching the bare minimum
    NSError *internalError = nil;
    CMISObjectData *objectData = [self retrieveObjectInternal:objectId withReturnVersion:LATEST withFilter:kCMISPropertyObjectId
                andIncludeRelationShips:CMISIncludeRelationshipNone andIncludePolicyIds:NO
                andRenditionFilder:renditionFilter andIncludeACL:NO andIncludeAllowableActions:NO error:&internalError];

    if (internalError != nil)
    {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeObjectNotFound];
        return nil;
    }

    return objectData.renditions;
}


#pragma mark Helper methods

- (CMISObjectData *)syncSendAtomEntryXmlToLink:(NSString *)link
                            withHttpRequestMethod:(CMISHttpRequestMethod)httpRequestMethod
                            withProperties:(CMISProperties *)properties
                            withContentFilePath:(NSString *)contentFilePath
                            withContentMimeType:(NSString *)contentMimeType
                            storeInMemory:(BOOL)isXmlStoredInMemory
                            error:(NSError * *)error
{
    // Validate params
    if (link == nil) {
        *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument withDetailedDescription:nil];
        log(@"Could not retrieve link from object to do creation or update");
        return nil;
    }

    // Generate XML
    NSString *writeResult = [self createAtomEntryWriter:properties contentFilePath:contentFilePath
        contentMimeType:contentMimeType isXmlStoredInMemory:isXmlStoredInMemory];

    // Execute call
    NSURL *url = [NSURL URLWithString:link];
    NSError *internalError = nil;
    NSData *responseData = nil;
    if (isXmlStoredInMemory)
    {
        responseData = [HttpUtil invokeSynchronous:url
                withHttpMethod:httpRequestMethod
                withSession:self.bindingSession
                body:[writeResult dataUsingEncoding:NSUTF8StringEncoding]
                headers:[NSDictionary dictionaryWithObject:kCMISMediaTypeEntry forKey:@"Content-type"]
                error:&internalError].data;
    }
    else
    {
        NSInputStream *bodyStream = [NSInputStream inputStreamWithFileAtPath:writeResult];
        responseData = [HttpUtil invokeSynchronous:url
                                           withHttpMethod:httpRequestMethod
                                           withSession:self.bindingSession
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

- (void)asyncSendAtomEntryXmlToLink:(NSString *)link
                    withHttpRequestMethod:(CMISHttpRequestMethod)httpRequestMethod
                    withProperties:(CMISProperties *)properties
                    withContentFilePath:(NSString *)contentFilePath
                    withContentMimeType:(NSString *)contentMimeType
                    storeInMemory:(BOOL)isXmlStoredInMemory
                    completionBlock:(CMISStringCompletionBlock)completionBlock
                    failureBlock:(CMISErrorFailureBlock)failureBlock
                    progressBlock:(CMISProgressBlock)progressBlock;
{
    // Validate param
    if (link == nil) {
        log(@"Could not retrieve link from object to do creation or update");
        if (failureBlock)
        {
            failureBlock([CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument withDetailedDescription:nil]);
        }
        return;
    }

    // Generate XML
    NSString *writeResult = [self createAtomEntryWriter:properties contentFilePath:contentFilePath
            contentMimeType:contentMimeType isXmlStoredInMemory:isXmlStoredInMemory];

    // Create delegate object for the asynchronous POST HTTP call
    CMISFileUploadDelegate *uploadDelegate = [self createFileUploadDelegateForFilePath:contentFilePath
                     withCompletionBlock:completionBlock withFailureBlock:failureBlock withProgressBlock:progressBlock];

    // Start the asynchronous POST http call
    NSURL *url = [NSURL URLWithString:link];
    if (isXmlStoredInMemory)
    {
        [self asyncSendXMLInMemory:url body:writeResult uploadDelegate:uploadDelegate];
    }
    else
    {
        [self asyncSendXMLUsingTempFile:url tempFilePath:writeResult failureBlock:failureBlock uploadDelegate:uploadDelegate];
    }
}

/**
 * Helper method: creates a writer for the xml needed to upload a file.
 * The atom entry XML can become huge, as the whole file is stored as base64 in the XML itself
 * Hence, we're allowing to store the atom entry xml in a temporary file and stream the body of the http post
 */
- (NSString *)createAtomEntryWriter:(CMISProperties *)properties contentFilePath:(NSString *)contentFilePath contentMimeType:(NSString *)contentMimeType isXmlStoredInMemory:(BOOL)isXmlStoredInMemory
{

    CMISAtomEntryWriter *atomEntryWriter = [[CMISAtomEntryWriter alloc] init];
    atomEntryWriter.contentFilePath = contentFilePath;
    atomEntryWriter.mimeType = contentMimeType;
    atomEntryWriter.cmisProperties = properties;
    atomEntryWriter.generateXmlInMemory = isXmlStoredInMemory;
    NSString *writeResult = [atomEntryWriter generateAtomEntryXml];
    return writeResult;
}

/**
 * Helper method: creates a CMISFileUploadDelegate object to handle the asynchronous upload
 */
- (CMISFileUploadDelegate *)createFileUploadDelegateForFilePath:(NSString *)filePath
                                            withCompletionBlock:(CMISStringCompletionBlock)completionBlock
                                               withFailureBlock:(CMISErrorFailureBlock)failureBlock
                                              withProgressBlock:(CMISProgressBlock)progressBlock
{
    CMISFileUploadDelegate *uploadDelegate = [[CMISFileUploadDelegate alloc] init];
    uploadDelegate.fileUploadFailureBlock = failureBlock;
    uploadDelegate.fileUploadProgressBlock = progressBlock;
    uploadDelegate.fileUploadCompletionBlock = ^(HTTPResponse *response)
    {
        if (completionBlock)
        {
            NSError *parseError = nil;
            CMISAtomEntryParser *atomEntryParser = [[CMISAtomEntryParser alloc] initWithData:response.data];
            [atomEntryParser parseAndReturnError:&parseError];
            if (parseError)
            {
                log(@"Error while parsing response: %@", [parseError description]);
                if (failureBlock)
                {
                    failureBlock([CMISErrors cmisError:&parseError withCMISErrorCode:kCMISErrorCodeUpdateConflict]);
                }
            }

            if (completionBlock)
            {
                completionBlock(atomEntryParser.objectData.identifier);
            }
        }
    };

    // We set the expected bytes Explicitely. In case the call is done using an Inputstream, NSURLConnection
    // would not be able to determine the file size.
    NSError *fileSizeError = nil;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&fileSizeError];

    if (fileSizeError == nil)
    {
        uploadDelegate.bytesExpected = [fileAttributes objectForKey:NSFileSize];
    }
    else
    {
        log(@"Could not determine file size of %@ : %@", filePath, [fileSizeError description]);
        if (failureBlock)
        {
            failureBlock(fileSizeError);
            return nil;
        }
    }

    return uploadDelegate;
}

/**
 * Helper method to send the xml (in memory) to the given url.
 */
- (void)asyncSendXMLInMemory:(NSURL *)url body:(NSString *)writeResult uploadDelegate:(CMISFileUploadDelegate *)uploadDelegate
{
    [HttpUtil invokePOSTAsynchronous:url
                      withSession:self.bindingSession
                      body:[writeResult dataUsingEncoding:NSUTF8StringEncoding]
                      headers:[NSDictionary dictionaryWithObject:kCMISMediaTypeEntry forKey:@"Content-type"]
                      withDelegate:uploadDelegate];
}

/**
 * Helper method to send the xml using a temporary file to the given url.
 */
- (void)asyncSendXMLUsingTempFile:(NSURL *)url tempFilePath:(NSString *)tempFilePath
                failureBlock:(CMISErrorFailureBlock)failureBlock uploadDelegate:(CMISFileUploadDelegate *)uploadDelegate
{
    NSInputStream *bodyStream = [NSInputStream inputStreamWithFileAtPath:tempFilePath];

    // Add cleanup block to close stream to input file and delete temporary file (after upload completion)
    uploadDelegate.fileUploadCleanupBlock = ^
    {
        // Close stream
        [bodyStream close];

        // Remove temp file
        NSError *internalError = nil;
        [[NSFileManager defaultManager] removeItemAtPath:tempFilePath error:&internalError];
        if (internalError)
        {
            if (failureBlock)
            {
                failureBlock([CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeStorage]);
            }
            return;
        }
    };

    [HttpUtil invokePOSTAsynchronous:url withSession:self.bindingSession
                          bodyStream:bodyStream
                          headers:[NSDictionary dictionaryWithObject:kCMISMediaTypeEntry forKey:@"Content-type"]
                          withDelegate:uploadDelegate];
}


@end
