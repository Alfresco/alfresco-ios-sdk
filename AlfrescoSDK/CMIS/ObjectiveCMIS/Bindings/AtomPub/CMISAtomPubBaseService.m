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

#import "CMISAtomPubBaseService.h"
#import "CMISAtomPubBaseService+Protected.h"
#import "CMISHttpResponse.h"
#import "CMISAtomPubServiceDocumentParser.h"
#import "CMISConstants.h"
#import "CMISAtomEntryParser.h"
#import "CMISAtomWorkspace.h"
#import "CMISErrors.h"
#import "CMISAtomPubObjectByPathUriBuilder.h"
#import "CMISAtomPubTypeByIdUriBuilder.h"
#import "CMISLinkCache.h"
#import "CMISLog.h"
#import "CMISAtomEntryWriter.h"

@interface CMISAtomPubBaseService ()

@property (nonatomic, strong, readwrite) CMISBindingSession *bindingSession;
@property (nonatomic, strong, readwrite) NSURL *atomPubUrl;

@end

@implementation CMISAtomPubBaseService


- (id)initWithBindingSession:(CMISBindingSession *)session
{
    self = [super init];
    if (self) {
        self.bindingSession = session;
        self.atomPubUrl = [session objectForKey:kCMISBindingSessionKeyUrl];
    }
    return self;
}


#pragma mark -
#pragma mark Protected methods

- (void)retrieveFromCache:(NSString *)cacheKey
              cmisRequest:(CMISRequest *)cmisRequest
          completionBlock:(void (^)(id object, NSError *error))completionBlock
{
    id object = [self.bindingSession objectForKey:cacheKey];

    if (object) {
        completionBlock(object, nil);
        return;
    } else {
         // if object is nil, first populate cache
        [self fetchRepositoryInfoWithCMISRequest:cmisRequest completionBlock:^(NSError *error) {
            id object = [self.bindingSession objectForKey:cacheKey];
            if (!object && !error) {
                // TODO: proper error initialisation
                error = [[NSError alloc] init];
                CMISLogDebug(@"Could not get object from cache with key '%@'", cacheKey);
            }
            completionBlock(object, error);
        }];        
    }
}

- (void)fetchRepositoryInfoWithCMISRequest:(CMISRequest *)cmisRequest
                           completionBlock:(void (^)(NSError *error))completionBlock
{
    [self retrieveCMISWorkspacesWithCMISRequest:cmisRequest completionBlock:^(NSArray *cmisWorkSpaces, NSError *error) {
        if (!error) {
            BOOL repositoryFound = NO;
            for (CMISAtomWorkspace *workspace in cmisWorkSpaces) {
                if ([workspace.repositoryInfo.identifier isEqualToString:self.bindingSession.repositoryId])
                {
                    repositoryFound = YES;
                    
                    // Cache collections
                    [self.bindingSession setObject:[workspace collectionHrefForCollectionType:kCMISAtomCollectionQuery] forKey:kCMISAtomBindingSessionKeyQueryCollection];
                    [self.bindingSession setObject:[workspace collectionHrefForCollectionType:kCMISAtomCollectionCheckedout] forKey:kCMISAtomBindingSessionKeyCheckedoutCollection];
                    
                    
                    // Cache uri's and uri templates
                    CMISAtomPubObjectByIdUriBuilder *objectByIdUriBuilder = [[CMISAtomPubObjectByIdUriBuilder alloc] initWithTemplateUrl:workspace.objectByIdUriTemplate];
                    [self.bindingSession setObject:objectByIdUriBuilder forKey:kCMISAtomBindingSessionKeyObjectByIdUriBuilder];
                    
                    CMISAtomPubObjectByPathUriBuilder *objectByPathUriBuilder = [[CMISAtomPubObjectByPathUriBuilder alloc] initWithTemplateUrl:workspace.objectByPathUriTemplate];
                    [self.bindingSession setObject:objectByPathUriBuilder forKey:kCMISAtomBindingSessionKeyObjectByPathUriBuilder];
                    
                    CMISAtomPubTypeByIdUriBuilder *typeByIdUriBuilder = [[CMISAtomPubTypeByIdUriBuilder alloc] initWithTemplateUrl:workspace.typeByIdUriTemplate];
                    [self.bindingSession setObject:typeByIdUriBuilder forKey:kCMISAtomBindingSessionKeyTypeByIdUriBuilder];
                    
                    [self.bindingSession setObject:workspace.queryUriTemplate forKey:kCMISAtomBindingSessionKeyQueryUri];
                    
                    break;
                }
            }
            
            if (!repositoryFound) {
                CMISLogError(@"No matching repository found for repository id %@", self.bindingSession.repositoryId);
                // TODO: populate error properly
                NSString *detailedDescription = [NSString stringWithFormat:@"No matching repository found for repository id %@", self.bindingSession.repositoryId];
                error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeNoRepositoryFound detailedDescription:detailedDescription];
            }
        }
        completionBlock(error);
    }];
}

- (void)retrieveCMISWorkspacesWithCMISRequest:(CMISRequest *)cmisRequest
                              completionBlock:(void (^)(NSArray *workspaces, NSError *error))completionBlock
{
    if ([self.bindingSession objectForKey:kCMISSessionKeyWorkspaces]) {
        completionBlock([self.bindingSession objectForKey:kCMISSessionKeyWorkspaces], nil);
    } else {
        [self.bindingSession.networkProvider invokeGET:self.atomPubUrl
                                               session:self.bindingSession
                                           cmisRequest:cmisRequest
                                       completionBlock:^(CMISHttpResponse *httpResponse, NSError *error) {
                                           if (httpResponse) {
                                               NSData *data = httpResponse.data;
                                               // Uncomment to see the service document
                                               //        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                               //        CMISLogDebug(@"Service document: %@", dataString);
                                               
                                               // Parse the cmis service document
                                               if (data) {
                                                   CMISAtomPubServiceDocumentParser *parser = [[CMISAtomPubServiceDocumentParser alloc] initWithData:data];
                                                   NSError *error = nil;
                                                   if ([parser parseAndReturnError:&error]) {
                                                       [self.bindingSession setObject:parser.workspaces forKey:kCMISSessionKeyWorkspaces];
                                                   } else {
                                                       CMISLogError(@"Error while parsing service document: %@", error.description);
                                                   }
                                                   completionBlock(parser.workspaces, error);
                                               }
                                           } else {
                                               completionBlock(nil, error);
                                           }
                                       }];
    }
}

- (void)retrieveObjectInternal:(NSString *)objectId
                   cmisRequest:(CMISRequest *)cmisRequest
               completionBlock:(void (^)(CMISObjectData *objectData, NSError *error))completionBlock
{
    return [self retrieveObjectInternal:objectId
                          returnVersion:NOT_PROVIDED
                                 filter:@""
                          relationships:CMISIncludeRelationshipNone
                       includePolicyIds:NO
                        renditionFilter:nil
                             includeACL:NO
                includeAllowableActions:YES
                            cmisRequest:cmisRequest
                        completionBlock:completionBlock];
}


- (void)retrieveObjectInternal:(NSString *)objectId
                 returnVersion:(CMISReturnVersion)returnVersion
                        filter:(NSString *)filter
                 relationships:(CMISIncludeRelationship)relationships
              includePolicyIds:(BOOL)includePolicyIds
               renditionFilter:(NSString *)renditionFilter
                    includeACL:(BOOL)includeACL
       includeAllowableActions:(BOOL)includeAllowableActions
                   cmisRequest:(CMISRequest *)cmisRequest
               completionBlock:(void (^)(CMISObjectData *objectData, NSError *error))completionBlock
{
    [self retrieveFromCache:kCMISAtomBindingSessionKeyObjectByIdUriBuilder
                cmisRequest:cmisRequest
            completionBlock:^(id object, NSError *error) {
        CMISAtomPubObjectByIdUriBuilder *objectByIdUriBuilder = object;
        objectByIdUriBuilder.objectId = objectId;
        objectByIdUriBuilder.filter = filter;
        objectByIdUriBuilder.includeACL = includeACL;
        objectByIdUriBuilder.includeAllowableActions = includeAllowableActions;
        objectByIdUriBuilder.includePolicyIds = includePolicyIds;
        objectByIdUriBuilder.relationships = relationships;
        objectByIdUriBuilder.renditionFilter = renditionFilter;
        objectByIdUriBuilder.returnVersion = returnVersion;
        NSURL *objectIdUrl = [objectByIdUriBuilder buildUrl];
        
        // Execute actual call
        [self.bindingSession.networkProvider invokeGET:objectIdUrl
                                               session:self.bindingSession
                                           cmisRequest:cmisRequest
                                       completionBlock:^(CMISHttpResponse *httpResponse, NSError *error) {
                if (httpResponse) {
                    if (httpResponse.statusCode == 200 && httpResponse.data) {
                        CMISObjectData *objectData = nil;
                        NSError *error = nil;
                        CMISAtomEntryParser *parser = [[CMISAtomEntryParser alloc] initWithData:httpResponse.data];
                        if ([parser parseAndReturnError:&error]) {
                            objectData = parser.objectData;
                            
                            // Add links to link cache
                            CMISLinkCache *linkCache = [self linkCache];
                            [linkCache addLinks:objectData.linkRelations objectId:objectData.identifier];
                        }
                        completionBlock(objectData, error);
                    }
                } else {
                    completionBlock(nil, error);
                }
            }];
    }];
}

- (void)retrieveObjectByPathInternal:(NSString *)path
                              filter:(NSString *)filter
                       relationships:(CMISIncludeRelationship)relationships
                    includePolicyIds:(BOOL)includePolicyIds
                     renditionFilter:(NSString *)renditionFilter
                          includeACL:(BOOL)includeACL
             includeAllowableActions:(BOOL)includeAllowableActions
                         cmisRequest:(CMISRequest *)cmisRequest
                     completionBlock:(void (^)(CMISObjectData *objectData, NSError *error))completionBlock
{
    [self retrieveFromCache:kCMISAtomBindingSessionKeyObjectByPathUriBuilder
                cmisRequest:cmisRequest
            completionBlock:^(id object, NSError *error) {
        CMISAtomPubObjectByPathUriBuilder *objectByPathUriBuilder = object;
        objectByPathUriBuilder.path = path;
        objectByPathUriBuilder.filter = filter;
        objectByPathUriBuilder.includeACL = includeACL;
        objectByPathUriBuilder.includeAllowableActions = includeAllowableActions;
        objectByPathUriBuilder.includePolicyIds = includePolicyIds;
        objectByPathUriBuilder.relationships = relationships;
        objectByPathUriBuilder.renditionFilter = renditionFilter;
        
        // Execute actual call
        [self.bindingSession.networkProvider invokeGET:[objectByPathUriBuilder buildUrl]
                                               session:self.bindingSession
                                           cmisRequest:cmisRequest
                                       completionBlock:^(CMISHttpResponse *httpResponse, NSError *error) {
                if (httpResponse) {
                    if (httpResponse.statusCode == 200 && httpResponse.data != nil) {
                        CMISObjectData *objectData = nil;
                        NSError *error = nil;
                        CMISAtomEntryParser *parser = [[CMISAtomEntryParser alloc] initWithData:httpResponse.data];
                        if ([parser parseAndReturnError:&error]) {
                            objectData = parser.objectData;
                            
                            // Add links to link cache
                            CMISLinkCache *linkCache = [self linkCache];
                            [linkCache addLinks:objectData.linkRelations objectId:objectData.identifier];
                        }
                        completionBlock(objectData, error);
                    }
                } else {
                    completionBlock(nil, error);
                }
            }];
    }];
}

- (CMISLinkCache *)linkCache
{
    CMISLinkCache *linkCache = [self.bindingSession objectForKey:kCMISAtomBindingSessionKeyLinkCache];
    if (linkCache == nil) {
        linkCache = [[CMISLinkCache alloc] initWithBindingSession:self.bindingSession];
        [self.bindingSession setObject:linkCache forKey:kCMISAtomBindingSessionKeyLinkCache];
    }
    return linkCache;
}

- (void)clearCacheFromService
{
    CMISLinkCache *linkCache = [self.bindingSession objectForKey:kCMISAtomBindingSessionKeyLinkCache];
    if (linkCache != nil) {
        [linkCache removeAllLinks];
    }    
}


- (void)loadLinkForObjectId:(NSString *)objectId
                   relation:(NSString *)rel
                cmisRequest:(CMISRequest *)cmisRequest
            completionBlock:(void (^)(NSString *link, NSError *error))completionBlock
{
    [self loadLinkForObjectId:objectId relation:rel type:nil cmisRequest:cmisRequest completionBlock:completionBlock];
}

- (void)loadLinkForObjectId:(NSString *)objectId
                   relation:(NSString *)rel
                       type:(NSString *)type
                cmisRequest:(CMISRequest *)cmisRequest
            completionBlock:(void (^)(NSString *link, NSError *error))completionBlock
{
    CMISLinkCache *linkCache = [self linkCache];
    
    // Fetch link from cache
    NSString *link = [linkCache linkForObjectId:objectId relation:rel type:type];
    if (link) {
        completionBlock(link, nil);
        return;///shall we return nil here
    } else {
        // Fetch object, which will trigger the caching of the links
        [self retrieveObjectInternal:objectId
                                      cmisRequest:cmisRequest
                                  completionBlock:^(CMISObjectData *objectData, NSError *error) {
            if (error) {
                CMISLogDebug(@"Could not retrieve object with id %@", objectId);
                completionBlock(nil, [CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeObjectNotFound]);
            } else {
                NSString *link = [linkCache linkForObjectId:objectId relation:rel type:type];
                if (link == nil) {
                    completionBlock(nil, [CMISErrors createCMISErrorWithCode:kCMISErrorCodeObjectNotFound
                                                         detailedDescription:[NSString stringWithFormat:@"Could not find link '%@' for object with id %@", rel, objectId]]);
                } else {
                    completionBlock(link, nil);
                }
            }
        }];
    }
}

- (void)sendAtomEntryXmlToLink:(NSString *)link
             httpRequestMethod:(CMISHttpRequestMethod)httpRequestMethod
                    properties:(CMISProperties *)properties
                   cmisRequest:(CMISRequest *)request
               completionBlock:(void (^)(CMISObjectData *objectData, NSError *error))completionBlock
{
    // Validate params
    if (link == nil) {
        CMISLogError(@"Must provide link to send atom entry");
        if (completionBlock) {
            completionBlock(nil, [CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument detailedDescription:nil]);
        }
        return;
    }
    
    // Generate atom entry XML in memory
    CMISAtomEntryWriter *atomEntryWriter = [[CMISAtomEntryWriter alloc] init];
    atomEntryWriter.cmisProperties = properties;
    atomEntryWriter.generateXmlInMemory = YES;
    NSString *writeResult = [atomEntryWriter generateAtomEntryXml];
    
    // Execute call
    [self.bindingSession.networkProvider invoke:[NSURL URLWithString:link]
                                     httpMethod:httpRequestMethod
                                        session:self.bindingSession
                                           body:[writeResult dataUsingEncoding:NSUTF8StringEncoding]
                                        headers:[NSDictionary dictionaryWithObject:kCMISMediaTypeEntry forKey:@"Content-type"]
                                    cmisRequest:request
                                completionBlock:^(CMISHttpResponse *response, NSError *error) {
                                    if (error) {
                                        CMISLogError(@"HTTP error when sending atom entry: %@", error);
                                        if (completionBlock) {
                                            completionBlock(nil, error);
                                        }
                                    } else if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
                                        if (completionBlock) {
                                            CMISAtomEntryParser *atomEntryParser = [[CMISAtomEntryParser alloc] initWithData:response.data];
                                            NSError *parseError = nil;
                                            [atomEntryParser parseAndReturnError:&parseError];
                                            if (parseError == nil) {
                                                completionBlock(atomEntryParser.objectData, nil);
                                            } else {
                                                CMISLogError(@"Error while parsing response: %@", [parseError description]);
                                                completionBlock(nil, [CMISErrors cmisError:parseError cmisErrorCode:kCMISErrorCodeRuntime]);
                                            }
                                        }
                                    } else {
                                        CMISLogError(@"Invalid http response status code when sending atom entry: %ld", (long)response.statusCode);
                                        CMISLogError(@"Error content: %@", [[NSString alloc] initWithData:response.data encoding:NSUTF8StringEncoding]);
                                        if (completionBlock) {
                                            completionBlock(nil, [CMISErrors createCMISErrorWithCode:kCMISErrorCodeRuntime
                                                                                 detailedDescription:[NSString stringWithFormat:@"Failed to send atom entry: http status code %li", (long)response.statusCode]]);
                                        }
                                    }
                                }];
}

- (void)sendAtomEntryXmlToLink:(NSString *)link
             httpRequestMethod:(CMISHttpRequestMethod)httpRequestMethod
                    properties:(CMISProperties *)properties
            contentInputStream:(NSInputStream *)contentInputStream
               contentMimeType:(NSString *)contentMimeType
                 bytesExpected:(unsigned long long)bytesExpected
                   cmisRequest:(CMISRequest*)request
               completionBlock:(void (^)(CMISObjectData *objectData, NSError *error))completionBlock
                 progressBlock:(void (^)(unsigned long long bytesUploaded, unsigned long long bytesTotal))progressBlock
{
    // Validate param
    if (link == nil) {
        CMISLogError(@"Must provide link to send atom entry");
        if (completionBlock) {
            completionBlock(nil, [CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument detailedDescription:nil]);
        }
        return;
    }
    
    // generate start and end XML
    CMISAtomEntryWriter *writer = [[CMISAtomEntryWriter alloc] init];
    writer.cmisProperties = properties;
    writer.mimeType = contentMimeType;
    
    NSString *xmlStart = [writer xmlStartElement];
    NSString *xmlContentStart = [writer xmlContentStartElement];
    NSString *start = [NSString stringWithFormat:@"%@%@", xmlStart, xmlContentStart];
    NSData *startData = [NSMutableData dataWithData:[start dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *xmlContentEnd = [writer xmlContentEndElement];
    NSString *xmlProperties = [writer xmlPropertiesElements];
    NSString *end = [NSString stringWithFormat:@"%@%@", xmlContentEnd, xmlProperties];
    NSData *endData = [end dataUsingEncoding:NSUTF8StringEncoding];
    
    // The underlying CMISHttpUploadRequest object generates the atom entry. The base64 encoded content is generated on
    // the fly to support very large files.
    [self.bindingSession.networkProvider invoke:[NSURL URLWithString:link]
                                     httpMethod:httpRequestMethod
                                        session:self.bindingSession
                                    inputStream:contentInputStream
                                        headers:[NSDictionary dictionaryWithObject:kCMISMediaTypeEntry forKey:@"Content-type"]
                                  bytesExpected:bytesExpected
                                    cmisRequest:request
                                      startData:startData
                                        endData:endData
                              useBase64Encoding:YES
                                completionBlock:^(CMISHttpResponse *response, NSError *error) {
                                    if (error) {
                                        CMISLogError(@"HTTP error when sending atom entry: %@", error);
                                        if (completionBlock) {
                                            completionBlock(nil, error);
                                        }
                                    } else if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
                                        if (completionBlock) {
                                            NSError *parseError = nil;
                                            CMISAtomEntryParser *atomEntryParser = [[CMISAtomEntryParser alloc] initWithData:response.data];
                                            [atomEntryParser parseAndReturnError:&parseError];
                                            if (parseError == nil) {
                                                completionBlock(atomEntryParser.objectData, nil);
                                            } else {
                                                CMISLogError(@"Error while parsing response: %@", [parseError description]);
                                                completionBlock(nil, [CMISErrors cmisError:parseError cmisErrorCode:kCMISErrorCodeRuntime]);
                                            }
                                        }
                                    } else {
                                        CMISLogError(@"Invalid http response status code when sending atom entry: %d", (int)response.statusCode);
                                        CMISLogError(@"Error content: %@", [[NSString alloc] initWithData:response.data encoding:NSUTF8StringEncoding]);
                                        if (completionBlock) {
                                            completionBlock(nil, [CMISErrors createCMISErrorWithCode:kCMISErrorCodeRuntime
                                                                                 detailedDescription:[NSString stringWithFormat:@"Failed to send atom entry: http status code %li", (long)response.statusCode]]);
                                        }
                                    }
                                }
                                  progressBlock:progressBlock];
}

@end
