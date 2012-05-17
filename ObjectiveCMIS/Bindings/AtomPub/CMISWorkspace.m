//
// ObjectiveCMIS
//
// Created by Joram Barrez
//


#import "CMISWorkspace.h"
#import "CMISRepositoryInfo.h"
#import "CMISSessionParameters.h"
#import "CMISAtomCollection.h"

@implementation CMISWorkspace

@synthesize sessionParameters = _sessionParameters;
@synthesize repositoryInfo = _repositoryInfo;

@synthesize collections = _collections;
@synthesize linkRelations = _linkRelations;

@synthesize objectByIdUriTemplate = _objectByIdUriTemplate;
@synthesize queryUriTemplate = _queryUriTemplate;
@synthesize typeByIdUriTemplate = _typeByIdUriTemplate;
@synthesize objectByPathUriTemplate = _objectByPathUriTemplate;

- (NSString *)collectionHrefForCollectionType:(NSString *)collectionType
{
    if (self.collections != nil)
    {
        for (CMISAtomCollection *collection in self.collections)
        {
            if ([collection.type isEqualToString:collectionType])
            {
                return collection.href;
            }
        }
    }
    return nil;
}

@end