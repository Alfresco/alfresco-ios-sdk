//
//  CMISObject.m
//  HybridApp
//
//  Created by Cornwell Gavin on 21/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISObject.h"
#import "CMISConstants.h"
#import "ISO8601DateFormatter.h"

@interface CMISObject ()
@property (nonatomic, strong, readwrite) id<CMISBinding> binding;
@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) NSString *createdBy;
@property (nonatomic, strong, readwrite) NSDate *creationDate;
@property (nonatomic, strong, readwrite) NSString *lastModifiedBy;
@property (nonatomic, strong, readwrite) NSDate *lastModificationDate;
@end

@implementation CMISObject

@synthesize binding = _binding;
@synthesize name = _name;
@synthesize createdBy = _createdBy;
@synthesize creationDate = _creationDate;
@synthesize lastModifiedBy = _lastModifiedBy;
@synthesize lastModificationDate = _lastModificationDate;


- (id)initWithObjectData:(CMISObjectData *)objectData binding:(id<CMISBinding>)binding;
{
    self =  [super initWithString:objectData.identifier];
    if (self)
    {
        self.binding = binding;
        
        self.name = [[objectData.properties.properties objectForKey:kCMISPropertyName] firstValue];
        self.createdBy = [[objectData.properties.properties objectForKey:kCMISPropertyCreatedBy] firstValue];
        self.lastModifiedBy = [[objectData.properties.properties objectForKey:kCMISPropertyModifiedBy] firstValue];

        // convert properties to NSDate
        ISO8601DateFormatter *isoFormatter = [[ISO8601DateFormatter alloc] init];
        
        NSString *date = [[objectData.properties.properties objectForKey:kCMISPropertyCreationDate] firstValue];
        if (date != nil)
        {
            self.creationDate = [isoFormatter dateFromString:date];
        }
        
        date = [[objectData.properties.properties objectForKey:kCMISPropertyModificationDate] firstValue];
        if (date != nil)
        {
            self.lastModificationDate = [isoFormatter dateFromString:date];
        }
    }
    
    return self;
}

@end
