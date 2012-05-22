//
//  CMISFolder.m
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 21/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISFolder.h"
#import "CMISObjectConverter.h"
#import "CMISConstants.h"

@interface CMISFolder ()

@property (nonatomic, strong, readwrite) NSString *path;
@property (nonatomic, strong, readwrite) CMISCollection *children;
@end

@implementation CMISFolder

@synthesize path = _path;
@synthesize children = _children;

- (id)initWithObjectData:(CMISObjectData *)objectData binding:(id <CMISBinding>)binding
{
    self = [super initWithObjectData:objectData binding:binding];
    if (self)
    {
        self.path = [[objectData.properties propertyForId:kCMISPropertyPath] firstValue];
    }
    return self;
}


- (CMISCollection *)collectionOfChildrenAndReturnError:(NSError * *)error
{
    if (self.children == nil)
    {
        NSArray *children = [self.binding.navigationService retrieveChildren:self.identifier error:error];

        CMISObjectConverter *objConverter = [[CMISObjectConverter alloc] initWithCMISBinding:self.binding];
        self.children = [objConverter convertObjects:children];
    }
    
    return self.children;
}

- (NSString *)createFolder:(CMISProperties *)properties error:(NSError **)error;
{
    return [self.binding.objectService createFolderInParentFolder:self.identifier withProperties:properties error:error];
}

- (NSString *)createDocumentFromFilePath:(NSString *)filePath withMimeType:(NSString *)mimeType withProperties:(CMISProperties *)properties error:(NSError **)error
{
    return [self.binding.objectService createDocumentFromFilePath:filePath withMimeType:mimeType withProperties:properties inFolder:self.identifier error:error];
}

- (NSArray *)deleteTreeAndReturnError:(NSError **)error
{
    return [self.binding.objectService deleteTree:self.identifier error:error];
}


@end
