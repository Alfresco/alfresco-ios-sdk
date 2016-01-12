/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import "CMISBrowserObjectService.h"
#import "CMISRequest.h"
#import "CMISHttpResponse.h"
#import "CMISConstants.h"
#import "CMISBrowserUtil.h"
#import "CMISBrowserConstants.h"
#import "CMISURLUtil.h"
#import "CMISFileUtil.h"
#import "CMISErrors.h"
#import "CMISLog.h"
#import "CMISBroswerFormDataWriter.h"
#import "CMISStringInOutParameter.h"

@implementation CMISBrowserObjectService

- (CMISRequest*)retrieveObject:(NSString *)objectId
                        filter:(NSString *)filter
                 relationships:(CMISIncludeRelationship)relationships
              includePolicyIds:(BOOL)includePolicyIds
               renditionFilter:(NSString *)renditionFilter
                    includeACL:(BOOL)includeACL
       includeAllowableActions:(BOOL)includeAllowableActions
               completionBlock:(void (^)(CMISObjectData *objectData, NSError *error))completionBlock
{
    NSString *objectUrl = [self retrieveObjectUrlForObjectWithId:objectId selector:kCMISBrowserJSONSelectorObject];
    objectUrl = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterFilter value:filter urlString:objectUrl];
    objectUrl = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterIncludeAllowableActions boolValue:includeAllowableActions urlString:objectUrl];
    objectUrl = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterIncludeRelationships value:[CMISEnums stringForIncludeRelationShip:relationships] urlString:objectUrl];
    objectUrl = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterRenditionFilter value:renditionFilter urlString:objectUrl];
    objectUrl = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterIncludePolicyIds boolValue:includePolicyIds urlString:objectUrl];
    objectUrl = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterIncludeAcl boolValue:includeACL urlString:objectUrl];
    objectUrl = [CMISURLUtil urlStringByAppendingParameter:kCMISBrowserJSONParameterSuccinct value:kCMISParameterValueTrue urlString:objectUrl];
    
    CMISRequest *cmisRequest = [[CMISRequest alloc] init];
    
    [self.bindingSession.networkProvider invokeGET:[NSURL URLWithString:objectUrl]
                                           session:self.bindingSession
                                       cmisRequest:cmisRequest
                                   completionBlock:^(CMISHttpResponse *httpResponse, NSError *error) {
                                       if (httpResponse.statusCode == 200 && httpResponse.data) {
                                           CMISBrowserTypeCache *typeCache = [[CMISBrowserTypeCache alloc] initWithRepositoryId:self.bindingSession.repositoryId bindingService:self];
                                           [CMISBrowserUtil objectDataFromJSONData:httpResponse.data typeCache:typeCache completionBlock:^(CMISObjectData *objectData, NSError *error) {
                                               if (error) {
                                                   completionBlock(nil, error);
                                               } else {
                                                   completionBlock(objectData, nil);
                                               }
                                           }];
                                           
                                       } else {
                                           completionBlock(nil, error);
                                       }
                                   }];
    
    return cmisRequest;
}

- (CMISRequest*)retrieveObjectByPath:(NSString *)path
                              filter:(NSString *)filter
                       relationships:(CMISIncludeRelationship)relationships
                    includePolicyIds:(BOOL)includePolicyIds
                     renditionFilter:(NSString *)renditionFilter
                          includeACL:(BOOL)includeACL
             includeAllowableActions:(BOOL)includeAllowableActions
                     completionBlock:(void (^)(CMISObjectData *objectData, NSError *error))completionBlock
{
    NSString *objectUrl = [self retrieveObjectUrlForObjectWithPath:path selector:kCMISBrowserJSONSelectorObject];
    objectUrl = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterFilter value:filter urlString:objectUrl];
    objectUrl = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterIncludeAllowableActions boolValue:includeAllowableActions urlString:objectUrl];
    objectUrl = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterIncludeRelationships value:[CMISEnums stringForIncludeRelationShip:relationships] urlString:objectUrl];
    objectUrl = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterRenditionFilter value:renditionFilter urlString:objectUrl];
    objectUrl = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterIncludePolicyIds boolValue:includePolicyIds urlString:objectUrl];
    objectUrl = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterIncludeAcl boolValue:includeACL urlString:objectUrl];
    objectUrl = [CMISURLUtil urlStringByAppendingParameter:kCMISBrowserJSONParameterSuccinct value:kCMISParameterValueTrue urlString:objectUrl];
    
    CMISRequest *cmisRequest = [[CMISRequest alloc] init];
    
    [self.bindingSession.networkProvider invokeGET:[NSURL URLWithString:objectUrl]
                                           session:self.bindingSession
                                       cmisRequest:cmisRequest
                                   completionBlock:^(CMISHttpResponse *httpResponse, NSError *error) {
                                       if (httpResponse.statusCode == 200 && httpResponse.data) {
                                           CMISBrowserTypeCache *typeCache = [[CMISBrowserTypeCache alloc] initWithRepositoryId:self.bindingSession.repositoryId bindingService:self];
                                           [CMISBrowserUtil objectDataFromJSONData:httpResponse.data typeCache:typeCache completionBlock:^(CMISObjectData *objectData, NSError *error) {
                                               if (error) {
                                                   completionBlock(nil, error);
                                               } else {
                                                   completionBlock(objectData, nil);
                                               }
                                           }];
                                          
                                       } else {
                                           completionBlock(nil, error);
                                       }
                                   }];
    
    return cmisRequest;
}

- (CMISRequest*)downloadContentOfObject:(NSString *)objectId
                               streamId:(NSString *)streamId
                                 toFile:(NSString *)filePath
                        completionBlock:(void (^)(NSError *error))completionBlock
                          progressBlock:(void (^)(unsigned long long bytesDownloaded, unsigned long long bytesTotal))progressBlock
{
    CMISRequest *request = [[CMISRequest alloc] init];
    
    NSString *rootUrl = [self.bindingSession objectForKey:kCMISBrowserBindingSessionKeyRootFolderUrl];
    
    NSString *contentUrl = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterStreamId value:streamId urlString:rootUrl];
    contentUrl = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterObjectId value:objectId urlString:contentUrl];
    contentUrl = [CMISURLUtil urlStringByAppendingParameter:kCMISBrowserJSONParameterSelector value:kCMISBrowserJSONSelectorContent urlString:contentUrl];
    
    [self.bindingSession.networkProvider invoke:[NSURL URLWithString:contentUrl]
                                     httpMethod:HTTP_GET
                                        session:self.bindingSession
                                 outputFilePath:filePath
                                  bytesExpected:0
                                    cmisRequest:request
                                completionBlock:^(CMISHttpResponse *httpResponse, NSError *error)
     {
         if (completionBlock) {
             completionBlock(error);
         }
     } progressBlock:progressBlock];
    
    return request;
}

- (CMISRequest*)downloadContentOfObject:(NSString *)objectId
                               streamId:(NSString *)streamId
                                 toFile:(NSString *)filePath
                                 offset:(NSDecimalNumber*)offset
                                 length:(NSDecimalNumber*)length
                        completionBlock:(void (^)(NSError *error))completionBlock
                          progressBlock:(void (^)(unsigned long long bytesDownloaded, unsigned long long bytesTotal))progressBlock
{
    NSOutputStream *outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    return [self downloadContentOfObject:objectId
                                streamId:streamId
                          toOutputStream:outputStream
                                  offset:offset
                                  length:length
                         completionBlock:completionBlock
                           progressBlock:progressBlock];
}

- (CMISRequest*)downloadContentOfObject:(NSString *)objectId
                               streamId:(NSString *)streamId
                         toOutputStream:(NSOutputStream *)outputStream
                        completionBlock:(void (^)(NSError *error))completionBlock
                          progressBlock:(void (^)(unsigned long long bytesDownloaded, unsigned long long bytesTotal))progressBlock
{
    return [self downloadContentOfObject:objectId
                                streamId:streamId
                          toOutputStream:outputStream
                                  offset:nil
                                  length:nil
                         completionBlock:completionBlock
                           progressBlock:^(unsigned long long bytesDownloaded, unsigned long long bytesTotal) {
                               if (progressBlock) {
                                   progressBlock(bytesDownloaded, bytesTotal);
                               }
                           }];
}

- (CMISRequest*)downloadContentOfObject:(NSString *)objectId
                               streamId:(NSString *)streamId
                         toOutputStream:(NSOutputStream *)outputStream
                                 offset:(NSDecimalNumber*)offset
                                 length:(NSDecimalNumber*)length
                        completionBlock:(void (^)(NSError *error))completionBlock
                          progressBlock:(void (^)(unsigned long long bytesDownloaded, unsigned long long bytesTotal))progressBlock
{
    CMISRequest *request = [[CMISRequest alloc] init];
    
    NSString *rootUrl = [self.bindingSession objectForKey:kCMISBrowserBindingSessionKeyRootFolderUrl];
    
    NSString *contentUrl = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterStreamId value:streamId urlString:rootUrl];
    contentUrl = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterObjectId value:objectId urlString:contentUrl];
    contentUrl = [CMISURLUtil urlStringByAppendingParameter:kCMISBrowserJSONParameterSelector value:kCMISBrowserJSONSelectorContent urlString:contentUrl];

    [self.bindingSession.networkProvider invoke:[NSURL URLWithString:contentUrl]
                                  httpMethod:HTTP_GET
                                     session:self.bindingSession
                                outputStream:outputStream
                               bytesExpected:0
                                      offset:offset
                                      length:length
                                 cmisRequest:request
                             completionBlock:^(CMISHttpResponse *httpResponse, NSError *error)
    {
        if (completionBlock) {
          completionBlock(error);
        }
    } progressBlock:progressBlock];
    
    return request;
}

- (CMISRequest*)deleteContentOfObject:(CMISStringInOutParameter *)objectIdParam
                          changeToken:(CMISStringInOutParameter *)changeTokenParam
                      completionBlock:(void (^)(NSError *error))completionBlock
{
    // we need an object id
    if ((objectIdParam.inParameter == nil) || (objectIdParam.inParameter.length == 0)) {
        completionBlock([CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument
                                        detailedDescription:@"Object id must be set!"]);
    }
    
    // build URL
    NSString *objectUrl = [self retrieveObjectUrlForObjectWithId:objectIdParam.inParameter];
    
    // prepare form data
    CMISBroswerFormDataWriter *formData = [[CMISBroswerFormDataWriter alloc] initWithAction:kCMISBrowserJSONActionDeleteContent];
    [formData addParameter:kCMISParameterChangeToken value:changeTokenParam.inParameter];
    [formData addSuccinctFlag:true];
    
    
    CMISRequest *cmisRequest = [[CMISRequest alloc] init];
    
    // send
    [self.bindingSession.networkProvider invokePOST:[NSURL URLWithString:objectUrl]
                                            session:self.bindingSession
                                               body:formData.body
                                            headers:formData.headers
                                        cmisRequest:cmisRequest
                                    completionBlock:^(CMISHttpResponse *httpResponse, NSError *error) {
                                        if ((httpResponse.statusCode == 200 || httpResponse.statusCode == 201) && httpResponse.data) {
                                            CMISBrowserTypeCache *typeCache = [[CMISBrowserTypeCache alloc] initWithRepositoryId:self.bindingSession.repositoryId bindingService:self];
                                            [CMISBrowserUtil objectDataFromJSONData:httpResponse.data typeCache:typeCache completionBlock:^(CMISObjectData *objectData, NSError *error) {
                                                if (error) {
                                                    completionBlock(error);
                                                } else {
                                                    objectIdParam.outParameter = objectData.identifier;
                                                    changeTokenParam.outParameter = objectData.properties.propertiesDictionary[kCMISPropertyChangeToken];
                                                    
                                                    completionBlock(nil);
                                                }
                                            }];
                                        } else {
                                            completionBlock(error);
                                        }
                                    }];
    return cmisRequest;
}

- (CMISRequest*)changeContentOfObject:(CMISStringInOutParameter *)objectIdParam
                      toContentOfFile:(NSString *)filePath
                             mimeType:(NSString *)mimeType
                    overwriteExisting:(BOOL)overwrite
                          changeToken:(CMISStringInOutParameter *)changeTokenParam
                      completionBlock:(void (^)(NSError *error))completionBlock
                        progressBlock:(void (^)(unsigned long long bytesUploaded, unsigned long long bytesTotal))progressBlock
{
    NSInputStream *inputStream = [NSInputStream inputStreamWithFileAtPath:filePath];
    if (inputStream == nil) {
        CMISLogError(@"Could not find file %@", filePath);
        if (completionBlock) {
            completionBlock([CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument detailedDescription:nil]);
        }
        return nil;
    }
    
    NSError *fileError = nil;
    unsigned long long fileSize = [CMISFileUtil fileSizeForFileAtPath:filePath error:&fileError];
    if (fileError) {
        CMISLogError(@"Could not determine size of file %@: %@", filePath, [fileError description]);
    }
    
    return [self changeContentOfObject:objectIdParam
                toContentOfInputStream:inputStream
                         bytesExpected:fileSize
                              filename:[filePath lastPathComponent]
                              mimeType:mimeType
                     overwriteExisting:overwrite
                           changeToken:changeTokenParam
                       completionBlock:completionBlock
                         progressBlock:progressBlock];
}

- (CMISRequest*)changeContentOfObject:(CMISStringInOutParameter *)objectId
               toContentOfInputStream:(NSInputStream *)inputStream
                        bytesExpected:(unsigned long long)bytesExpected
                             filename:(NSString *)filename
                             mimeType:(NSString *)mimeType
                    overwriteExisting:(BOOL)overwrite
                          changeToken:(CMISStringInOutParameter *)changeToken
                      completionBlock:(void (^)(NSError *error))completionBlock
                        progressBlock:(void (^)(unsigned long long bytesUploaded, unsigned long long bytesTotal))progressBlock
{
    // we need an object id
    if ((objectId.inParameter == nil) || (objectId.inParameter.length == 0)) {
        completionBlock([CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument
                                        detailedDescription:@"Object id must be set!"]);
    }
    
    // Validate mimetype
    if (inputStream && !mimeType) {
        CMISLogError(@"Must provide a mimetype when creating a cmis document");
        if (completionBlock) {
            completionBlock([CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument detailedDescription:nil]);
        }
        return nil;
    }
    
    // build URL
    NSString *objectUrl = [self retrieveObjectUrlForObjectWithId:objectId.inParameter];
    
    // prepare form data
    CMISBroswerFormDataWriter *formData = [[CMISBroswerFormDataWriter alloc] initWithAction:kCMISBrowserJSONActionSetContent contentStream:inputStream mediaType:mimeType];
    [formData setFileName:filename];
    [formData addParameter:kCMISParameterOverwriteFlag boolValue:overwrite];
    [formData addParameter:kCMISParameterChangeToken value:changeToken.inParameter];
    [formData addSuccinctFlag:true];
    
    
    CMISRequest *cmisRequest = [[CMISRequest alloc] init];
    
    // send
    [self.bindingSession.networkProvider invoke:[NSURL URLWithString:objectUrl]
                                     httpMethod:HTTP_POST
                                        session:self.bindingSession
                                    inputStream:inputStream
                                        headers:formData.headers
                                  bytesExpected:bytesExpected
                                    cmisRequest:cmisRequest
                                      startData:formData.startData
                                        endData:formData.endData
                              useBase64Encoding:NO
                                completionBlock:^(CMISHttpResponse *httpResponse, NSError *error) {
                                    if ((httpResponse.statusCode == 200 || httpResponse.statusCode == 201) && httpResponse.data) {
                                        CMISBrowserTypeCache *typeCache = [[CMISBrowserTypeCache alloc] initWithRepositoryId:self.bindingSession.repositoryId bindingService:self];
                                        [CMISBrowserUtil objectDataFromJSONData:httpResponse.data typeCache:typeCache completionBlock:^(CMISObjectData *objectData, NSError *error) {
                                            if (error) {
                                                completionBlock(error);
                                            } else {
                                                objectId.outParameter = objectData.identifier;
                                                changeToken.outParameter = objectData.properties.propertiesDictionary[kCMISPropertyChangeToken];
                                                
                                                completionBlock(nil);
                                            }
                                        }];
                                    } else {
                                        completionBlock(error);
                                    }
                                }
                                  progressBlock:progressBlock];
    return cmisRequest;
}

- (CMISRequest*)createDocumentFromFilePath:(NSString *)filePath
                                  mimeType:(NSString *)mimeType
                                properties:(CMISProperties *)properties
                                  inFolder:(NSString *)folderObjectId
                           completionBlock:(void (^)(NSString *objectId, NSError *error))completionBlock
                             progressBlock:(void (^)(unsigned long long bytesUploaded, unsigned long long bytesTotal))progressBlock
{
    NSInputStream *inputStream = [NSInputStream inputStreamWithFileAtPath:filePath];
    if (inputStream == nil) {
        CMISLogError(@"Could not find file %@", filePath);
        if (completionBlock) {
            completionBlock(nil, [CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument
                                                 detailedDescription:@"Invalid file"]);
        }
        return nil;
    }
    
    NSError *fileError = nil;
    unsigned long long bytesExpected = [CMISFileUtil fileSizeForFileAtPath:filePath error:&fileError];
    if (fileError) {
        CMISLogError(@"Could not determine size of file %@: %@", filePath, [fileError description]);
    }
    
    return [self createDocumentFromInputStream:inputStream
                                      mimeType:mimeType
                                    properties:properties
                                      inFolder:folderObjectId
                                 bytesExpected:bytesExpected
                               completionBlock:completionBlock
                                 progressBlock:progressBlock];
}

- (CMISRequest*)createDocumentFromInputStream:(NSInputStream *)inputStream
                                     mimeType:(NSString *)mimeType
                                   properties:(CMISProperties *)properties
                                     inFolder:(NSString *)folderObjectId
                                bytesExpected:(unsigned long long)bytesExpected // optional
                              completionBlock:(void (^)(NSString *objectId, NSError *error))completionBlock
                                progressBlock:(void (^)(unsigned long long bytesUploaded, unsigned long long bytesTotal))progressBlock
{
    // Validate properties
    if ([properties propertyValueForId:kCMISPropertyName] == nil || [properties propertyValueForId:kCMISPropertyObjectTypeId] == nil) {
        CMISLogError(@"Must provide %@ and %@ as properties", kCMISPropertyName, kCMISPropertyObjectTypeId);
        if (completionBlock) {
            completionBlock(nil, [CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument detailedDescription:nil]);
        }
        return nil;
    }
    
    // Validate mimetype
    if (inputStream && !mimeType) {
        CMISLogError(@"Must provide a mimetype when creating a cmis document");
        if (completionBlock) {
            completionBlock(nil, [CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument detailedDescription:nil]);
        }
        return nil;
    }
    
    // build URL
    NSString *folderObjectUrl = (folderObjectId != nil ? [self retrieveObjectUrlForObjectWithId:folderObjectId] : [self retrieveRepositoryUrl]);
    
    // prepare form data
    CMISBroswerFormDataWriter *formData = [[CMISBroswerFormDataWriter alloc] initWithAction:kCMISBrowserJSONActionCreateDocument contentStream:inputStream mediaType:mimeType];
    [formData addPropertiesParameters:properties];
    // TODO [formData addParameter:kCMISParameterVersioningState value:versioningState];
    // TODO [formData addPoliciesParameters:policies];
    // TODO [formData addAddAcesParameters:addAces];
    // TODO [formData addRemoveAcesParameters:removeAces];
    [formData addSuccinctFlag:true];
    
    
    CMISRequest *cmisRequest = [[CMISRequest alloc] init];
    
    void (^responseHandlingBlock) (CMISHttpResponse*, NSError*) = ^(CMISHttpResponse *httpResponse, NSError *error) {
        if ((httpResponse.statusCode == 200 || httpResponse.statusCode == 201) && httpResponse.data) {
            CMISBrowserTypeCache *typeCache = [[CMISBrowserTypeCache alloc] initWithRepositoryId:self.bindingSession.repositoryId bindingService:self];
            [CMISBrowserUtil objectDataFromJSONData:httpResponse.data typeCache:typeCache completionBlock:^(CMISObjectData *objectData, NSError *error) {
                if (error) {
                    completionBlock(nil, error);
                } else {
                    completionBlock(objectData.identifier, nil);
                }
            }];
        } else {
            completionBlock(nil, error);
        }
    };
    
    // send
    if (inputStream) {
        [self.bindingSession.networkProvider invoke:[NSURL URLWithString:folderObjectUrl]
                                         httpMethod:HTTP_POST
                                            session:self.bindingSession
                                        inputStream:inputStream
                                            headers:formData.headers
                                      bytesExpected:bytesExpected
                                        cmisRequest:cmisRequest
                                          startData:formData.startData
                                            endData:formData.endData
                                  useBase64Encoding:NO
                                    completionBlock:responseHandlingBlock
                                      progressBlock:progressBlock];
    } else {
        [self.bindingSession.networkProvider invokePOST:[NSURL URLWithString:folderObjectUrl]
                                                session:self.bindingSession
                                                   body:formData.body
                                                headers:formData.headers
                                            cmisRequest:cmisRequest
                                        completionBlock:responseHandlingBlock];
    }
    return cmisRequest;
}

- (CMISRequest*)deleteObject:(NSString *)objectId
                 allVersions:(BOOL)allVersions
             completionBlock:(void (^)(BOOL objectDeleted, NSError *error))completionBlock
{
    // build URL
    NSString *objectUrl = [self retrieveObjectUrlForObjectWithId:objectId];
    
    CMISBroswerFormDataWriter *formData = [[CMISBroswerFormDataWriter alloc] initWithAction:kCMISBrowserJSONActionDelete];
    [formData addParameter:kCMISParameterAllVersions boolValue:allVersions];
    

    CMISRequest *cmisRequest = [[CMISRequest alloc] init];
    
    // send
    [self.bindingSession.networkProvider invokePOST:[NSURL URLWithString:objectUrl]
                                            session:self.bindingSession
                                               body:formData.body
                                            headers:formData.headers
                                        cmisRequest:cmisRequest
                                    completionBlock:^(CMISHttpResponse *httpResponse, NSError *error) {
                                        if ((httpResponse.statusCode == 200 || httpResponse.statusCode == 201) && httpResponse.data) {
                                            completionBlock(YES, nil);
                                        } else {
                                            completionBlock(NO, [CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeUpdateConflict]);
                                        }
                                    }];
    return cmisRequest;
}

- (CMISRequest*)createFolderInParentFolder:(NSString *)folderObjectId
                                properties:(CMISProperties *)properties
                           completionBlock:(void (^)(NSString *objectId, NSError *error))completionBlock
{
    // build URL
    NSString *folderObjectUrl = [self retrieveObjectUrlForObjectWithId:folderObjectId];
    
    // prepare form data
    CMISBroswerFormDataWriter *formData = [[CMISBroswerFormDataWriter alloc] initWithAction:kCMISBrowserJSONActionCreateFolder];
    [formData addPropertiesParameters:properties];
    // TODO [formData addPoliciesParameters:policies];
    // TODO [formData addAddAcesParameters:addAces];
    // TODO [formData addRemoveAcesParameters:removeAces];
    [formData addSuccinctFlag:true];
    
    
    CMISRequest *cmisRequest = [[CMISRequest alloc] init];
    
    // send
    [self.bindingSession.networkProvider invokePOST:[NSURL URLWithString:folderObjectUrl]
                                            session:self.bindingSession
                                               body:formData.body
                                            headers:formData.headers
                                        cmisRequest:cmisRequest
                                    completionBlock:^(CMISHttpResponse *httpResponse, NSError *error) {
                                        if ((httpResponse.statusCode == 200 || httpResponse.statusCode == 201) && httpResponse.data) {
                                            CMISBrowserTypeCache *typeCache = [[CMISBrowserTypeCache alloc] initWithRepositoryId:self.bindingSession.repositoryId bindingService:self];
                                            [CMISBrowserUtil objectDataFromJSONData:httpResponse.data typeCache:typeCache completionBlock:^(CMISObjectData *objectData, NSError *error) {
                                                if (error) {
                                                    completionBlock(nil, error);
                                                } else {
                                                    completionBlock(objectData.identifier, nil);
                                                }
                                            }];
                                        } else {
                                            completionBlock(nil, error);
                                        }
                                    }];
    return cmisRequest;
}

- (CMISRequest*)moveObject:(NSString *)objectId
                fromFolder:(NSString *)sourceFolderId
                  toFolder:(NSString *)targetFolderId
           completionBlock:(void (^)(CMISObjectData *objectData, NSError *error))completionBlock
{
    // we need an object id
    if ((objectId == nil) || (objectId.length == 0)) {
        completionBlock(nil, [CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument
                                        detailedDescription:@"Object id must be set!"]);
    }
    
    // build URL
    NSString *objectUrl = [self retrieveObjectUrlForObjectWithId:objectId];
    
    // prepare form data
    CMISBroswerFormDataWriter *formData = [[CMISBroswerFormDataWriter alloc] initWithAction:kCMISBrowserJSONActionMove];
    [formData addParameter:kCMISParameterTargetFolderId value:targetFolderId];
    [formData addParameter:kCMISParameterSourceFolderId value:sourceFolderId];
    [formData addSuccinctFlag:true];
    
    
    CMISRequest *cmisRequest = [[CMISRequest alloc] init];
    
    // send
    [self.bindingSession.networkProvider invokePOST:[NSURL URLWithString:objectUrl]
                                            session:self.bindingSession
                                               body:formData.body
                                            headers:formData.headers
                                        cmisRequest:cmisRequest
                                    completionBlock:^(CMISHttpResponse *httpResponse, NSError *error) {
                                        if ((httpResponse.statusCode == 200 || httpResponse.statusCode == 201) && httpResponse.data) {
                                            CMISBrowserTypeCache *typeCache = [[CMISBrowserTypeCache alloc] initWithRepositoryId:self.bindingSession.repositoryId bindingService:self];
                                            [CMISBrowserUtil objectDataFromJSONData:httpResponse.data typeCache:typeCache completionBlock:^(CMISObjectData *objectData, NSError *error) {
                                                if (error) {
                                                    completionBlock(nil, error);
                                                } else {
                                                    completionBlock(objectData, nil);
                                                }
                                            }];
                                        } else {
                                            completionBlock(nil, error);
                                        }
                                    }];
    return cmisRequest;
}

- (CMISRequest*)deleteTree:(NSString *)folderObjectId
                allVersion:(BOOL)allVersions
             unfileObjects:(CMISUnfileObject)unfileObjects
         continueOnFailure:(BOOL)continueOnFailure
           completionBlock:(void (^)(NSArray *failedObjects, NSError *error))completionBlock
{
    // build URL
    NSString *folderObjectUrl = [self retrieveObjectUrlForObjectWithId:folderObjectId];
    
    CMISBroswerFormDataWriter *formData = [[CMISBroswerFormDataWriter alloc] initWithAction:kCMISBrowserJSONActionDeleteTree];
    [formData addParameter:kCMISParameterAllVersions boolValue:allVersions];
    [formData addParameter:kCMISParameterUnfileObjects value:[CMISEnums stringForUnfileObject:unfileObjects]];
    [formData addParameter:kCMISParameterContinueOnFailure boolValue:continueOnFailure];
    
    CMISRequest *cmisRequest = [[CMISRequest alloc] init];
    
    // send
    [self.bindingSession.networkProvider invokePOST:[NSURL URLWithString:folderObjectUrl]
                                            session:self.bindingSession
                                               body:formData.body
                                            headers:formData.headers
                                        cmisRequest:cmisRequest
                                    completionBlock:^(CMISHttpResponse *httpResponse, NSError *error) {
                                        if ((httpResponse.statusCode == 200 || httpResponse.statusCode == 201) && httpResponse.data) {
                                            NSError *error = nil;
                                            if(httpResponse.data.length > 0) {
                                                NSArray *failedToDeleteIds = [CMISBrowserUtil failedToDeleteObjectsFromJSONData:httpResponse.data error:&error];
                                                if (error) {
                                                    completionBlock(nil, error);
                                                } else {
                                                    completionBlock(failedToDeleteIds, nil);
                                                }
                                            } else {
                                                completionBlock([NSArray array], nil);
                                            }
                                        } else {
                                            completionBlock(nil, [CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeConnection]);
                                        }
                                    }];
    
    return cmisRequest;
}

- (CMISRequest*)updatePropertiesForObject:(CMISStringInOutParameter *)objectIdParam
                               properties:(CMISProperties *)properties
                              changeToken:(CMISStringInOutParameter *)changeTokenParam
                          completionBlock:(void (^)(NSError *error))completionBlock
{
    // we need an object id
    if ((objectIdParam.inParameter == nil) || (objectIdParam.inParameter.length == 0)) {
        completionBlock([CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument
                                        detailedDescription:@"Object id must be set!"]);
    }
    
    // build URL
    NSString *objectUrl = [self retrieveObjectUrlForObjectWithId:objectIdParam.inParameter];
    
    // prepare form data
    CMISBroswerFormDataWriter *formData = [[CMISBroswerFormDataWriter alloc] initWithAction:kCMISBrowserJSONActionUpdateProperties];
    [formData addPropertiesParameters:properties];
    [formData addParameter:kCMISParameterChangeToken value:changeTokenParam.inParameter];
    [formData addSuccinctFlag:true];
    
    
    CMISRequest *cmisRequest = [[CMISRequest alloc] init];
    
    // send
    [self.bindingSession.networkProvider invokePOST:[NSURL URLWithString:objectUrl]
                                            session:self.bindingSession
                                               body:formData.body
                                            headers:formData.headers
                                        cmisRequest:cmisRequest
                                    completionBlock:^(CMISHttpResponse *httpResponse, NSError *error) {
                                        if ((httpResponse.statusCode == 200 || httpResponse.statusCode == 201) && httpResponse.data) {
                                            CMISBrowserTypeCache *typeCache = [[CMISBrowserTypeCache alloc] initWithRepositoryId:self.bindingSession.repositoryId bindingService:self];
                                            [CMISBrowserUtil objectDataFromJSONData:httpResponse.data typeCache:typeCache completionBlock:^(CMISObjectData *objectData, NSError *error) {
                                                if (error) {
                                                    completionBlock(error);
                                                } else {
                                                    objectIdParam.outParameter = objectData.identifier;
                                                    changeTokenParam.outParameter = objectData.properties.propertiesDictionary[kCMISPropertyChangeToken];
                                                    
                                                    completionBlock(nil);
                                                }
                                            }];
                                        } else {
                                            completionBlock(error);
                                        }
                                    }];
    return cmisRequest;
}

- (CMISRequest*)retrieveRenditions:(NSString *)objectId
                   renditionFilter:(NSString *)renditionFilter
                          maxItems:(NSNumber *)maxItems
                         skipCount:(NSNumber *)skipCount
                   completionBlock:(void (^)(NSArray *renditions, NSError *error))completionBlock
{
    NSString *objectUrl = [self retrieveObjectUrlForObjectWithId:objectId selector:kCMISBrowserJSONSelectorRenditions];
    objectUrl = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterRenditionFilter value:renditionFilter urlString:objectUrl];
    objectUrl = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterMaxItems value:[maxItems stringValue] urlString:objectUrl];
    objectUrl = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterSkipCount value:[skipCount stringValue] urlString:objectUrl];
    
    CMISRequest *cmisRequest = [[CMISRequest alloc] init];
    
    [self.bindingSession.networkProvider invokeGET:[NSURL URLWithString:objectUrl]
                                           session:self.bindingSession
                                       cmisRequest:cmisRequest
                                   completionBlock:^(CMISHttpResponse *httpResponse, NSError *error) {
                                       if (httpResponse.statusCode == 200 && httpResponse.data) {
                                           NSError *parsingError = nil;
                                           NSArray *renditions = [CMISBrowserUtil renditionsFromJSONData:httpResponse.data error:&parsingError];
                                           if (parsingError)
                                           {
                                               completionBlock(nil, parsingError);
                                           } else {
                                               completionBlock(renditions, nil);
                                           }
                                       } else {
                                           completionBlock(nil, error);
                                       }
                                   }];
    
    return cmisRequest;
}

@end
