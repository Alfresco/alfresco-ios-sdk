//
//  CMISDocument.m
//  HybridApp
//
//  Created by Cornwell Gavin on 29/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISDocument.h"
#import "CMISConstants.h"
#import "HttpUtil.h"

@interface CMISDocument()

@property (nonatomic, strong, readwrite) NSString *contentStreamId;
@property (nonatomic, strong, readwrite) NSURL *contentURL;

@end

@implementation CMISDocument

@synthesize contentStreamId = _contentStreamId;
@synthesize contentURL = _contentURL;

- (id)initWithObjectData:(CMISObjectData *)objectData binding:(id <CMISBinding>)binding
{
    self = [super initWithObjectData:objectData binding:binding];
    if (self)
    {
        self.contentStreamId = [[objectData.properties.properties objectForKey:kCMISProperyContentStreamId] firstValue];
        self.contentURL = objectData.contentUrl;
    }
    return self;
}


- (void)writeContentToFile:(NSString *)filePath withError:(NSError * *)error
{
    [self.binding.objectService writeContentOfCMISObject:self.identifier toFile:filePath withError:error];
}


@end
