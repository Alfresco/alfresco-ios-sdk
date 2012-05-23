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
#import "CMISErrors.h"
#import "CMISObjectConverter.h"
#import "CMISStringInOutParameter.h"

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

- (CMISObject *)updateProperties:(NSDictionary *)properties error:(NSError **)error
{
    // Validate properties param
    if (!properties || properties.count == 0)
    {
        *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument withDetailedDescription:@"Properties cannot be nil or empty"];
        return nil;
    }

    // Convert properties to an understandable format for the service
    CMISObjectConverter *converter = [[CMISObjectConverter alloc] initWithCMISBinding:self.binding];
    CMISProperties *convertedProperties = [converter convertProperties:properties forObjectTypeId:self.objectType error:error];

    if (convertedProperties != nil)
    {
        CMISStringInOutParameter *objectIdInOutParam = [CMISStringInOutParameter inOutParameterUsingInParameter:self.identifier];
        CMISStringInOutParameter *changeTokenInOutParam = [CMISStringInOutParameter inOutParameterUsingInParameter:self.changeToken];
        [self.binding.objectService updatePropertiesForObject:objectIdInOutParam withProperties:convertedProperties withChangeToken:changeTokenInOutParam error:error];

        if (objectIdInOutParam.outParameter != nil)
        {
            CMISObjectData *objectData = [self.binding.objectService retrieveObject:objectIdInOutParam.outParameter error:error];
            if (objectData != nil)
            {
                return [converter convertObject:objectData];
            }
        }
    }
    return nil;
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
