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

#import "CMISDocument.h"
#import "CMISConstants.h"
#import "CMISObjectConverter.h"
#import "CMISStringInOutParameter.h"
#import "CMISOperationContext.h"
#import "CMISErrors.h"
#import "CMISRequest.h"
#import "CMISSession.h"
#import "CMISLog.h"

@interface CMISDocument()

@property (nonatomic, strong, readwrite) NSString *contentStreamId;
@property (nonatomic, strong, readwrite) NSString *contentStreamFileName;
@property (nonatomic, strong, readwrite) NSString *contentStreamMediaType;
@property (readwrite) unsigned long long contentStreamLength;

@property (nonatomic, strong, readwrite) NSString *versionLabel;
@property (nonatomic, assign, readwrite, getter = isLatestVersion) BOOL latestVersion;
@property (nonatomic, assign, readwrite, getter = isMajorVersion) BOOL majorVersion;
@property (nonatomic, assign, readwrite, getter = isLatestMajorVersion) BOOL latestMajorVersion;
@property (nonatomic, strong, readwrite) NSString *versionSeriesId;

@end

@implementation CMISDocument

- (id)initWithObjectData:(CMISObjectData *)objectData session:(CMISSession *)session
{
    self = [super initWithObjectData:objectData session:session];
    if (self) {
        self.contentStreamId = [[objectData.properties.propertiesDictionary objectForKey:kCMISPropertyContentStreamId] firstValue];
        self.contentStreamMediaType = [[objectData.properties.propertiesDictionary objectForKey:kCMISPropertyContentStreamMediaType] firstValue];
        self.contentStreamLength = [[[objectData.properties.propertiesDictionary objectForKey:kCMISPropertyContentStreamLength] firstValue] unsignedLongLongValue];
        self.contentStreamFileName = [[objectData.properties.propertiesDictionary objectForKey:kCMISPropertyContentStreamFileName] firstValue];

        self.versionLabel = [[objectData.properties.propertiesDictionary objectForKey:kCMISPropertyVersionLabel] firstValue];
        self.versionSeriesId = [[objectData.properties.propertiesDictionary objectForKey:kCMISPropertyVersionSeriesId] firstValue];
        self.latestVersion = [[[objectData.properties.propertiesDictionary objectForKey:kCMISPropertyIsLatestVersion] firstValue] boolValue];
        self.latestMajorVersion = [[[objectData.properties.propertiesDictionary objectForKey:kCMISPropertyIsLatestMajorVersion] firstValue] boolValue];
        self.majorVersion = [[[objectData.properties.propertiesDictionary objectForKey:kCMISPropertyIsMajorVersion] firstValue] boolValue];
    }
    return self;
}

- (CMISRequest*)retrieveAllVersionsWithCompletionBlock:(void (^)(CMISCollection *allVersionsOfDocument, NSError *error))completionBlock
{
    return [self retrieveAllVersionsWithOperationContext:[CMISOperationContext defaultOperationContext] completionBlock:completionBlock];
}

- (CMISRequest*)retrieveAllVersionsWithOperationContext:(CMISOperationContext *)operationContext completionBlock:(void (^)(CMISCollection *collection, NSError *error))completionBlock
{
    return [self.binding.versioningService retrieveAllVersions:self.identifier
           filter:operationContext.filterString includeAllowableActions:operationContext.includeAllowableActions completionBlock:^(NSArray *objects, NSError *error) {
               if (error) {
                   CMISLogError(@"Error while retrieving all versions: %@", error.description);
                   completionBlock(nil, [CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeRuntime]);
               } else {
                   [self.session.objectConverter convertObjects:objects
                                                completionBlock:^(NSArray *objects, NSError *error) {
                                                    completionBlock([[CMISCollection alloc] initWithItems:objects], error);
                                                }];
               }
           }];
}

- (CMISRequest*)changeContentToContentOfFile:(NSString *)filePath
                                    mimeType:(NSString *)mimeType
                                   overwrite:(BOOL)overwrite
                             completionBlock:(void (^)(NSError *error))completionBlock
                               progressBlock:(void (^)(unsigned long long bytesUploaded, unsigned long long bytesTotal))progressBlock
{
    return [self.binding.objectService changeContentOfObject:[CMISStringInOutParameter inOutParameterUsingInParameter:self.identifier]
                                             toContentOfFile:filePath
                                                    mimeType:mimeType
                                           overwriteExisting:overwrite
                                                 changeToken:[CMISStringInOutParameter inOutParameterUsingInParameter:self.changeToken]
                                             completionBlock:completionBlock
                                               progressBlock:progressBlock];
}

- (CMISRequest*)changeContentToContentOfInputStream:(NSInputStream *)inputStream
                                      bytesExpected:(unsigned long long)bytesExpected
                                           fileName:(NSString *)filename
                                           mimeType:(NSString *)mimeType
                                          overwrite:(BOOL)overwrite
                                    completionBlock:(void (^)(NSError *error))completionBlock
                                      progressBlock:(void (^)(unsigned long long bytesUploaded, unsigned long long bytesTotal))progressBlock
{
    return [self.binding.objectService changeContentOfObject:[CMISStringInOutParameter inOutParameterUsingInParameter:self.identifier]
                                      toContentOfInputStream:inputStream
                                               bytesExpected:bytesExpected
                                                    filename:filename
                                                    mimeType:mimeType
                                           overwriteExisting:overwrite
                                                 changeToken:[CMISStringInOutParameter inOutParameterUsingInParameter:self.changeToken]
                                             completionBlock:completionBlock
                                               progressBlock:progressBlock];
}

- (CMISRequest*)deleteContentWithCompletionBlock:(void (^)(NSError *error))completionBlock
{
    return [self.binding.objectService deleteContentOfObject:[CMISStringInOutParameter inOutParameterUsingInParameter:self.identifier]
                                      changeToken:[CMISStringInOutParameter inOutParameterUsingInParameter:self.changeToken]
                                      completionBlock:completionBlock];
}

- (CMISRequest*)retrieveObjectOfLatestVersionWithMajorVersion:(BOOL)major completionBlock:(void (^)(CMISDocument *document, NSError *error))completionBlock
{
    return [self retrieveObjectOfLatestVersionWithMajorVersion:major operationContext:[CMISOperationContext defaultOperationContext] completionBlock:completionBlock];
}

- (CMISRequest*)retrieveObjectOfLatestVersionWithMajorVersion:(BOOL)major
                                             operationContext:(CMISOperationContext *)operationContext
                                              completionBlock:(void (^)(CMISDocument *document, NSError *error))completionBlock
{
    return [self.binding.versioningService retrieveObjectOfLatestVersion:self.identifier
                                                                   major:major filter:operationContext.filterString
                                                           relationships:operationContext.relationships
                                                        includePolicyIds:operationContext.includePolicies
                                                         renditionFilter:operationContext.renditionFilterString
                                                              includeACL:operationContext.includeACLs
                                                 includeAllowableActions:operationContext.includeAllowableActions
                                                         completionBlock:^(CMISObjectData *objectData, NSError *error) {
            if (error) {
                completionBlock(nil, [CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeRuntime]);
            } else {
                [self.session.objectConverter convertObject:objectData
                                            completionBlock:^(CMISObject *object, NSError *error) {
                                                completionBlock((CMISDocument *)object, error);
                                            }];
            }
        }];
}

- (CMISRequest*)downloadContentToFile:(NSString *)filePath
                      completionBlock:(void (^)(NSError *error))completionBlock
                        progressBlock:(void (^)(unsigned long long bytesDownloaded, unsigned long long bytesTotal))progressBlock
{
    return [self downloadContentToFile:filePath
                                offset:nil
                                length:nil
                       completionBlock:completionBlock
                         progressBlock:^(unsigned long long bytesDownloaded, unsigned long long bytesTotal) {
                             if (progressBlock) {
                                 progressBlock(bytesDownloaded, bytesTotal);
                             }
                         }];
}


- (CMISRequest*)downloadContentToOutputStream:(NSOutputStream *)outputStream
                              completionBlock:(void (^)(NSError *error))completionBlock
                                progressBlock:(void (^)(unsigned long long bytesDownloaded, unsigned long long bytesTotal))progressBlock
{
    return [self downloadContentToOutputStream:outputStream
                                        offset:nil
                                        length:nil
                               completionBlock:completionBlock
                                 progressBlock:^(unsigned long long bytesDownloaded, unsigned long long bytesTotal) {
                                     if (progressBlock) {
                                         progressBlock(bytesDownloaded, bytesTotal);
                                     }
                                 }];
}

- (CMISRequest*)downloadContentToFile:(NSString *)filePath
                               offset:(NSDecimalNumber*)offset
                               length:(NSDecimalNumber*)length
                      completionBlock:(void (^)(NSError *error))completionBlock
                        progressBlock:(void (^)(unsigned long long bytesDownloaded, unsigned long long bytesTotal))progressBlock
{
    NSOutputStream *outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    return [self.binding.objectService downloadContentOfObject:self.identifier
                                                      streamId:nil
                                                toOutputStream:outputStream
                                                        offset:offset
                                                        length:length
                                               completionBlock:completionBlock
                                                 progressBlock:progressBlock];
}


- (CMISRequest*)downloadContentToOutputStream:(NSOutputStream *)outputStream
                                       offset:(NSDecimalNumber*)offset
                                       length:(NSDecimalNumber*)length
                              completionBlock:(void (^)(NSError *error))completionBlock
                                progressBlock:(void (^)(unsigned long long bytesDownloaded, unsigned long long bytesTotal))progressBlock
{
    return [self.binding.objectService downloadContentOfObject:self.identifier
                                                      streamId:nil
                                                toOutputStream:outputStream
                                                        offset:offset
                                                        length:length
                                               completionBlock:completionBlock
                                                 progressBlock:progressBlock];
}


- (CMISRequest*)deleteAllVersionsWithCompletionBlock:(void (^)(BOOL documentDeleted, NSError *error))completionBlock
{
    return [self.binding.objectService deleteObject:self.identifier allVersions:YES completionBlock:completionBlock];
}

- (CMISRequest *)checkOutWithCompletionBlock:(void (^)(CMISDocument *privateWorkingCopy, NSError *error))completionBlock
{
    return [self.binding.versioningService checkOut:self.identifier completionBlock:^(CMISObjectData *objectData, NSError *error) {
        if (error) {
            completionBlock(nil, [CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeVersioning]);
        } else {
            [self.session.objectConverter convertObject:objectData completionBlock:^(CMISObject *object, NSError *error) {
                if (error) {
                    [CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeVersioning];
                } else {
                    completionBlock((CMISDocument*)object, nil);
                }
            }];
        }
    }];
}

- (CMISRequest *)cancelCheckOutWithCompletionBlock:(void (^)(BOOL, NSError *))completionBlock
{
    return [self.binding.versioningService cancelCheckOut:self.identifier completionBlock:^(BOOL checkOutCancelled, NSError *error) {
        if (error) {
            completionBlock(NO, [CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeVersioning]);
        } else {
            completionBlock(YES, nil);
        }
    }];
}

- (CMISRequest*)checkInAsMajorVersion:(BOOL)majorVersion
                             filePath:(NSString *)filePath
                             mimeType:(NSString *)mimeType
                           properties:(CMISProperties *)properties
                       checkinComment:(NSString *)checkinComment
                      completionBlock:(void (^)(CMISDocument *document, NSError *error))completionBlock
                        progressBlock:(void (^)(unsigned long long bytesUploaded, unsigned long long bytesTotal))progressBlock
{
    return [self.binding.versioningService checkIn:self.identifier
                                    asMajorVersion:majorVersion
                                          filePath:filePath
                                          mimeType:mimeType
                                        properties:properties
                                    checkinComment:checkinComment
                                   completionBlock:^(CMISObjectData *objectData, NSError *error) {
        if (error) {
            completionBlock(nil, [CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeVersioning]);
        } else {
            // convert the object data to document object
            [self.session.objectConverter convertObject:objectData completionBlock:^(CMISObject *object, NSError *error) {
                if (error) {
                    [CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeVersioning];
                } else {
                    completionBlock((CMISDocument*)object, nil);
                }
            }];
        }
    } progressBlock:progressBlock];
}

- (CMISRequest*)checkInAsMajorVersion:(BOOL)majorVersion
                          inputStream:(NSInputStream *)inputStream
                        bytesExpected:(unsigned long long)bytesExpected
                             mimeType:(NSString *)mimeType
                           properties:(CMISProperties *)properties
                       checkinComment:(NSString *)checkinComment
                      completionBlock:(void (^)(CMISDocument *document, NSError *error))completionBlock
                        progressBlock:(void (^)(unsigned long long bytesUploaded, unsigned long long bytesTotal))progressBlock
{
    return [self.binding.versioningService checkIn:self.identifier
                                    asMajorVersion:majorVersion
                                       inputStream:inputStream
                                     bytesExpected:bytesExpected
                                          mimeType:mimeType
                                        properties:properties
                                    checkinComment:checkinComment
                                   completionBlock:^(CMISObjectData *objectData, NSError *error) {
        if (error) {
            completionBlock(nil, [CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeVersioning]);
        } else {
            // convert the object data to document object
            [self.session.objectConverter convertObject:objectData completionBlock:^(CMISObject *object, NSError *error) {
                if (error) {
                    [CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeVersioning];
                } else {
                    completionBlock((CMISDocument*)object, nil);
                }
            }];
        }
    } progressBlock:progressBlock];
}

@end
