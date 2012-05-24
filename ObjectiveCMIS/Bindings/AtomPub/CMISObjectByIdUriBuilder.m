//
// ObjectiveCMIS
//
// Created by Joram Barrez
//


#import "CMISObjectByIdUriBuilder.h"

@interface CMISObjectByIdUriBuilder ()

@property (nonatomic, strong) NSString *templateUrl;

@end

@implementation CMISObjectByIdUriBuilder

@synthesize templateUrl = _templateUrl;
@synthesize objectId = _objectId;
@synthesize filter = _filter;
@synthesize includeAllowableActions = _includeAllowableActions;
@synthesize includePolicyIds = _includePolicyIds;
@synthesize includeRelationships = _includeRelationships;
@synthesize includeACL = _includeACL;
@synthesize renditionFilter = _renditionFilter;
@synthesize returnVersion = _returnVersion;

- (id)initWithTemplateUrl:(NSString *)templateUrl
{
    self = [super init];
    if (self)
    {
        self.templateUrl = templateUrl;

        // Defaults
        self.includeAllowableActions = YES;
        self.includeRelationships = CMISIncludeRelationshipNone;
        self.returnVersion = NOT_PROVIDED;
    }
    return self;
}

- (NSURL *)buildUrl
{
    NSString *urlString = [self.templateUrl stringByReplacingOccurrencesOfString:@"{id}" withString:self.objectId];
    urlString = [urlString stringByReplacingOccurrencesOfString:@"{filter}" withString:(self.filter != nil ? self.filter : @"")];
    urlString = [urlString stringByReplacingOccurrencesOfString:@"{includeAllowableActions}" withString:(self.includeAllowableActions ? @"true" : @"false")];
    urlString = [urlString stringByReplacingOccurrencesOfString:@"{includePolicyIds}" withString:(self.includePolicyIds ? @"true" : @"false")];

    NSString *includeRelationShipParam = nil;
    switch (self.includeRelationships)
    {
        case (CMISIncludeRelationshipNone):
            includeRelationShipParam = @"none";
            break;
        case (CMISIncludeRelationshipSource):
            includeRelationShipParam = @"source";
            break;
        case (CMISIncludeRelationshipTarget):
            includeRelationShipParam = @"target";
            break;
        case (CMISIncludeRelationshipBoth):
            includeRelationShipParam = @"both";
            break;
    }
    urlString = [urlString stringByReplacingOccurrencesOfString:@"{includeRelationships}" withString:includeRelationShipParam];


    urlString = [urlString stringByReplacingOccurrencesOfString:@"{includeACL}" withString:(self.includeACL ? @"true" : @"false")];
    urlString = [urlString stringByReplacingOccurrencesOfString:@"{renditionFilter}" withString:(self.renditionFilter != nil ? self.renditionFilter : @"")];

    if (self.returnVersion != NOT_PROVIDED)
    {
        NSString *returnVersionParam = nil;
        if (self.returnVersion == THIS)
        {
            returnVersionParam = @"this";
        }
        else if (self.returnVersion == LATEST)
        {
            returnVersionParam = @"latest";
        }
        else
        {
            returnVersionParam = @"latestmajor";
        }

        urlString = [NSString stringWithFormat:@"%@&returnVersion=%@", urlString, returnVersionParam];
    }

    return [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
}

@end