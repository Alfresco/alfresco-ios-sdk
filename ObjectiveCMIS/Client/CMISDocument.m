//
//  CMISDocument.m
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 29/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISDocument.h"
#import "CMISConstants.h"
#import "CMISHttpUtil.h"
#import "CMISObjectConverter.h"
#import "CMISStringInOutParameter.h"

@interface CMISDocument()

@property (nonatomic, strong, readwrite) NSString *contentStreamId;
@property (nonatomic, strong, readwrite) NSString *contentStreamFileName;
@property (nonatomic, strong, readwrite) NSString *contentStreamMediaType;
@property (readwrite) NSInteger contentStreamLength;

@property (nonatomic, strong, readwrite) NSString *versionLabel;
@property (readwrite) BOOL isLatestVersion;
@property (readwrite) BOOL isMajorVersion;
@property (readwrite) BOOL isLatestMajorVersion;
@property (nonatomic, strong, readwrite) NSString *versionSeriesId;

@end

@implementation CMISDocument

@synthesize contentStreamId = _contentStreamId;
@synthesize contentStreamFileName = _contentStreamFileName;
@synthesize contentStreamMediaType = _contentStreamMediaType;
@synthesize contentStreamLength = _contentStreamLength;
@synthesize versionLabel = _versionLabel;
@synthesize isLatestVersion = _isLatestVersion;
@synthesize isMajorVersion = _isMajorVersion;
@synthesize versionSeriesId = _versionSeriesId;
@synthesize isLatestMajorVersion = _isLatestMajorVersion;

- (id)initWithObjectData:(CMISObjectData *)objectData withSession:(CMISSession *)session
{
    self = [super initWithObjectData:objectData withSession:session];
    if (self)
    {
        self.contentStreamId = [[objectData.properties.propertiesDictionary objectForKey:kCMISProperyContentStreamId] firstValue];
        self.contentStreamMediaType = [[objectData.properties.propertiesDictionary objectForKey:kCMISPropertyContentStreamMediaType] firstValue];
        self.contentStreamLength = [[[objectData.properties.propertiesDictionary objectForKey:kCMISPropertyContentStreamLength] firstValue] integerValue];
        self.contentStreamFileName = [[objectData.properties.propertiesDictionary objectForKey:kCMISPropertyContentStreamFileName] firstValue];

        self.versionLabel = [[objectData.properties.propertiesDictionary objectForKey:kCMISPropertyVersionLabel] firstValue];
        self.versionSeriesId = [[objectData.properties.propertiesDictionary objectForKey:kCMISPropertyVersionSeriesId] firstValue];
        self.isLatestVersion = [[[objectData.properties.propertiesDictionary objectForKey:kCMISPropertyIsLatestVersion] firstValue] boolValue];
        self.isLatestMajorVersion = [[[objectData.properties.propertiesDictionary objectForKey:kCMISPropertyIsLatestMajorVersion] firstValue] boolValue];
        self.isMajorVersion = [[[objectData.properties.propertiesDictionary objectForKey:kCMISPropertyIsMajorVersion] firstValue] boolValue];
    }
    return self;
}

- (CMISCollection *)retrieveAllVersionsAndReturnError:(NSError **)error
{
    NSArray *entries = [self.binding.versioningService retrieveAllVersions:self.identifier error:error];

    if (*error == nil)
    {
        CMISObjectConverter *converter = [[CMISObjectConverter alloc] initWithSession:self.session];
        return [converter convertObjects:entries];
    }
    return nil;
}

- (void)changeContentToContentOfFile:(NSString *)filePath withOverwriteExisting:(BOOL)overwrite error:(NSError **)error
{
    [self.binding.objectService changeContentOfObject:[CMISStringInOutParameter inOutParameterUsingInParameter:self.identifier]
                                toContentOfFile:filePath
                                withOverwriteExisting:overwrite
                                withChangeToken:[CMISStringInOutParameter inOutParameterUsingInParameter:self.changeToken]
                                error:error];
}

- (void)deleteContentAndReturnError:(NSError **)error
{
    [self.binding.objectService deleteContentOfObject:[CMISStringInOutParameter inOutParameterUsingInParameter:self.identifier]
                                      withChangeToken:[CMISStringInOutParameter inOutParameterUsingInParameter:self.changeToken]
                                      error:error];
}

- (CMISDocument *)retrieveObjectOfLatestVersionAndReturnError:(NSError **)error
{
    CMISObjectData *objectData = [self.binding.versioningService retrieveObjectOfLatestVersion:self.identifier error:error];

    if (*error == nil)
    {
        CMISObjectConverter *converter = [[CMISObjectConverter alloc] initWithSession:self.session];
        return (CMISDocument *) [converter convertObject:objectData];
    }
    return nil;
}

- (void)downloadContentToFile:(NSString *)filePath completionBlock:(CMISContentRetrievalCompletionBlock)completionBlock
           failureBlock:(CMISContentRetrievalFailureBlock)failureBlock progressBlock:(CMISContentRetrievalProgressBlock)progressBlock
{
    [self.binding.objectService downloadContentOfObject:self.identifier toFile:filePath
                                 completionBlock:completionBlock failureBlock:failureBlock progressBlock:progressBlock];
}

- (BOOL)deleteAllVersionsAndReturnError:(NSError **)error
{
    return [self.binding.objectService deleteObject:self.identifier allVersions:YES error:error];
}

@end
