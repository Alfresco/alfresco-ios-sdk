//
//  CMISAtomPubBaseService.m
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 10/04/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISAtomPubBaseService.h"
#import "HttpUtil.h"
#import "CMISServiceDocumentParser.h"
#import "CMISConstants.h"

@interface CMISAtomPubBaseService ()
@property (nonatomic, strong, readwrite) CMISSessionParameters *sessionParameters;
@end

@implementation CMISAtomPubBaseService

@synthesize sessionParameters = _sessionParameters;

- (id)initWithSessionParameters:(CMISSessionParameters *)sessionParameters
{
    self = [super init];
    if (self)
    {
        self.sessionParameters = sessionParameters;
    }
    return self;
}


#pragma mark -
#pragma mark Protected methods

- (NSArray *)retrieveCMISWorkspacesWithError:(NSError * *)error
{
    if ([self.sessionParameters objectForKey:kCMISSessionKeyWorkspaces] == nil)
    {
        NSData *data = [HttpUtil invokeGET:self.sessionParameters.atomPubUrl withSession:self.sessionParameters error:error];

        // Parse the cmis service document
        if (data != nil)
        {
            CMISServiceDocumentParser *parser = [[CMISServiceDocumentParser alloc] initWithData:data];
            if ([parser parseAndReturnError:error])
            {
                [[self sessionParameters] setObject:parser.workspaces forKey:kCMISSessionKeyWorkspaces];
            } else
            {
                log(@"Error while parsing service document: %@", [*error description]);
            }
        }
    }

    return (NSArray *) [self.sessionParameters objectForKey:kCMISSessionKeyWorkspaces];

}

- (NSData *)executeRequest:(NSURL *)url error:(NSError **)error
{
    return [HttpUtil invokeGET:url withSession:self.sessionParameters error:error];
}

@end
