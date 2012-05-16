//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISObjectByPathUriBuilder.h"

@interface CMISObjectByPathUriBuilder ()

@property (nonatomic, strong) NSString *templateUrl;

@end


@implementation CMISObjectByPathUriBuilder

@synthesize templateUrl = _templateUrl;
@synthesize path = _path;
@synthesize filter = _filter;
@synthesize includeAllowableActions = _includeAllowableActions;
@synthesize includePolicyIds = _includePolicyIds;
@synthesize includeRelationships = _includeRelationships;
@synthesize includeACL = _includeACL;
@synthesize renditionFilter = _renditionFilter;

- (id)initWithTemplateUrl:(NSString *)templateUrl
{
    self = [super init];
    if (self)
    {
        self.templateUrl = templateUrl;
    }
    return self;
}

- (NSURL *)buildUrl
{
    NSString *urlString = [self.templateUrl stringByReplacingOccurrencesOfString:@"{path}" withString:self.path];
    urlString = [urlString stringByReplacingOccurrencesOfString:@"{filter}" withString:(self.filter != nil ? self.filter : @"")];
    urlString = [urlString stringByReplacingOccurrencesOfString:@"{includeAllowableActions}" withString:(self.includeAllowableActions ? @"true" : @"false")];
    urlString = [urlString stringByReplacingOccurrencesOfString:@"{includePolicyIds}" withString:(self.includePolicyIds ? @"true" : @"false")];
    urlString = [urlString stringByReplacingOccurrencesOfString:@"{includeRelationships}" withString:(self.includeRelationships ? @"true" : @"false")];
    urlString = [urlString stringByReplacingOccurrencesOfString:@"{includeACL}" withString:(self.includeACL ? @"true" : @"false")];
    urlString = [urlString stringByReplacingOccurrencesOfString:@"{renditionFilter}" withString:(self.renditionFilter != nil ? self.renditionFilter : @"")];

    return [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
}


@end