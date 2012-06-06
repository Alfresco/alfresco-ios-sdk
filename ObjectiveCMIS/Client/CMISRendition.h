//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISRenditionData.h"
#import "CMISTypeDefs.h"

@class CMISDocument;
@class CMISOperationContext;
@class CMISSession;


@interface CMISRendition : CMISRenditionData

- (id)initWithRenditionData:(CMISRenditionData *)renditionData andObjectId:(NSString *)objectId andSession:(CMISSession *)session;

- (CMISDocument *)retrieveRenditionDocumentAndReturnError:(NSError **)error;

- (CMISDocument *)retrieveRenditionDocumentWithOperationContext:(CMISOperationContext *)operationContext withError:(NSError **)error;

- (void)downloadRenditionContentToFile:(NSString *)filePath
                                completionBlock:(CMISVoidCompletionBlock)completionBlock
                                failureBlock:(CMISErrorFailureBlock)failureBlock
                                progressBlock:(CMISProgressBlock)progressBlock;

@end