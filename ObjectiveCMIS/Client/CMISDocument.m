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

@property (nonatomic, strong, readwrite) NSString *versionLabel;
@property (readwrite) BOOL isLatestVersion;
@property (readwrite) BOOL isMajorVersion;
@property (readwrite) BOOL isLatestMajorVersion;
@property (nonatomic, strong, readwrite) NSString *versionSeriesId;

@end

@implementation CMISDocument

@synthesize versionLabel = _versionLabel;
@synthesize isLatestVersion = _isLatestVersion;
@synthesize isMajorVersion = _isMajorVersion;
@synthesize versionSeriesId = _versionSeriesId;
@synthesize isLatestMajorVersion = _isLatestMajorVersion;

- (id)initWithObjectData:(CMISObjectData *)objectData binding:(id <CMISBinding>)binding
{
    self = [super initWithObjectData:objectData binding:binding];
    if (self)
    {
        self.versionLabel = [[objectData.properties.properties objectForKey:kCMISPropertyVersionLabel] firstValue];
        self.versionSeriesId = [[objectData.properties.properties objectForKey:kCMISPropertyVersionSeriesId] firstValue];
        self.isLatestVersion = [[[objectData.properties.properties objectForKey:kCMISPropertyIsLatestVersion] firstValue] boolValue];
        self.isLatestMajorVersion = [[[objectData.properties.properties objectForKey:kCMISPropertyIsLatestMajorVersion] firstValue] boolValue];
        self.isMajorVersion = [[[objectData.properties.properties objectForKey:kCMISPropertyIsMajorVersion] firstValue] boolValue];
    }
    return self;
}


- (void)writeContentToFile:(NSString *)filePath completionBlock:(CMISContentRetrievalCompletionBlock)completionBlock failureBlock:(CMISContentRetrievalFailureBlock)failureBlock
{
    [self.binding.objectService writeContentOfCMISObject:self.identifier toFile:filePath completionBlock:completionBlock failureBlock:failureBlock];
}

- (BOOL)deleteAllVersionsAndReturnError:(NSError **)error
{
    return [self.binding.objectService deleteObject:self.identifier allVersions:YES error:error];
}

@end
