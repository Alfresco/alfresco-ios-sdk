//
//  CMISFolder.m
//  HybridApp
//
//  Created by Cornwell Gavin on 21/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISFolder.h"
#import "CMISObjectConverter.h"

@interface CMISFolder ()
@property (nonatomic, strong) CMISCollection *children;
@end

@implementation CMISFolder

@synthesize children = _children;

- (CMISCollection *)collectionOfChildrenAndReturnError:(NSError *)error
{
    if (self.children == nil)
    {
        NSArray *children = [self.binding.navigationService retrieveChildren:[self identifier] error:&error];
        
        CMISObjectConverter *objConverter = [[CMISObjectConverter alloc] initWithCMISBinding:self.binding];
        self.children = [objConverter convertObjects:children];
    }
    
    return self.children;
}


@end
