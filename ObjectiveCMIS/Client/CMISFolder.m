//
//  CMISFolder.m
//  HybridApp
//
//  Created by Cornwell Gavin on 21/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISFolder.h"
#import "CMISObjectConverter.h"
#import "CMISDocument.h"

@interface CMISFolder ()
@property (nonatomic, strong) CMISCollection *children;
@end

@implementation CMISFolder

@synthesize children = _children;


- (CMISCollection *)collectionOfChildrenAndReturnError:(NSError * *)error
{
    if (self.children == nil)
    {
        NSArray *children = [self.binding.navigationService retrieveChildren:[self identifier] error:error];
        
        CMISObjectConverter *objConverter = [[CMISObjectConverter alloc] initWithCMISBinding:self.binding];
        self.children = [objConverter convertObjects:children];
    }
    
    return self.children;
}

- (NSString *)createFolder:(NSDictionary *)properties error:(NSError **)error;
{
    return [self.binding.objectService createFolderInParentFolder:self.identifier withProperties:properties error:error];
}

- (NSString *)createDocumentFromFilePath:(NSString *)filePath withMimeType:(NSString *)mimeType withProperties:(NSDictionary *)properties error:(NSError **)error
{
    return [self.binding.objectService createDocumentFromFilePath:filePath withMimeType:mimeType withProperties:properties inFolder:self.identifier error:error];
}

- (NSArray *)deleteTreeAndReturnError:(NSError **)error
{
    return [self.binding.objectService deleteTree:self.identifier error:error];
}


@end
