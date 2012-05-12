//
//  CMISRepositoryInfo.m
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 10/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISRepositoryInfo.h"

@implementation CMISRepositoryInfo

@synthesize identifier = _identifier;
@synthesize name = _name;
@synthesize desc = _desc;
@synthesize rootFolderId = _rootFolderId;
@synthesize cmisVersionSupported = _cmisVersionSupported;
@synthesize productName = _productName;
@synthesize productVersion = _productVersion;
@synthesize vendorName = _vendorName;

- (NSString *)description
{
    return [NSString stringWithFormat:@"identifer: %@, name: %@, version: %@", 
            self.identifier, self.name, self.productVersion];
}

@end
