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

@interface CMISFolder : CMISFileableObject

@property (nonatomic, strong, readonly) NSString *path;

- (CMISCollection *)collectionOfChildrenAndReturnError:(NSError * *)error;

- (NSString *)createFolder:(NSDictionary *)properties error:(NSError * *)error;

- (NSString *)createDocumentFromFilePath:(NSString *)filePath withMimeType:(NSString *)mimeType withProperties:(NSDictionary *)properties error:(NSError **)error;

- (NSArray *)deleteTreeAndReturnError:(NSError * *)error;

@end


