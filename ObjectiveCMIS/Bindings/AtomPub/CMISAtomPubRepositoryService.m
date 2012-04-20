//
//  CMISAtomPubRepositoryService.m
//  HybridApp
//
//  Created by Cornwell Gavin on 17/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISAtomPubRepositoryService.h"
#import "CMISConstants.h"
#import "CMISServiceDocumentParser.h"

#import "ASIHTTPRequest.h"

@interface CMISAtomPubRepositoryService ()
@property (nonatomic, strong) NSMutableDictionary *repositories;
@end

@interface CMISAtomPubRepositoryService (PrivateMethods)
- (void)retrieveRepositoriesAndReturnError:(NSError **)error;
@end


@implementation CMISAtomPubRepositoryService

@synthesize repositories = _repositories;

- (NSArray *)arrayOfRepositoriesAndReturnError:(NSError **)outError
{
    [self retrieveRepositoriesAndReturnError:outError];
    return [self.repositories allValues];
}

- (CMISRepositoryInfo *)repositoryInfoForId:(NSString *)repositoryId error:(NSError **)outError
{
    [self retrieveRepositoriesAndReturnError:outError];
    return [self.repositories objectForKey:repositoryId];
}

- (void)retrieveRepositoriesAndReturnError:(NSError **)error
{
    self.repositories = [NSMutableDictionary dictionary];
    
    // get the CMIS service document URL from the parameters
    NSURL *serviceDocUrl = self.sessionParameters.atomPubUrl;
    NSLog(@"CMISAtomPubRepositoryService GET: %@", [serviceDocUrl absoluteString]);
    
    // execute the request
    NSData *data = [self executeRequest:serviceDocUrl error:error];
    if (data != nil)
    {
        CMISServiceDocumentParser *parser = [[CMISServiceDocumentParser alloc] initWithData:data];
        if ([parser parseAndReturnError:error])
        {
            for (CMISWorkspace *workspace in [parser workspaces]) 
            {
                [self.repositories setObject:workspace.repositoryInfo forKey:workspace.repositoryInfo.identifier];
            }
        }
    }
}

@end
