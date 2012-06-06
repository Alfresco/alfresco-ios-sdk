//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISRendition.h"
#import "CMISDocument.h"
#import "CMISOperationContext.h"
#import "CMISSession.h"

@interface CMISRendition ()

@property (nonatomic, strong) CMISSession *session;
@property (nonatomic, strong) NSString *objectId;

@end

@implementation CMISRendition

@synthesize session = _session;
@synthesize objectId = _objectId;

- (id)initWithRenditionData:(CMISRenditionData *)renditionData andObjectId:(NSString *)objectId andSession:(CMISSession *)session
{
    self = [super initWithRenditionData:renditionData];
    if (self)
    {
        self.objectId = objectId;
        self.session = session;
    }
    return self;
}

- (CMISDocument *)retrieveRenditionDocumentAndReturnError:(NSError **)error
{
    return [self retrieveRenditionDocumentWithOperationContext:[CMISOperationContext defaultOperationContext] withError:error];
}

- (CMISDocument *)retrieveRenditionDocumentWithOperationContext:(CMISOperationContext *)operationContext withError:(NSError **)error
{
    if (self.renditionDocumentId == nil)
    {
        log(@"Cannot retrieve rendition document: no renditionDocumentId was returned by the server.");
        return nil;
    }

    CMISObject *renditionDocument = [self.session retrieveObject:self.renditionDocumentId withOperationContext:operationContext error:error];
    if (renditionDocument != nil && !([[renditionDocument class] isKindOfClass:[CMISDocument class]]))
    {
        log(@"Returned object was not of document type");
        return nil;
    }

    return (CMISDocument *) renditionDocument;
}

- (void)downloadRenditionContentToFile:(NSString *)filePath completionBlock:(CMISVoidCompletionBlock)completionBlock failureBlock:(CMISErrorFailureBlock)failureBlock progressBlock:(CMISProgressBlock)progressBlock
{
    if (self.objectId == nil || self.streamId == nil)
    {
        log(@"Object id or stream id is nil. Both are needed when fetching the content of a rendition");
        return;
    }

    [self.session.binding.objectService downloadContentOfObject:self.objectId
                                                   withStreamId:self.streamId
                                                         toFile:filePath
                                                completionBlock:completionBlock
                                                   failureBlock:failureBlock
                                                  progressBlock:progressBlock];
}

@end