/*******************************************************************************
 * Copyright (C) 2005-2012 Alfresco Software Limited.
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
 ******************************************************************************/

#import "AlfrescoCloudPersonService.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoAuthenticationProvider.h"
#import "AlfrescoBasicAuthenticationProvider.h"
#import "AlfrescoErrors.h"
#import "AlfrescoHTTPUtils.h"
#import "AlfrescoPagingUtils.h"
#import "AlfrescoDocumentFolderService.h"

@interface AlfrescoCloudPersonService ()
@property (nonatomic, strong, readwrite) id<AlfrescoSession> session;
@property (nonatomic, strong, readwrite) NSString *baseApiUrl;
@property (nonatomic, strong, readwrite) NSOperationQueue *operationQueue;
@property (nonatomic, strong, readwrite) AlfrescoObjectConverter *objectConverter;
@property (nonatomic, weak, readwrite) id<AlfrescoAuthenticationProvider> authenticationProvider;
- (AlfrescoPerson *)parsePersonArrayWithData:(NSData *)data error:(NSError **)outError;
- (AlfrescoPerson *)personFromJSON:(NSDictionary *)personDict;
@end


@implementation AlfrescoCloudPersonService
@synthesize baseApiUrl = _baseApiUrl;
@synthesize session = _session;
@synthesize operationQueue = _operationQueue;
@synthesize objectConverter = _objectConverter;
@synthesize authenticationProvider = _authenticationProvider;

- (id)initWithSession:(id<AlfrescoSession>)session
{
    if (self = [super init])
    {
        self.session = session;
        self.baseApiUrl = [[self.session.baseUrl absoluteString] stringByAppendingString:kAlfrescoCloudAPIPath];
        self.objectConverter = [[AlfrescoObjectConverter alloc] initWithSession:self.session];
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.maxConcurrentOperationCount = 2;
        id authenticationObject = objc_getAssociatedObject(self.session, &kAlfrescoAuthenticationProviderObjectKey);
        self.authenticationProvider = nil;
        if ([authenticationObject isKindOfClass:[AlfrescoBasicAuthenticationProvider class]])
        {
            self.authenticationProvider = (AlfrescoBasicAuthenticationProvider *)authenticationObject;
        }
    }
    return self;
}
- (void)retrievePersonWithIdentifier:(NSString *)identifier completionBlock:(AlfrescoPersonCompletionBlock)completionBlock
{
    NSAssert(nil != identifier, @"identifier must not be nil");
    NSAssert(nil != completionBlock, @"completionBlock must not be nil");
    
    __weak AlfrescoCloudPersonService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        NSError *operationQueueError = nil;
        NSString *requestString = [kAlfrescoOnPremisePersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:identifier];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",
                                           weakSelf.baseApiUrl, requestString]];
        
        NSData *data = [AlfrescoHTTPUtils executeRequestWithURL:url
                                         authenticationProvider:weakSelf.authenticationProvider
                                                           data:nil
                                                     httpMethod:@"GET"
                                                          error:&operationQueueError];
        
        AlfrescoPerson *person = nil;
        if (nil != data)
        {
            person = [weakSelf parsePersonArrayWithData:data error:&operationQueueError];
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(person, operationQueueError);
        }];
        
    }];
}

- (void)retrieveAvatarForPerson:(AlfrescoPerson *)person completionBlock:(AlfrescoContentFileCompletionBlock)completionBlock
{
    NSAssert(nil != person, @"person must not be nil");
    NSAssert(nil != completionBlock, @"completionBlock must not be nil");
    
    __weak AlfrescoCloudPersonService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        if (nil == person.avatarIdentifier)
        {
            NSError * error = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodePerson withDetailedDescription:@"no avatar specified"];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completionBlock(nil, error);
            }];
        }
        else
        {
            __block AlfrescoDocumentFolderService *docService = [[AlfrescoDocumentFolderService alloc] initWithSession:weakSelf.session];
            [docService retrieveNodeWithIdentifier:person.avatarIdentifier completionBlock:^(AlfrescoNode *avatarFile, NSError *retrieveError){
                if (nil == avatarFile)
                {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        completionBlock(nil, retrieveError);
                    }];
                }
                else
                {
                    [docService retrieveContentOfDocument:(AlfrescoDocument *)avatarFile completionBlock:^(AlfrescoContentFile *downloadedAvatar, NSError * downloadError){
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            completionBlock(downloadedAvatar, downloadError);
                        }];
                    }progressBlock:^(NSInteger bytesDownloaded, NSInteger bytesTotal){}];
                }
            }];                    
        }
        
    }];
}

#pragma mark - private methods
- (AlfrescoPerson *) parsePersonArrayWithData:(NSData *)data error:(NSError *__autoreleasing *)outError
{
    NSLog(@"parsePersonArrayWithData with JSON data %@",[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
    NSDictionary *entryDict = [AlfrescoObjectConverter parseCloudJSONEntryFromListData:data error:outError];
    if (nil == entryDict)
    {
        *outError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodePerson withDetailedDescription:@"person JSON data return with NIL"];
        return nil;
    }
    
    return (AlfrescoPerson *)[self personFromJSON:entryDict];
    
}

- (AlfrescoPerson *)personFromJSON:(NSDictionary *)personDict
{
    AlfrescoPerson *alfPerson = [[AlfrescoPerson alloc] init];
    alfPerson.identifier = [personDict valueForKey:kAlfrescoJSONIdentifier];
    alfPerson.firstName = [personDict valueForKey:kAlfrescoJSONFirstName];
    alfPerson.lastName = [personDict valueForKey:kAlfrescoJSONLastName];
    if (alfPerson.lastName != nil && alfPerson.lastName.length > 0)
    {
        if (alfPerson.firstName != nil && alfPerson.firstName.length > 0)
        {
            alfPerson.fullName = [NSString stringWithFormat:@"%@ %@", alfPerson.firstName, alfPerson.lastName];
        }
        else
        {
            alfPerson.fullName = alfPerson.lastName;
        }
    }
    else if (alfPerson.firstName != nil && alfPerson.firstName.length > 0)
    {
        alfPerson.fullName = alfPerson.firstName;
    }
    else
    {
        alfPerson.fullName = alfPerson.identifier;
    }
    alfPerson.avatarIdentifier = [personDict valueForKey:kAlfrescoJSONAvatarId];
    return alfPerson;
}


@end
