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
#import "CMISErrors.h"

@interface CMISFolder ()

@property (nonatomic, strong, readwrite) NSString *path;
@property (nonatomic, strong, readwrite) CMISCollection *children;
@end

@implementation CMISFolder

@synthesize path = _path;
@synthesize children = _children;

- (id)initWithObjectData:(CMISObjectData *)objectData withSession:(CMISSession *)session
{
    self = [super initWithObjectData:objectData withSession:session];
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

        CMISObjectConverter *objConverter = [[CMISObjectConverter alloc] initWithSession:self.session];
        self.children = [objConverter convertObjects:children];
    }
    
    return self.children;
}

- (NSString *)createFolder:(NSDictionary *)properties error:(NSError **)error;
{
    NSError *internalError = nil;
    CMISObjectConverter *converter = [[CMISObjectConverter alloc] initWithSession:self.session];
    CMISProperties *convertedProperties = [converter convertProperties:properties forObjectTypeId:kCMISPropertyObjectTypeIdValueFolder error:&internalError];
    if (internalError != nil)
    {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeRuntime];
        return nil;
    }

    return [self.binding.objectService createFolderInParentFolder:self.identifier withProperties:convertedProperties error:error];
}

- (NSString *)createDocumentFromFilePath:(NSString *)filePath withMimeType:(NSString *)mimeType withProperties:(NSDictionary *)properties error:(NSError **)error
{
    NSError *internalError = nil;
    CMISObjectConverter *converter = [[CMISObjectConverter alloc] initWithSession:self.session];
    CMISProperties *convertedProperties = [converter convertProperties:properties forObjectTypeId:kCMISPropertyObjectTypeIdValueDocument error:&internalError];
    if (internalError != nil)
    {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeRuntime];
        return nil;
    }

    return [self.binding.objectService createDocumentFromFilePath:filePath withMimeType:mimeType withProperties:convertedProperties inFolder:self.identifier error:error];
}

- (NSArray *)deleteTreeAndReturnError:(NSError **)error
{
    return [self.binding.objectService deleteTree:self.identifier error:error];
}


@end
