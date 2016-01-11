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

#import "CMISAtomPubNavigationService.h"
#import "CMISAtomPubBaseService+Protected.h"
#import "CMISAtomFeedParser.h"
#import "CMISHttpResponse.h"
#import "CMISErrors.h"
#import "CMISURLUtil.h"
#import "CMISObjectList.h"
#import "CMISLog.h"

@implementation CMISAtomPubNavigationService


- (CMISRequest*)retrieveChildren:(NSString *)objectId
                 orderBy:(NSString *)orderBy
                  filter:(NSString *)filter
           relationships:(CMISIncludeRelationship)relationships
         renditionFilter:(NSString *)renditionFilter
 includeAllowableActions:(BOOL)includeAllowableActions
      includePathSegment:(BOOL)includePathSegment
               skipCount:(NSNumber *)skipCount
                maxItems:(NSNumber *)maxItems
         completionBlock:(void (^)(CMISObjectList *objectList, NSError *error))completionBlock
{
    // Get Down link
    CMISRequest *request = [[CMISRequest alloc] init];
    [self loadLinkForObjectId:objectId
                     relation:kCMISLinkRelationDown
                         type:kCMISMediaTypeChildren
                  cmisRequest:request
              completionBlock:^(NSString *downLink, NSError *error) {
                          if (error) {
                              CMISLogError(@"Could not retrieve down link: %@", error.description);
                              completionBlock(nil, error);
                              return;
                          }
                          
                          // Add optional params (CMISUrlUtil will not append if the param name or value is nil)
                          downLink = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterFilter value:filter urlString:downLink];
                          downLink = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterOrderBy value:orderBy urlString:downLink];
                          downLink = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterIncludeAllowableActions value:(includeAllowableActions ? @"true" : @"false") urlString:downLink];
                          downLink = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterIncludeRelationships value:[CMISEnums stringForIncludeRelationShip:relationships] urlString:downLink];
                          downLink = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterRenditionFilter value:renditionFilter urlString:downLink];
                          downLink = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterIncludePathSegment value:(includePathSegment ? @"true" : @"false") urlString:downLink];
                          downLink = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterMaxItems value:[maxItems stringValue] urlString:downLink];
                          downLink = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterSkipCount value:[skipCount stringValue] urlString:downLink];
                          
                          // execute the request
                          [self.bindingSession.networkProvider invokeGET:[NSURL URLWithString:downLink]
                                                                 session:self.bindingSession
                                                             cmisRequest:request
                                                         completionBlock:^(CMISHttpResponse *httpResponse, NSError *error) {
                                  if (httpResponse) {
                                      if (httpResponse.data == nil) {
                                          NSError *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeConnection
                                                                           detailedDescription:nil];
                                          completionBlock(nil, error);
                                          return;
                                      }
                                      
                                      // Parse the feed (containing entries for the children) you get back
                                      CMISAtomFeedParser *parser = [[CMISAtomFeedParser alloc] initWithData:httpResponse.data];
                                      NSError *internalError = nil;
                                      if ([parser parseAndReturnError:&internalError]) {
                                          NSString *nextLink = [parser.linkRelations linkHrefForRel:kCMISLinkRelationNext];
                                          
                                          CMISObjectList *objectList = [[CMISObjectList alloc] init];
                                          objectList.hasMoreItems = (nextLink != nil);
                                          objectList.numItems = parser.numItems;
                                          objectList.objects = parser.entries;
                                          completionBlock(objectList, nil);
                                      } else {
                                          NSError *error = [CMISErrors cmisError:internalError cmisErrorCode:kCMISErrorCodeRuntime];
                                          completionBlock(nil, error);
                                      }
                                  } else {
                                      completionBlock(nil, error);
                                  }
                              }];
                      }];
    return request;
}

- (CMISRequest*)retrieveParentsForObject:(NSString *)objectId
                          filter:(NSString *)filter
                   relationships:(CMISIncludeRelationship)relationships
                 renditionFilter:(NSString *)renditionFilter
         includeAllowableActions:(BOOL)includeAllowableActions
      includeRelativePathSegment:(BOOL)includeRelativePathSegment
                 completionBlock:(void (^)(NSArray *parents, NSError *error))completionBlock
{
    // Get up link
    CMISRequest *request = [[CMISRequest alloc] init];
    [self loadLinkForObjectId:objectId
                     relation:kCMISLinkRelationUp
                  cmisRequest:request
              completionBlock:^(NSString *upLink, NSError *error) {
        if (upLink == nil) {
            CMISLogError(@"Failing because the NSString upLink is nil");
            completionBlock([NSArray array], nil); // TODO: shouldn't this return an error if the log talks about 'failing'?
            return;
        }
        
        // Add optional parameters
        if (filter != nil) {
            upLink = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterFilter value:filter urlString:upLink];
        }
        upLink = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterIncludeAllowableActions value:(includeAllowableActions ? @"true" : @"false") urlString:upLink];
        upLink = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterIncludeRelationships value:[CMISEnums stringForIncludeRelationShip:relationships] urlString:upLink];
        
        if (renditionFilter != nil) {
            upLink = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterRenditionFilter value:renditionFilter urlString:upLink];
        }
        
        upLink = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterRelativePathSegment value:(includeRelativePathSegment ? @"true" : @"false") urlString:upLink];
        
        [self.bindingSession.networkProvider invokeGET:[NSURL URLWithString:upLink]
                                               session:self.bindingSession
                                           cmisRequest:request
                                       completionBlock:^(CMISHttpResponse *httpResponse, NSError *error) {
                if (httpResponse) {
                    CMISAtomFeedParser *parser = [[CMISAtomFeedParser alloc] initWithData:httpResponse.data];
                    NSError *internalError;
                    if (![parser parseAndReturnError:&internalError]) {
                        NSError *error = [CMISErrors cmisError:internalError cmisErrorCode:kCMISErrorCodeRuntime];
                        CMISLogError(@"Failing because parsing the Atom Feed XML returns an error");
                        completionBlock([NSArray array], error);
                    } else {
                        completionBlock(parser.entries, nil);
                    }
                } else {
                    CMISLogError(@"Failing because the invokeGET returns an error");
                    completionBlock([NSArray array], error);
                }
            }];
    }];
    return request;
}

- (CMISRequest*)retrieveCheckedOutDocumentsInFolder:(NSString *)folderId
                                            orderBy:(NSString *)orderBy
                                             filter:(NSString *)filter
                                      relationships:(CMISIncludeRelationship)relationships
                                    renditionFilter:(NSString *)renditionFilter
                            includeAllowableActions:(BOOL)includeAllowableActions
                                          skipCount:(NSNumber *)skipCount
                                           maxItems:(NSNumber *)maxItems
                                    completionBlock:(void (^)(CMISObjectList *objectList, NSError *error))completionBlock
{
    // Get checked out link
    NSString *checkedoutLink = [self.bindingSession objectForKey:kCMISAtomBindingSessionKeyCheckedoutCollection];
    if (checkedoutLink == nil) {
        CMISLogDebug(@"Checkedout not supported!");
        completionBlock(nil, [CMISErrors createCMISErrorWithCode:kCMISErrorCodeNotSupported detailedDescription:nil]);
        return nil;
    }
    
    // add the parameters to the URL (CMISUrlUtil will not append if the param name or value is nil)
    checkedoutLink = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterFolderId value:folderId urlString:checkedoutLink];
    checkedoutLink = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterFilter value:filter urlString:checkedoutLink];
    checkedoutLink = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterOrderBy value:orderBy urlString:checkedoutLink];
    checkedoutLink = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterIncludeAllowableActions value:(includeAllowableActions ? @"true" : @"false") urlString:checkedoutLink];
    checkedoutLink = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterIncludeRelationships value:[CMISEnums stringForIncludeRelationShip:relationships] urlString:checkedoutLink];
    checkedoutLink = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterRenditionFilter value:renditionFilter urlString:checkedoutLink];
    checkedoutLink = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterMaxItems value:[maxItems stringValue] urlString:checkedoutLink];
    checkedoutLink = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterSkipCount value:[skipCount stringValue] urlString:checkedoutLink];
    
    // retrieve the list
    CMISRequest *request = [[CMISRequest alloc] init];
    [self.bindingSession.networkProvider invokeGET:[NSURL URLWithString:checkedoutLink]
                                           session:self.bindingSession
                                       cmisRequest:request
                                   completionBlock:^(CMISHttpResponse *httpResponse, NSError *error) {
        if (httpResponse) {
            if (httpResponse.data == nil) {
                NSError *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeConnection detailedDescription:nil];
                completionBlock(nil, error);
                return;
            }
             
            // Parse the feed (containing entries for the documents)
            CMISAtomFeedParser *parser = [[CMISAtomFeedParser alloc] initWithData:httpResponse.data];
            NSError *internalError = nil;
            if ([parser parseAndReturnError:&internalError]) {
                NSString *nextLink = [parser.linkRelations linkHrefForRel:kCMISLinkRelationNext];
                 
                CMISObjectList *objectList = [[CMISObjectList alloc] init];
                objectList.hasMoreItems = (nextLink != nil);
                objectList.numItems = parser.numItems;
                objectList.objects = parser.entries;
                completionBlock(objectList, nil);
            } else {
                NSError *error = [CMISErrors cmisError:internalError cmisErrorCode:kCMISErrorCodeRuntime];
                completionBlock(nil, error);
            }
        } else {
            completionBlock(nil, error);
        }
    }];

    return request;
}

@end
