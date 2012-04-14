//
//  CMISObjectConverter.m
//  HybridApp
//
//  Created by Cornwell Gavin on 22/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISObjectConverter.h"
#import "CMISDocument.h"
#import "CMISFolder.h"

@interface CMISObjectConverter ()
@property (nonatomic, strong) id<CMISBindingDelegate> binding;
@end

@implementation CMISObjectConverter

@synthesize binding = _binding;

- (id)initWithCMISBinding:(id<CMISBindingDelegate>)binding
{
    if (self = [super init])
    {
        self.binding = binding;
    }
    
    return self;
}

- (CMISObject *)convertObject:(CMISObjectData *)objectData
{
    CMISObject *object = nil;
    
    if (objectData.baseType == CMISBaseTypeDocument)
    {
        object = [[CMISDocument alloc] initWithObjectData:objectData binding:self.binding];
    }
    else if (objectData.baseType == CMISBaseTypeFolder)
    {
        object = [[CMISFolder alloc] initWithObjectData:objectData binding:self.binding];
    }
    
    return object;
}

- (CMISCollection *)convertObjects:(NSArray *)objects
{
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:[objects count]];
    
    for (CMISObjectData *object in objects) 
    {
        [items addObject:[self convertObject:object]];
    }
    
    // create the collection
    CMISCollection *collection = [[CMISCollection alloc] initWithItems:items];
    
    return collection;
}

@end
