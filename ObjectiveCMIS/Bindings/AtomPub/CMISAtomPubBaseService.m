//
//  CMISAtomPubBaseService.m
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 10/04/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISAtomPubBaseService.h"
#import "HttpUtil.h"

@interface CMISAtomPubBaseService ()

@end

@implementation CMISAtomPubBaseService

@synthesize sessionParameters = _sessionParameters;

- (id)initWithSessionParameters:(CMISSessionParameters *)sessionParameters
{
    self = [super init];
    if (self)
    {
        _sessionParameters = sessionParameters;
    }
    return self;
}


#pragma mark -
#pragma mark Protected methods

- (NSData *)executeRequest:(NSURL *)url error:(NSError **)error
{
    return [HttpUtil invokeGET:url withSession:self.sessionParameters error:error];
}

@end
