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

#import "CMISAtomPubVersioningService.h"
#import "CMISAtomPubBaseService+Protected.h"
#import "CMISAtomPubConstants.h"
#import "CMISAtomPubObjectService.h"
#import "CMISHttpResponse.h"
#import "CMISAtomEntryWriter.h"
#import "CMISAtomFeedParser.h"
#import "CMISErrors.h"
#import "CMISURLUtil.h"
#import "CMISLog.h"
#import "CMISFileUtil.h"

@implementation CMISAtomPubVersioningService

- (CMISRequest*)retrieveObjectOfLatestVersion:(NSString *)objectId
                                        major:(BOOL)major
                                       filter:(NSString *)filter
                                relationships:(CMISIncludeRelationship)relationships
                             includePolicyIds:(BOOL)includePolicyIds
                              renditionFilter:(NSString *)renditionFilter
                                   includeACL:(BOOL)includeACL
                      includeAllowableActions:(BOOL)includeAllowableActions
                              completionBlock:(void (^)(CMISObjectData *objectData, NSError *error))completionBlock
{
    CMISRequest *request = [[CMISRequest alloc] init];
    [self retrieveObjectInternal:objectId
                   returnVersion:(major ? LATEST_MAJOR : LATEST)
                          filter:filter
                   relationships:relationships
                includePolicyIds:includePolicyIds
                 renditionFilter:renditionFilter
                      includeACL:includeACL
         includeAllowableActions:includeAllowableActions
                     cmisRequest:request
                 completionBlock:^(CMISObjectData *objectData, NSError *error) {
                     completionBlock(objectData, error);
                 }];
    return request;
}

- (CMISRequest*)retrieveAllVersions:(NSString *)objectId
                             filter:(NSString *)filter
            includeAllowableActions:(BOOL)includeAllowableActions
                    completionBlock:(void (^)(NSArray *objects, NSError *error))completionBlock
{
    // Validate params
    if (!objectId) {
        CMISLogError(@"Must provide an objectId when retrieving all versions");
        completionBlock(nil, [CMISErrors createCMISErrorWithCode:kCMISErrorCodeObjectNotFound detailedDescription:nil]);
        return nil;
    }
    CMISRequest *request = [[CMISRequest alloc] init];
    
    // Fetch version history link
    [self loadLinkForObjectId:objectId
                     relation:kCMISLinkVersionHistory
                  cmisRequest:request
              completionBlock:^(NSString *versionHistoryLink, NSError *error) {
        if (error) {
            completionBlock(nil, [CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeObjectNotFound]);
            return;
        }
        
        if (filter) {
            versionHistoryLink = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterFilter value:filter urlString:versionHistoryLink];
        }
        versionHistoryLink = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterIncludeAllowableActions
                                                              value:(includeAllowableActions ? @"true" : @"false") urlString:versionHistoryLink];
        
        // Execute call
        [self.bindingSession.networkProvider invokeGET:[NSURL URLWithString:versionHistoryLink]
                                               session:self.bindingSession
                                           cmisRequest:request
                                       completionBlock:^(CMISHttpResponse *httpResponse, NSError *error) {
                if (httpResponse) {
                    NSData *data = httpResponse.data;
                    CMISAtomFeedParser *feedParser = [[CMISAtomFeedParser alloc] initWithData:data];
                    NSError *error;
                    if (![feedParser parseAndReturnError:&error]) {
                        completionBlock(nil, [CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeVersioning]);
                    } else {
                        completionBlock(feedParser.entries, nil);
                    }
                } else {
                    completionBlock(nil, [CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeConnection]);
                }
            }];
    }];
    return request;
}

- (CMISRequest*)checkOut:(NSString *)objectId
         completionBlock:(void (^)(CMISObjectData *objectData, NSError *error))completionBlock
{
    // Validate params
    if (!objectId) {
        CMISLogError(@"Must provide an objectId when checking out");
        completionBlock(nil, [CMISErrors createCMISErrorWithCode:kCMISErrorCodeObjectNotFound detailedDescription:nil]);
        return nil;
    }
    
    NSString *checkedoutUrlString = [self.bindingSession objectForKey:kCMISAtomBindingSessionKeyCheckedoutCollection];
    if (checkedoutUrlString == nil) {
        CMISLogDebug(@"Checkedout not supported!");
        completionBlock(nil, [CMISErrors createCMISErrorWithCode:kCMISErrorCodeNotSupported detailedDescription:nil]);
        return nil;
    }
    
    CMISProperties *properties = [CMISProperties new];
    [properties addProperty:[CMISPropertyData createPropertyForId:kCMISPropertyObjectId idValue:objectId]];

    CMISRequest *request = [CMISRequest new];
    
    // send an atom entry to check out the file
    [self sendAtomEntryXmlToLink:checkedoutUrlString
               httpRequestMethod:HTTP_POST
                      properties:properties
                     cmisRequest:request
                 completionBlock:^(CMISObjectData *objectData, NSError *error) {
                     if (error) {
                         completionBlock(nil, [CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeVersioning]);
                     } else {
                         completionBlock(objectData, nil);
                     }
                 }];

    return request;
}

- (CMISRequest*)cancelCheckOut:(NSString *)objectId
               completionBlock:(void (^)(BOOL checkoutCancelled, NSError *error))completionBlock
{
    // Validate params
    if (!objectId) {
        CMISLogError(@"Must provide an objectId when cancelling check out");
        completionBlock(NO, [CMISErrors createCMISErrorWithCode:kCMISErrorCodeObjectNotFound detailedDescription:nil]);
        return nil;
    }
    
    CMISRequest *request = [CMISRequest new];

    [self workingCopyLinkForObjectId:objectId completionBlock:^(NSString *workingCopyLink, NSError *error) {
        NSURL *deleteUrl = [NSURL URLWithString:workingCopyLink];
        [self.bindingSession.networkProvider invokeDELETE:deleteUrl
                                                  session:self.bindingSession
                                              cmisRequest:request
                                          completionBlock:^(CMISHttpResponse *httpResponse, NSError *error) {
            if (httpResponse) {
                completionBlock(YES, nil);
            } else {
                completionBlock(NO, [CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeVersioning]);
            }
        }];
    }];
    
    return request;
}

- (CMISRequest*)checkIn:(NSString *)objectId
         asMajorVersion:(BOOL)asMajorVersion
               filePath:(NSString *)filePath
               mimeType:(NSString *)mimeType
             properties:(CMISProperties *)properties
         checkinComment:(NSString *)checkinComment
        completionBlock:(void (^)(CMISObjectData *objectData, NSError *error))completionBlock
          progressBlock:(void (^)(unsigned long long bytesUploaded, unsigned long long bytesTotal))progressBlock
{
    NSInputStream *inputStream = [NSInputStream inputStreamWithFileAtPath:filePath];
    if (inputStream == nil) {
        CMISLogError(@"Could not find file %@", filePath);
        if (completionBlock) {
            completionBlock(nil, [CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument detailedDescription:nil]);
        }
        return nil;
    }
    
    NSError *fileError = nil;
    unsigned long long fileSize = [CMISFileUtil fileSizeForFileAtPath:filePath error:&fileError];
    if (fileError) {
        CMISLogError(@"Could not determine size of file %@: %@", filePath, [fileError description]);
    }
    
    return [self checkIn:objectId
          asMajorVersion:asMajorVersion
             inputStream:inputStream
           bytesExpected:fileSize
                mimeType:mimeType
              properties:properties
          checkinComment:checkinComment
         completionBlock:completionBlock
           progressBlock:progressBlock];
}

- (CMISRequest*)checkIn:(NSString *)objectId
         asMajorVersion:(BOOL)asMajorVersion
            inputStream:(NSInputStream *)inputStream
          bytesExpected:(unsigned long long)bytesExpected
               mimeType:(NSString *)mimeType
             properties:(CMISProperties *)properties
         checkinComment:(NSString *)checkinComment
        completionBlock:(void (^)(CMISObjectData *objectData, NSError *error))completionBlock
          progressBlock:(void (^)(unsigned long long bytesUploaded, unsigned long long bytesTotal))progressBlock
{
    // Validate params
    if (!objectId) {
        CMISLogError(@"Must provide an objectId when checking in");
        completionBlock(nil, [CMISErrors createCMISErrorWithCode:kCMISErrorCodeObjectNotFound detailedDescription:nil]);
        return nil;
    }
    
    CMISRequest *request = [CMISRequest new];
    
    [self workingCopyLinkForObjectId:objectId completionBlock:^(NSString *workingCopyLink, NSError *error) {
        
        // add the necessary parameters to the URL
        NSString *link = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterCheckin value:kCMISParameterValueTrue urlString:workingCopyLink];
        link = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterMajor
                                                    value:asMajorVersion ? kCMISParameterValueTrue : kCMISParameterValueFalse urlString:link];
        if (checkinComment != nil)
        {
            link = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterCheckinComment value:checkinComment urlString:link];
        }
        
        // send an atom entry to have the file checked in
        [self sendAtomEntryXmlToLink:link
                   httpRequestMethod:HTTP_PUT
                          properties:properties
                  contentInputStream:inputStream
                     contentMimeType:mimeType
                       bytesExpected:bytesExpected
                         cmisRequest:request
                     completionBlock:^(CMISObjectData *objectData, NSError *error) {
                         if (error) {
                             completionBlock(nil, [CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeVersioning]);
                         } else {
                             completionBlock(objectData, nil);
                         }
                     }
                       progressBlock:progressBlock];
    }];
    
    return request;
}

#pragma mark Internal methods

- (CMISRequest *)workingCopyLinkForObjectId:(NSString *)objectId completionBlock:(void(^)(NSString *workingCopyLink, NSError *error))completionBlock
{
    CMISRequest *request = [CMISRequest new];
    [self loadLinkForObjectId:objectId
                     relation:kCMISLinkRelationSelf
                  cmisRequest:request
              completionBlock:^(NSString *selfLink, NSError *error) {
        if (!selfLink) {
            completionBlock(nil, [CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument detailedDescription:nil]);
        } else {
            // Prefer working copy link if available
            [self loadLinkForObjectId:objectId
                             relation:kCMISLinkRelationWorkingCopy
                          cmisRequest:request
                      completionBlock:^(NSString *workingCopyLink, NSError *error) {
                NSString *link = (nil != workingCopyLink) ? workingCopyLink : selfLink;
                completionBlock(link, nil);
            }];
        }
    }];
    
    return request;
}

@end