//
//  CMISFolder.h
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 21/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISFileableObject.h"
#import "CMISCollection.h"

@class CMISDocument;
@class CMISPagedResult;
@class CMISOperationContext;

@interface CMISFolder : CMISFileableObject

@property (nonatomic, strong, readonly) NSString *path;

/**
 * Retrieves the children of this folder as a paged result.
 *
 * The returned objects will be instances of CMISObject.
 */
- (CMISPagedResult *)retrieveChildrenAndReturnError:(NSError * *)error;

/**
 * Retrieves the children of this folder as a paged result using the provided operation context.
 *
 * The returned objects will be instances of CMISObject.
 */
- (CMISPagedResult *)retrieveChildrenWithOperationContext:(CMISOperationContext *)operationContext andReturnError:(NSError * *)error;

- (NSString *)createFolder:(NSDictionary *)properties error:(NSError * *)error;

- (NSString *)createDocumentFromFilePath:(NSString *)filePath withMimeType:(NSString *)mimeType withProperties:(NSDictionary *)properties error:(NSError **)error;

- (NSArray *)deleteTreeAndReturnError:(NSError * *)error;

@end


