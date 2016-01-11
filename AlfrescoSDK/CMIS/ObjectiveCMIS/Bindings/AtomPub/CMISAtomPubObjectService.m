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

#import "CMISAtomPubObjectService.h"
#import "CMISAtomPubBaseService+Protected.h"
#import "CMISHttpResponse.h"
#import "CMISAtomEntryWriter.h"
#import "CMISAtomEntryParser.h"
#import "CMISErrors.h"
#import "CMISStringInOutParameter.h"
#import "CMISURLUtil.h"
#import "CMISFileUtil.h"
#import "CMISLog.h"

@implementation CMISAtomPubObjectService

- (CMISRequest*)retrieveObject:(NSString *)objectId
                filter:(NSString *)filter
         relationships:(CMISIncludeRelationship)relationships
      includePolicyIds:(BOOL)includePolicyIds
       renditionFilter:(NSString *)renditionFilter
            includeACL:(BOOL)includeACL
    includeAllowableActions:(BOOL)includeAllowableActions
       completionBlock:(void (^)(CMISObjectData *objectData, NSError *error))completionBlock
{
    CMISRequest *cmisRequest = [[CMISRequest alloc] init];
    [self retrieveObjectInternal:objectId
                   returnVersion:NOT_PROVIDED
                          filter:filter
                   relationships:relationships
                includePolicyIds:includePolicyIds
                 renditionFilter:renditionFilter
                      includeACL:includeACL
         includeAllowableActions:includeAllowableActions
                     cmisRequest:cmisRequest
                 completionBlock:^(CMISObjectData *objectData, NSError *error) {
                     if (error) {
                         completionBlock(nil, [CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeObjectNotFound]);
                     } else {
                         completionBlock(objectData, nil);
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
    CMISRequest *cmisRequest = [[CMISRequest alloc] init];
    [self retrieveObjectByPathInternal:path
                                filter:filter
                         relationships:relationships
                      includePolicyIds:includePolicyIds
                       renditionFilter:renditionFilter
                            includeACL:includeACL
               includeAllowableActions:includeAllowableActions
                           cmisRequest:cmisRequest
                       completionBlock:completionBlock];
    return cmisRequest;
}

- (CMISRequest*)downloadContentOfObject:(NSString *)objectId
                               streamId:(NSString *)streamId
                                 toFile:(NSString *)filePath
                        completionBlock:(void (^)(NSError *error))completionBlock
                          progressBlock:(void (^)(unsigned long long bytesDownloaded, unsigned long long bytesTotal))progressBlock
{
    CMISRequest *request = [[CMISRequest alloc] init];
    
    [self retrieveObjectInternal:objectId cmisRequest:request completionBlock:^(CMISObjectData *objectData, NSError *error) {
        if (error) {
            if (completionBlock) {
                completionBlock([CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeObjectNotFound]);
            }
        } else {
            NSURL *contentUrl = objectData.contentUrl;
         
            if (contentUrl) {
                if (streamId != nil) {
                    contentUrl = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterStreamId value:streamId url:contentUrl];
                }
                
                unsigned long long streamLength = [[[objectData.properties.propertiesDictionary objectForKey:kCMISPropertyContentStreamLength] firstValue] unsignedLongLongValue];
             
                [self.bindingSession.networkProvider invoke:contentUrl
                                                 httpMethod:HTTP_GET
                                                    session:self.bindingSession
                                             outputFilePath:filePath
                                              bytesExpected:streamLength
                                                cmisRequest:request
                                            completionBlock:^(CMISHttpResponse *httpResponse, NSError *error) {
                    if (completionBlock) {
                        completionBlock(error);
                    }
                } progressBlock:progressBlock];
                
            } else {
                if (completionBlock) {
                    completionBlock(nil);
                }
            }
        }
    }];
    
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
    
    [self retrieveObjectInternal:objectId
                     cmisRequest:request
                 completionBlock:^(CMISObjectData *objectData, NSError *error) {
        if (error) {
            CMISLogError(@"Error while retrieving CMIS object for object id '%@' : %@", objectId, error.description);
            if (completionBlock) {
                completionBlock([CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeObjectNotFound]);
            }
        } else {
            NSURL *contentUrl = objectData.contentUrl;
            
            if (contentUrl) {
                // This is not spec-compliant!! Took me half a day to find this in opencmis ...
                if (streamId != nil) {
                    contentUrl = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterStreamId value:streamId url:contentUrl];
                }
                
                unsigned long long streamLength = [[[objectData.properties.propertiesDictionary objectForKey:kCMISPropertyContentStreamLength] firstValue] unsignedLongLongValue];
                
                [self.bindingSession.networkProvider invoke:contentUrl
                                                 httpMethod:HTTP_GET
                                                    session:self.bindingSession
                                               outputStream:outputStream
                                              bytesExpected:streamLength
                                                     offset:offset
                                                     length:length
                                                cmisRequest:request
                                            completionBlock:^(CMISHttpResponse *httpResponse, NSError *error)
                 {
                     if (completionBlock) {
                         completionBlock(error);
                     }
                 }progressBlock:progressBlock];
            } else { // it is spec-compliant to have no content stream set and in this case there is nothing to download
                if (completionBlock) {
                    completionBlock(nil);
                }
            }
        }
    }];
    
    return request;
}

- (CMISRequest*)deleteContentOfObject:(CMISStringInOutParameter *)objectIdParam
                          changeToken:(CMISStringInOutParameter *)changeTokenParam
                      completionBlock:(void (^)(NSError *error))completionBlock
{
    // Validate object id param
    if (objectIdParam == nil || objectIdParam.inParameter == nil) {
        CMISLogError(@"Object id is nil or inParameter of objectId is nil");
        completionBlock([[NSError alloc] init]); // TODO: properly init error (CmisInvalidArgumentException)
        return nil;
    }
    
    CMISRequest *request = [[CMISRequest alloc] init];
    // Get edit media link
    [self loadLinkForObjectId:objectIdParam.inParameter
                     relation:kCMISLinkEditMedia
                  cmisRequest:request
              completionBlock:^(NSString *editMediaLink, NSError *error) {
        if (editMediaLink == nil){
            CMISLogError(@"Could not retrieve %@ link for object '%@'", kCMISLinkEditMedia, objectIdParam.inParameter);
            completionBlock(error);
            return;
        }
        
        // Append optional change token parameters
        if (changeTokenParam != nil && changeTokenParam.inParameter != nil) {
            editMediaLink = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterChangeToken
                                                             value:changeTokenParam.inParameter urlString:editMediaLink];
        }
        
        [self.bindingSession.networkProvider invokeDELETE:[NSURL URLWithString:editMediaLink]
                                                  session:self.bindingSession
                                              cmisRequest:request
                                          completionBlock:^(CMISHttpResponse *httpResponse, NSError *error) {
                   if (httpResponse) {
                       // Atompub DOES NOT SUPPORT returning the new object id and change token
                       // See http://docs.oasis-open.org/cmis/CMIS/v1.0/cs01/cmis-spec-v1.0.html#_Toc243905498
                       objectIdParam.outParameter = nil;
                       changeTokenParam.outParameter = nil;
                       completionBlock(nil);
                   } else {
                       completionBlock(error);
                   }
               }];
    }];
    return request;
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

- (CMISRequest*)changeContentOfObject:(CMISStringInOutParameter *)objectIdParam
               toContentOfInputStream:(NSInputStream *)inputStream
                        bytesExpected:(unsigned long long)bytesExpected
                             filename:(NSString*)filename
                             mimeType:(NSString *)mimeType
                    overwriteExisting:(BOOL)overwrite
                          changeToken:(CMISStringInOutParameter *)changeTokenParam
                      completionBlock:(void (^)(NSError *error))completionBlock
                        progressBlock:(void (^)(unsigned long long bytesUploaded, unsigned long long bytesTotal))progressBlock
{
    CMISRequest *request = [[CMISRequest alloc] init];
    // Validate object id param
    if (objectIdParam == nil || objectIdParam.inParameter == nil) {
        CMISLogError(@"Object id is nil or inParameter of objectId is nil");
        if (completionBlock) {
            completionBlock([CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument detailedDescription:@"Must provide object id"]);
        }
        return nil;
    }
    
    if (inputStream == nil) {
        CMISLogError(@"Invalid input stream");
        if (completionBlock) {
            completionBlock([CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument detailedDescription:@"Invalid input stream"]);
        }
        return nil;
    }
    
    if (nil == mimeType)
    {
        mimeType = kCMISMediaTypeOctetStream;
    }
    
    // Atompub DOES NOT SUPPORT returning the new object id and change token
    // See http://docs.oasis-open.org/cmis/CMIS/v1.0/cs01/cmis-spec-v1.0.html#_Toc243905498
    objectIdParam.outParameter = nil;
    changeTokenParam.outParameter = nil;
    
    // Get edit media link
    [self loadLinkForObjectId:objectIdParam.inParameter
                     relation:kCMISLinkEditMedia
                  cmisRequest:request
              completionBlock:^(NSString *editMediaLink, NSError *error) {
        if (editMediaLink == nil){
            CMISLogError(@"Could not retrieve %@ link for object '%@'", kCMISLinkEditMedia, objectIdParam.inParameter);
            if (completionBlock) {
                completionBlock([CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeObjectNotFound]);
            }
            return;
        }
        
        // Append optional change token parameters
        if (changeTokenParam != nil && changeTokenParam.inParameter != nil) {
            editMediaLink = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterChangeToken
                                                             value:changeTokenParam.inParameter urlString:editMediaLink];
        }
        
        // Append overwrite flag
        editMediaLink = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterOverwriteFlag
                                                         value:(overwrite ? @"true" : @"false") urlString:editMediaLink];
        
        
        // Execute HTTP call on edit media link, passing the a stream to the file
        NSArray *values =  @[[NSString stringWithFormat:kCMISHTTPHeaderContentDispositionAttachment, filename], mimeType];
        NSArray *keys = @[kCMISHTTPHeaderContentDisposition, kCMISHTTPHeaderContentType];
        
        NSDictionary *headers = [NSDictionary dictionaryWithObjects:values forKeys:keys];
                  
        [self.bindingSession.networkProvider invoke:[NSURL URLWithString:editMediaLink]
                                         httpMethod:HTTP_PUT
                                            session:self.bindingSession
                                        inputStream:inputStream
                                            headers:headers
                                      bytesExpected:bytesExpected
                                        cmisRequest:request
                                    completionBlock:^(CMISHttpResponse *httpResponse, NSError *error) {
             // Check response status
             if (httpResponse) {
                 if (httpResponse.statusCode == 200 || httpResponse.statusCode == 201 || httpResponse.statusCode == 204) {
                     error = nil;
                 } else {
                     CMISLogError(@"Invalid http response status code when updating content: %d", (int)httpResponse.statusCode);
                     error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeRuntime
                                             detailedDescription:[NSString stringWithFormat:@"Could not update content: http status code %li", (long)httpResponse.statusCode]];
                 }
             }
             if (completionBlock) {
                 completionBlock(error);
             }
         }
           progressBlock:progressBlock];
    }];
    
    return request;
}


- (CMISRequest*)createDocumentFromFilePath:(NSString *)filePath
                                  mimeType:(NSString *)mimeType
                                properties:(CMISProperties *)properties
                                  inFolder:(NSString *)folderObjectId
                           completionBlock:(void (^)(NSString *objectId, NSError *Error))completionBlock
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

- (CMISRequest*)createDocumentFromInputStream:(NSInputStream *)inputStream // may be nil if you do not want to set content
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
    
    CMISRequest *request = [[CMISRequest alloc] init];
    // Get Down link
    [self loadLinkForObjectId:folderObjectId
                     relation:kCMISLinkRelationDown
                         type:kCMISMediaTypeChildren
                  cmisRequest:request
              completionBlock:^(NSString *downLink, NSError *error) {
                          if (error) {
                              CMISLogError(@"Could not retrieve down link: %@", error.description);
                              if (completionBlock) {
                                  completionBlock(nil, [CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeObjectNotFound]);
                              }
                          } else {
                              [self sendAtomEntryXmlToLink:downLink
                                         httpRequestMethod:HTTP_POST
                                                properties:properties
                                        contentInputStream:inputStream
                                           contentMimeType:mimeType
                                             bytesExpected:bytesExpected
                                               cmisRequest:request
                                           completionBlock:^(CMISObjectData *objectData, NSError *error) {
                                               completionBlock(objectData.identifier, error);
                                           }
                                             progressBlock:progressBlock];
                          }
                      }];
    return request;
}


- (CMISRequest*)deleteObject:(NSString *)objectId
         allVersions:(BOOL)allVersions
     completionBlock:(void (^)(BOOL objectDeleted, NSError *error))completionBlock
{
    CMISRequest *request = [[CMISRequest alloc] init];
    [self loadLinkForObjectId:objectId
                     relation:kCMISLinkRelationSelf 
                  cmisRequest:request
              completionBlock:^(NSString *selfLink, NSError *error) {
        if (!selfLink) {
            completionBlock(NO, [CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument detailedDescription:nil]);
        } else {
            NSURL *selfUrl = [NSURL URLWithString:selfLink];
            [self.bindingSession.networkProvider invokeDELETE:selfUrl
                                                      session:self.bindingSession
                                                  cmisRequest:request
                                              completionBlock:^(CMISHttpResponse *httpResponse, NSError *error) {
                       if (httpResponse) {
                           completionBlock(YES, nil);
                       } else {
                           completionBlock(NO, [CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeUpdateConflict]);
                       }
                   } ];
        }
    }];
    return request;
}

- (CMISRequest*)createFolderInParentFolder:(NSString *)folderObjectId
                        properties:(CMISProperties *)properties
                   completionBlock:(void (^)(NSString *, NSError *))completionBlock
{
    if ([properties propertyValueForId:kCMISPropertyName] == nil || [properties propertyValueForId:kCMISPropertyObjectTypeId] == nil) {
        CMISLogError(@"Must provide %@ and %@ as properties", kCMISPropertyName, kCMISPropertyObjectTypeId);
        completionBlock(nil,  [CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument detailedDescription:nil]);
        return nil;
    }
    
    // Validate parent folder id
    if (!folderObjectId) {
        CMISLogError(@"Must provide a parent folder object id when creating a new folder");
        completionBlock(nil, [CMISErrors createCMISErrorWithCode:kCMISErrorCodeObjectNotFound detailedDescription:nil]);
        return nil;
    }
    CMISRequest *request = [[CMISRequest alloc] init];
    // Get Down link
    [self loadLinkForObjectId:folderObjectId
                     relation:kCMISLinkRelationDown
                         type:kCMISMediaTypeChildren
                  cmisRequest:request
              completionBlock:^(NSString *downLink, NSError *error) {
                          if (error) {
                              CMISLogError(@"Could not retrieve down link: %@", error.description);
                              completionBlock(nil, [CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeConnection]);
                          } else {
                              [self sendAtomEntryXmlToLink:downLink
                                         httpRequestMethod:HTTP_POST
                                                properties:properties
                                               cmisRequest:request
                                           completionBlock:^(CMISObjectData *objectData, NSError *error) {
                                               completionBlock(objectData.identifier, error);
                                           }];
                          }
                      }];
    return request;
}

- (CMISRequest*)moveObject:(NSString *)objectId
                fromFolder:(NSString *)sourceFolderId
                  toFolder:(NSString *)targetFolderId
           completionBlock:(void (^)(CMISObjectData *objectData, NSError *error))completionBlock
{
    // Validate params
    if (!objectId) {
        CMISLogError(@"Must provide an object id when moving it");
        completionBlock(nil, [CMISErrors createCMISErrorWithCode:kCMISErrorCodeObjectNotFound detailedDescription:nil]);
        return nil;
    }
    
    if (!sourceFolderId) {
        CMISLogError(@"Must provide a source folder id when moving an object");
        completionBlock(nil, [CMISErrors createCMISErrorWithCode:kCMISErrorCodeObjectNotFound detailedDescription:nil]);
        return nil;
    }
    
    if (!targetFolderId) {
        CMISLogError(@"Must provide a target folder id when moving an object");
        completionBlock(nil, [CMISErrors createCMISErrorWithCode:kCMISErrorCodeObjectNotFound detailedDescription:nil]);
        return nil;
    }
    
    // Build property for objectId
    CMISPropertyData *objectIdPropertyData = [CMISPropertyData createPropertyForId:kCMISPropertyObjectId idValue:objectId];
    CMISProperties *properties = [[CMISProperties alloc] init];
    [properties addProperty:objectIdPropertyData];
    
    
    CMISRequest *request = [[CMISRequest alloc] init];
    // Get Down link
    [self loadLinkForObjectId:targetFolderId
                     relation:kCMISLinkRelationDown
                         type:kCMISMediaTypeChildren
                  cmisRequest:request
              completionBlock:^(NSString *downLink, NSError *error) {
                  if (error) {
                      CMISLogError(@"Could not retrieve down link: %@", error.description);
                      if (completionBlock) {
                          completionBlock(nil, [CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeObjectNotFound]);
                      }
                  } else {
                      
                      downLink = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterSourceFolderId value:sourceFolderId urlString:downLink];
                      
                      [self sendAtomEntryXmlToLink:downLink
                                 httpRequestMethod:HTTP_POST
                                        properties:properties
                                       cmisRequest:request
                                   completionBlock:completionBlock];
                  }
              }];
    return request;
}


- (CMISRequest*)deleteTree:(NSString *)folderObjectId
                allVersion:(BOOL)allVersions
             unfileObjects:(CMISUnfileObject)unfileObjects
         continueOnFailure:(BOOL)continueOnFailure
           completionBlock:(void (^)(NSArray *failedObjects, NSError *error))completionBlock
{
    // Validate params
    if (!folderObjectId) {
        CMISLogError(@"Must provide a folder object id when deleting a folder tree");
        completionBlock(nil, [CMISErrors createCMISErrorWithCode:kCMISErrorCodeObjectNotFound detailedDescription:nil]);
        return nil;
    }
    CMISRequest *request = [[CMISRequest alloc] init];
    
    // find the down links
    [self loadLinkForObjectId:folderObjectId
                     relation:kCMISLinkRelationDown
                         type:nil
                  cmisRequest:request
              completionBlock:^(NSString *link, NSError *error) {

        __block NSString *childrenLink = nil;

        void (^continueWithLink)(NSString*) = ^(NSString* link) {
            if(!link){
                link = childrenLink;
            }
            
            if(!link){
                CMISLogError(@"Could not retrieve %@ nor %@ link", kCMISLinkRelationDown, kCMISLinkRelationFolderTree);
                completionBlock(nil, [CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeRuntime]);
                return;
            }
            
            link = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterAllVersions value:(allVersions ? @"true" : @"false") urlString:link];
            link = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterUnfileObjects value:[CMISEnums stringForUnfileObject:unfileObjects] urlString:link];
            link = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterContinueOnFailure value:(continueOnFailure ? @"true" : @"false") urlString:link];

            [self.bindingSession.networkProvider invokeDELETE:[NSURL URLWithString:link]
                                                    session:self.bindingSession
                                                cmisRequest:request
                                            completionBlock:^(CMISHttpResponse *httpResponse, NSError *error) {
                                                if (httpResponse) {
                                                    // TODO: retrieve failed folders and files and return
                                                    completionBlock([NSArray array], nil);
                                                } else {
                                                    completionBlock(nil, [CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeConnection]);
                                                }
                                            }];
        };
                  
        void (^continueWithLinkFolderTreeFeed)(NSString*) = ^(NSString* link) {
            if(!link){
                [self loadLinkForObjectId:folderObjectId
                                 relation:kCMISLinkRelationFolderTree
                                     type:kCMISMediaTypeFeed
                              cmisRequest:request
                          completionBlock:^(NSString *link, NSError *error) {
                              continueWithLink(link);
                          }];
            } else {
                continueWithLink(link);   
            }
        };
                  
        void (^continueWithLinksFolderTreeDescendants)(NSString*) = ^(NSString* link) {
            if(!link) {
                [self loadLinkForObjectId:folderObjectId
                                 relation:kCMISLinkRelationFolderTree
                                     type:kCMISMediaTypeDescendants
                              cmisRequest:request
                          completionBlock:^(NSString *link, NSError *error) {
                              continueWithLinkFolderTreeFeed(link);
                          }];
            } else {
                continueWithLinkFolderTreeFeed(link);
            }
        };
                  

        if(link){
            // found only a children link, but no descendants link
            // -> try folder tree link
            childrenLink = link;
            link = nil;
            continueWithLinksFolderTreeDescendants(link);
        } else {
            // found no or two down links
            // -> get only the descendants link
            [self loadLinkForObjectId:folderObjectId
                           relation:kCMISLinkRelationDown
                               type:kCMISMediaTypeDescendants
                        cmisRequest:request
                    completionBlock:^(NSString *link, NSError *error) {
                        continueWithLinksFolderTreeDescendants(link);
                    }];
        }
    }];
    return request;
}

- (CMISRequest*)updatePropertiesForObject:(CMISStringInOutParameter *)objectIdParam
                       properties:(CMISProperties *)properties
                      changeToken:(CMISStringInOutParameter *)changeTokenParam
                  completionBlock:(void (^)(NSError *error))completionBlock
{
    // Validate params
    if (objectIdParam == nil || objectIdParam.inParameter == nil) {
        CMISLogError(@"Object id is nil or inParameter of objectId is nil");
        completionBlock([[NSError alloc] init]); // TODO: properly init error (CmisInvalidArgumentException)
        return nil;
    }
    
    CMISRequest *request = [[CMISRequest alloc] init];
    // Get self link
    [self loadLinkForObjectId:objectIdParam.inParameter
                     relation:kCMISLinkRelationSelf
                  cmisRequest:request
              completionBlock:^(NSString *selfLink, NSError *error) {
        if (selfLink == nil) {
            CMISLogError(@"Could not retrieve %@ link", kCMISLinkRelationSelf);
            completionBlock([CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeConnection]);
            return;
        }
        
        // Append optional params
        if (changeTokenParam != nil && changeTokenParam.inParameter != nil) {
            selfLink = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterChangeToken
                                                        value:changeTokenParam.inParameter urlString:selfLink];
        }
        
        // Execute request
        [self sendAtomEntryXmlToLink:selfLink
                   httpRequestMethod:HTTP_PUT
                          properties:properties
                         cmisRequest:request
                     completionBlock:^(CMISObjectData *objectData, NSError *error) {
                         if (objectData == nil) {
                             completionBlock([CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeConnection]);
                         }
                         else {
                             // update the out parameter as the objectId may have changed
                             objectIdParam.outParameter = [[objectData.properties propertyForId:kCMISPropertyObjectId] firstValue];
                             if (changeTokenParam != nil) {
                                 changeTokenParam.outParameter = [[objectData.properties propertyForId:kCMISPropertyChangeToken] firstValue];
                             }
                             completionBlock(nil);
                         }
                     }];
    }];
    return request;
}


- (CMISRequest*)retrieveRenditions:(NSString *)objectId
           renditionFilter:(NSString *)renditionFilter
                  maxItems:(NSNumber *)maxItems
                 skipCount:(NSNumber *)skipCount
           completionBlock:(void (^)(NSArray *renditions, NSError *error))completionBlock
{
    // Only fetching the bare minimum
    CMISRequest *cmisRequest = [[CMISRequest alloc] init];
    [self retrieveObjectInternal:objectId
                   returnVersion:LATEST
                          filter:kCMISPropertyObjectId
                   relationships:CMISIncludeRelationshipNone
                includePolicyIds:NO
                 renditionFilter:renditionFilter
                      includeACL:NO
         includeAllowableActions:NO
                     cmisRequest:cmisRequest
                 completionBlock:^(CMISObjectData *objectData, NSError *error) {
                     if (error) {
                         completionBlock(nil, [CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeObjectNotFound]);
                     } else {
                         completionBlock(objectData.renditions, nil);
                     }
                 }];
    return cmisRequest;
}

@end
