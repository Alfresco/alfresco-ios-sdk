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

#import "CMISRendition.h"
#import "CMISDocument.h"
#import "CMISOperationContext.h"
#import "CMISSession.h"
#import "CMISRequest.h"
#import "CMISLog.h"

@interface CMISRendition ()

@property (nonatomic, strong) CMISSession *session;
@property (nonatomic, strong) NSString *objectId;

@end

@implementation CMISRendition


- (id)initWithRenditionData:(CMISRenditionData *)renditionData objectId:(NSString *)objectId session:(CMISSession *)session
{
    self = [super initWithRenditionData:renditionData];
    if (self) {
        self.objectId = objectId;
        self.session = session;
    }
    return self;
}

- (CMISRequest*)retrieveRenditionDocumentWithCompletionBlock:(void (^)(CMISDocument *document, NSError *error))completionBlock
{
    return [self retrieveRenditionDocumentWithOperationContext:[CMISOperationContext defaultOperationContext] completionBlock:completionBlock];
}

- (CMISRequest*)retrieveRenditionDocumentWithOperationContext:(CMISOperationContext *)operationContext
                                      completionBlock:(void (^)(CMISDocument *document, NSError *error))completionBlock
{
    if (self.renditionDocumentId == nil) {
        CMISLogError(@"Cannot retrieve rendition document: no renditionDocumentId was returned by the server.");
        completionBlock(nil, nil);
        return nil;
    }

    return [self.session retrieveObject:self.renditionDocumentId operationContext:operationContext completionBlock:^(CMISObject *renditionDocument, NSError *error) {
        if (renditionDocument != nil && !([[renditionDocument class] isKindOfClass:[CMISDocument class]])) {
            completionBlock(nil, nil);
            return;
        }
        
        completionBlock((CMISDocument *) renditionDocument, nil);
    }];
}

- (CMISRequest*)downloadRenditionContentToFile:(NSString *)filePath
                       completionBlock:(void (^)(NSError *error))completionBlock
                         progressBlock:(void (^)(unsigned long long bytesDownloaded, unsigned long long bytesTotal))progressBlock
{
    if (self.objectId == nil || self.streamId == nil) {
        CMISLogError(@"Object id or stream id is nil. Both are needed when fetching the content of a rendition");
        return nil;
    }

    return [self.session.binding.objectService downloadContentOfObject:self.objectId
                                                              streamId:self.streamId
                                                                toFile:filePath
                                                       completionBlock:completionBlock
                                                         progressBlock:progressBlock];
}

- (CMISRequest*)downloadRenditionContentToOutputStream:(NSOutputStream *)outputStream
                               completionBlock:(void (^)(NSError *error))completionBlock
                                 progressBlock:(void (^)(unsigned long long bytesDownloaded, unsigned long long bytesTotal))progressBlock
{
    if (self.objectId == nil || self.streamId == nil) {
        CMISLogError(@"Object id or stream id is nil. Both are needed when fetching the content of a rendition");
        return nil;
    }
    
    return [self.session.binding.objectService downloadContentOfObject:self.objectId
                                                              streamId:self.streamId
                                                        toOutputStream:outputStream
                                                       completionBlock:completionBlock
                                                         progressBlock:progressBlock];
}

@end