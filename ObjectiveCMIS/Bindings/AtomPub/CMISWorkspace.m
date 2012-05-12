//
// ObjectiveCMIS
//
// Created by Joram Barrez
//


#import "CMISWorkspace.h"
#import "CMISRepositoryInfo.h"
#import "CMISSessionParameters.h"

@implementation CMISWorkspace

@synthesize sessionParameters = _sessionParameters;
@synthesize repositoryInfo = _repositoryInfo;

@synthesize objectByIdUriTemplate = _objectByIdUriTemplate;
@synthesize queryUriTemplate = _queryUriTemplate;
@synthesize typeByIdUriTemplate = _typeByIdUriTemplate;
@synthesize objectByPathUriTemplate = _objectByPathUriTemplate;

@end