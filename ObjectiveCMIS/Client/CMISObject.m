//
//  CMISObject.m
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 21/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISObject.h"
#import "CMISConstants.h"
#import "ISO8601DateFormatter.h"

@interface CMISObject ()

@property (nonatomic, strong, readwrite) id<CMISBinding> binding;

@property (nonatomic, strong, readwrite) NSString *identifier;
@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) NSString *createdBy;
@property (nonatomic, strong, readwrite) NSDate *creationDate;
@property (nonatomic, strong, readwrite) NSString *lastModifiedBy;
@property (nonatomic, strong, readwrite) NSDate *lastModificationDate;
@property (nonatomic, strong, readwrite) NSString *objectType;
@property (nonatomic, strong, readwrite) NSString *changeToken;

@property (nonatomic, strong, readwrite) CMISProperties *properties;

@end

@implementation CMISObject

@synthesize binding = _binding;
@synthesize identifier = _identifier;
@synthesize name = _name;
@synthesize createdBy = _createdBy;
@synthesize creationDate = _creationDate;
@synthesize lastModifiedBy = _lastModifiedBy;
@synthesize lastModificationDate = _lastModificationDate;
@synthesize objectType = _objectType;
@synthesize changeToken = _changeToken;
@synthesize properties = _properties;


- (id)initWithObjectData:(CMISObjectData *)objectData binding:(id<CMISBinding>)binding;
{
    self =  [super initWithString:objectData.identifier];
    if (self)
    {
        self.binding = binding;

        self.properties = objectData.properties;
        self.name = [[self.properties propertyForId:kCMISPropertyName] firstValue];
        self.createdBy = [[self.properties propertyForId:kCMISPropertyCreatedBy] firstValue];
        self.lastModifiedBy = [[self.properties propertyForId:kCMISPropertyModifiedBy] firstValue];
        self.creationDate = [[self.properties propertyForId:kCMISPropertyCreationDate] firstValue];
        self.lastModificationDate = [[self.properties propertyForId:kCMISPropertyModificationDate] firstValue];
        self.objectType = [[self.properties propertyForId:kCMISPropertyObjectTypeId] firstValue];
        self.changeToken = [[self.properties propertyForId:kCMISPropertyChangeToken] firstValue];
    }
    
    return self;
}

- (NSArray *)extensionsForExtensionLevel:(CMISExtensionLevel)extensionLevel
{
    // TODO Need to implement the following extension levels CMISExtensionLevelObject, CMISExtensionLevelAllowableActions, CMISExtensionLevelAcl, CMISExtensionLevelPolicies, CMISExtensionLevelChangeEvent
    
    NSArray *extensions = nil;
    
    switch (extensionLevel) 
    {
        case CMISExtensionLevelProperties:
        {
            extensions = self.properties.extensions;
            break;
        }
        default:
            break;
    }
    
    return extensions;
}

@end
