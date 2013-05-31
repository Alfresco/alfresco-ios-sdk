/*
 ******************************************************************************
 * Copyright (C) 2005-2013 Alfresco Software Limited.
 *
 * This file is part of the Alfresco Mobile SDK.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *****************************************************************************
 */

#import "AlfrescoCloudDocumentFolderService.h"
#import "AlfrescoErrors.h"
#import "CMISOperationContext.h"
#import "CMISSession.h"
#import "AlfrescoCMISUtil.h"
#import "CMISDocument.h"
#import "CMISRendition.h"
#import "AlfrescoLog.h"
#import "AlfrescoFileManager.h"
#import "AlfrescoInternalConstants.h"

@interface AlfrescoCloudDocumentFolderService ()
@property (nonatomic, strong, readwrite) CMISSession *cmisSession;
@end

@implementation AlfrescoCloudDocumentFolderService

- (id)initWithSession:(id<AlfrescoSession>)session
{
    if (self = [super initWithSession:session])
    {
        self.cmisSession = [session objectForParameter:kAlfrescoSessionKeyCmisSession];
    }
    return self;
}

- (AlfrescoRequest *)retrieveRenditionOfNode:(AlfrescoNode *)node
                               renditionName:(NSString *)renditionName
                             completionBlock:(AlfrescoContentFileCompletionBlock)completionBlock
{
    
    [AlfrescoErrors assertArgumentNotNil:node argumentName:@"node"];
    [AlfrescoErrors assertArgumentNotNil:renditionName argumentName:@"renditionName"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    __block AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    CMISOperationContext *operationContext = [CMISOperationContext defaultOperationContext];
    operationContext.renditionFilterString = @"cmis:thumbnail";
    request.httpRequest = [self.cmisSession retrieveObject:node.identifier operationContext:operationContext completionBlock:^(CMISObject *cmisObject, NSError *error) {
        if (nil == cmisObject)
        {
            NSError *alfrescoError = [AlfrescoCMISUtil alfrescoErrorWithCMISError:error];
            completionBlock(nil, alfrescoError);
        }
        else if([cmisObject isKindOfClass:[CMISFolder class]])
        {
            NSError *wrongTypeError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolderNoThumbnail];
            completionBlock(nil, wrongTypeError);
        }
        else
        {
            NSError *renditionsError = nil;
            CMISDocument *document = (CMISDocument *)cmisObject;
            NSArray *renditions = document.renditions;
            if (nil == renditions)
            {
                renditionsError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolderNoThumbnail];
                completionBlock(nil, renditionsError);
            }
            else if(0 == renditions.count)
            {
                renditionsError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolderNoThumbnail];
                completionBlock(nil, renditionsError);
            }
            else
            {
                CMISRendition *thumbnailRendition = (CMISRendition *)[renditions objectAtIndex:0];
                AlfrescoLogDebug(@"************* NUMBER OF RENDITION OBJECTS FOUND IS %d and the document ID is %@",renditions.count, thumbnailRendition.renditionDocumentId);
                NSString *tmpFileName = [[[AlfrescoFileManager sharedManager] temporaryDirectory] stringByAppendingFormat:@"%@.png",node.name];
                AlfrescoLogDebug(@"************* DOWNLOADING TO FILE %@",tmpFileName);
                request.httpRequest = [thumbnailRendition downloadRenditionContentToFile:tmpFileName completionBlock:^(NSError *downloadError) {
                    if (downloadError)
                    {
                        NSError *alfrescoError = [AlfrescoCMISUtil alfrescoErrorWithCMISError:downloadError];
                        completionBlock(nil, alfrescoError);
                    }
                    else
                    {
                        AlfrescoContentFile *contentFile = [[AlfrescoContentFile alloc] initWithUrl:[NSURL fileURLWithPath:tmpFileName] mimeType:@"image/png"];
                        completionBlock(contentFile, nil);
                    }
                } progressBlock:^(unsigned long long bytesDownloaded, unsigned long long bytesTotal) {
                    AlfrescoLogDebug(@"************* PROGRESS DOWNLOADING FILE with %llu bytes downloaded from %llu total ",bytesDownloaded, bytesTotal);
                }];
            }
        }
    }];
    return request;
}

- (AlfrescoRequest *)retrieveRenditionOfNode:(AlfrescoNode *)node
                               renditionName:(NSString *)renditionName
                                outputStream:(NSOutputStream *)outputStream
                             completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:node argumentName:@"node"];
    [AlfrescoErrors assertArgumentNotNil:renditionName argumentName:@"renditionName"];
    [AlfrescoErrors assertArgumentNotNil:outputStream argumentName:@"outputStream"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    __block AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    CMISOperationContext *operationContext = [CMISOperationContext defaultOperationContext];
    operationContext.renditionFilterString = @"cmis:thumbnail";
    request.httpRequest = [self.cmisSession retrieveObject:node.identifier operationContext:operationContext completionBlock:^(CMISObject *cmisObject, NSError *error) {
        if (nil == cmisObject)
        {
            NSError *alfrescoError = [AlfrescoCMISUtil alfrescoErrorWithCMISError:error];
            completionBlock(NO, alfrescoError);
        }
        else if([cmisObject isKindOfClass:[CMISFolder class]])
        {
            NSError *wrongTypeError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolderNoThumbnail];
            completionBlock(NO, wrongTypeError);
        }
        else
        {
            NSError *renditionsError = nil;
            CMISDocument *document = (CMISDocument *)cmisObject;
            NSArray *renditions = document.renditions;
            if (nil == renditions)
            {
                renditionsError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolderNoThumbnail];
                completionBlock(NO, renditionsError);
            }
            else if (0 == renditions.count)
            {
                renditionsError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolderNoThumbnail];
                completionBlock(NO, renditionsError);
            }
            else
            {
                CMISRendition *thumbnailRendition = (CMISRendition *)[renditions objectAtIndex:0];
                AlfrescoLogDebug(@"************* NUMBER OF RENDITION OBJECTS FOUND IS %d and the document ID is %@", renditions.count, thumbnailRendition.renditionDocumentId);
                request.httpRequest = [thumbnailRendition downloadRenditionContentToOutputStream:outputStream completionBlock:^(NSError *downloadError) {
                    if (downloadError)
                    {
                        NSError *alfrescoError = [AlfrescoCMISUtil alfrescoErrorWithCMISError:downloadError];
                        completionBlock(NO, alfrescoError);
                    }
                    else
                    {
                        completionBlock(YES, nil);
                    }
                } progressBlock:^(unsigned long long bytesDownloaded, unsigned long long bytesTotal) {
                    AlfrescoLogDebug(@"************* PROGRESS DOWNLOADING FILE with %llu bytes downloaded from %llu total ",bytesDownloaded, bytesTotal);
                }];
            }
        }
    }];
    return request;
}

@end
