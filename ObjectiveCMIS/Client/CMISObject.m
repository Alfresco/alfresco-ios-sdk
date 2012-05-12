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

- (id)initWithObjectData:(CMISObjectData *)objectData binding:(id<CMISBinding>)binding;
{
    self =  [super initWithString:objectData.identifier];
    if (self)
    {
        self.binding = binding;

        self.name = [[objectData.properties.properties objectForKey:kCMISPropertyName] firstValue];
        self.createdBy = [[objectData.properties.properties objectForKey:kCMISPropertyCreatedBy] firstValue];
        self.lastModifiedBy = [[objectData.properties.properties objectForKey:kCMISPropertyModifiedBy] firstValue];
        self.creationDate = [[objectData.properties.properties objectForKey:kCMISPropertyCreationDate] firstValue];
        self.lastModificationDate = [[objectData.properties.properties objectForKey:kCMISPropertyModificationDate] firstValue];
        self.objectType = [[objectData.properties.properties objectForKey:kCMISPropertyObjectTypeId] firstValue];
    }
    
    return self;
}

@end
