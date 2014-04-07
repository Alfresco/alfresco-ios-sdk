/*******************************************************************************
 * Copyright (C) 2005-2014 Alfresco Software Limited.
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

#import "AlfrescoLegacyAPIPersonService.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoAuthenticationProvider.h"
#import "AlfrescoBasicAuthenticationProvider.h"
#import "AlfrescoErrors.h"
#import "AlfrescoURLUtils.h"
#import "AlfrescoPagingUtils.h"

@interface AlfrescoLegacyAPIPersonService ()
@property (nonatomic, strong, readwrite) id<AlfrescoSession> session;
@property (nonatomic, strong, readwrite) NSString *baseApiUrl;
@property (nonatomic, strong, readwrite) AlfrescoCMISToAlfrescoObjectConverter *objectConverter;
@property (nonatomic, weak, readwrite) id<AlfrescoAuthenticationProvider> authenticationProvider;
@end

@implementation AlfrescoLegacyAPIPersonService

- (id)initWithSession:(id<AlfrescoSession>)session
{
    if (self = [super init])
    {
        self.session = session;
        self.baseApiUrl = [[self.session.baseUrl absoluteString] stringByAppendingString:kAlfrescoLegacyAPIPath];
        self.objectConverter = [[AlfrescoCMISToAlfrescoObjectConverter alloc] initWithSession:self.session];
        id authenticationObject = [session objectForParameter:kAlfrescoAuthenticationProviderObjectKey];
        self.authenticationProvider = nil;
        if ([authenticationObject isKindOfClass:[AlfrescoBasicAuthenticationProvider class]])
        {
            self.authenticationProvider = (AlfrescoBasicAuthenticationProvider *)authenticationObject;
        }
    }
    return self;
}
- (AlfrescoRequest *)retrievePersonWithIdentifier:(NSString *)identifier completionBlock:(AlfrescoPersonCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:identifier argumentName:@"identifier"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    NSString *requestString = [kAlfrescoLegacyPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:identifier];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    AlfrescoRequest *alfrescoRequest = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url
                                                session:self.session
                                        alfrescoRequest:alfrescoRequest
                                        completionBlock:^(NSData *responseData, NSError *error){
        if (nil == responseData)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            AlfrescoPerson *person = [self alfrescoPersonFromJSONData:responseData error:&conversionError];
            completionBlock(person, conversionError);
        }
    }];
    return alfrescoRequest;
}

- (AlfrescoRequest *)retrieveAvatarForPerson:(AlfrescoPerson *)person completionBlock:(AlfrescoContentFileCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:person argumentName:@"person"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    AlfrescoRepositoryInfo *repoInfo = self.session.repositoryInfo;
    NSNumber *majorVersion = repoInfo.majorVersion;
    if ([majorVersion intValue] < 4)
    {
        return [self retrieveAvatarForPersonV3x:person completionBlock:completionBlock];
    }
    return [self retrieveAvatarForPersonV4x:person completionBlock:completionBlock];
}

- (AlfrescoRequest *)retrieveAvatarForPersonV4x:(AlfrescoPerson *)person completionBlock:(AlfrescoContentFileCompletionBlock)completionBlock
{
    NSString *requestString = [kAlfrescoLegacyAvatarForPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:person.identifier];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:[self.session.baseUrl absoluteString] extensionURL:requestString];
    AlfrescoRequest *alfrescoRequest = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url
                                                session:self.session
                                        alfrescoRequest:alfrescoRequest
                                        completionBlock:^(NSData *responseData, NSError *error){
        if (nil == responseData)
        {
            completionBlock(nil, error);
        }
        else
        {
            AlfrescoContentFile *avatarFile = [[AlfrescoContentFile alloc] initWithData:responseData mimeType:@"application/octet-stream"];
            completionBlock(avatarFile, nil);
        }
    }];
    return alfrescoRequest;
}

- (AlfrescoRequest *)retrieveAvatarForPersonV3x:(AlfrescoPerson *)person completionBlock:(AlfrescoContentFileCompletionBlock)completionBlock
{
    NSString *avatarId = person.avatarIdentifier;
    if (nil == avatarId)
    {
        completionBlock(nil, [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodePersonNoAvatarFound]);
        return nil;
    }
    NSString *requestString = [NSString stringWithFormat:@"%@/service/%@",[self.session.baseUrl absoluteString],avatarId];
    NSURL *url = [NSURL URLWithString:requestString];
    AlfrescoRequest *alfrescoRequest = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url
                                                session:self.session
                                        alfrescoRequest:alfrescoRequest
                                        completionBlock:^(NSData *responseData, NSError *error){
        if (nil == responseData)
        {
            completionBlock(nil, error);
        }
        else
        {
            AlfrescoContentFile *avatarFile = [[AlfrescoContentFile alloc] initWithData:responseData mimeType:@"application/octet-stream"];
            completionBlock(avatarFile, nil);
        }
    }];
    return alfrescoRequest;
}

- (AlfrescoRequest *)searchWithKeywords:(NSString *)keywords completionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    return [self searchPeople:keywords completionBlock:completionBlock];
}

- (AlfrescoRequest *)searchWithKeywords:(NSString *)keywords
                         listingContext:(AlfrescoListingContext *)listingContext
                        completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:keywords argumentName:@"keywords"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    if (nil == listingContext)
    {
        listingContext = self.session.defaultListingContext;
    }
    
    AlfrescoRequest *request = [self searchPeople:keywords completionBlock:^(NSArray *array, NSError *error) {
        
        AlfrescoPagingResult *pagingResult = [AlfrescoPagingUtils pagedResultFromArray:array listingContext:listingContext];
        completionBlock(pagingResult, error);
    }];    
    return request;
}

#pragma mark - private methods

- (AlfrescoRequest *)searchPeople:(NSString *)keywords completionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    NSString *requestString = [kAlfrescoLegacyPersonSearchAPI stringByReplacingOccurrencesOfString:kAlfrescoSearchFilter withString:keywords];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    AlfrescoRequest *alfrescoRequest = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url
                                                session:self.session
                                        alfrescoRequest:alfrescoRequest
                                        completionBlock:^(NSData *responseData, NSError *error) {
                                            if (nil == responseData)
                                            {
                                                completionBlock(nil, error);
                                            }
                                            else
                                            {
                                                NSError *conversionError = nil;
                                                NSArray *people = [self peopleArrayFromJSONData:responseData error:&conversionError];
                                                completionBlock(people, conversionError);
                                            }
                                        }];
    return alfrescoRequest;
}

- (AlfrescoPerson *)alfrescoPersonFromJSONData:(NSData *)data error:(NSError *__autoreleasing *)outError
{
    NSMutableDictionary *jsonPersonDictionary = [self extractJsonDictionaryFromData:data error:outError];
    AlfrescoCompany *company = [[AlfrescoCompany alloc] initWithProperties:jsonPersonDictionary];
    [jsonPersonDictionary setValue:company forKey:kAlfrescoJSONCompany];
    
    return [[AlfrescoPerson alloc] initWithProperties:jsonPersonDictionary];
}

- (NSArray *)peopleArrayFromJSONData:(NSData *)data error:(NSError *__autoreleasing *)outError
{
    NSMutableDictionary *jsonPeopleDictionary = [self extractJsonDictionaryFromData:data error:outError];
    
    NSArray *peopleProperties = jsonPeopleDictionary[kAlfrescoJSONPeople];
    NSMutableArray *people = [[NSMutableArray alloc] init];
    
    for (NSDictionary *personProperties in peopleProperties)
    {
        AlfrescoCompany *company = [[AlfrescoCompany alloc] initWithProperties:personProperties];
        [personProperties setValue:company forKey:kAlfrescoJSONCompany];
        AlfrescoPerson *person = [[AlfrescoPerson alloc] initWithProperties:personProperties];
        [people addObject:person];
    }
    return people;
}

- (id)extractJsonDictionaryFromData:(NSData *)data error:(NSError *__autoreleasing *)outError
{
    if (nil == data)
    {
        if (nil == *outError)
        {
            *outError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
        }
        else
        {
            NSError *error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
            *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
        }
        return nil;
    }
    
    NSError *error = nil;
    id jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if(nil == jsonDictionary)
    {
        *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodePerson];
        return nil;
    }
    if ([[jsonDictionary valueForKeyPath:kAlfrescoJSONStatusCode] isEqualToNumber:@404])
    {
        // no person found
        if (nil == *outError)
        {
            *outError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodePersonNotFound];
        }
        else
        {
            NSError *underlyingError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodePersonNotFound];
            *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:underlyingError andAlfrescoErrorCode:kAlfrescoErrorCodePersonNotFound];
        }
        return nil;
    }
    if (![jsonDictionary isKindOfClass:[NSDictionary class]])
    {
        if (nil == *outError)
        {
            *outError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
        }
        else
        {
            NSError *underlyingError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
            *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:underlyingError andAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
        }
        return nil;
    }
    return jsonDictionary;
}

- (NSData *)jsonDataForUpdatingProfile:(NSDictionary *)properties
{
    return [NSJSONSerialization dataWithJSONObject:properties options:NSJSONWritingPrettyPrinted error:nil];
}

- (NSDictionary *)propertiesWithOnPremiseKeys:(NSDictionary *)properties
{
    NSDictionary *mappedOnPremiseKeys = @{kAlfrescoPersonPropertyFirstName: kAlfrescoJSONFirstName,
                                          kAlfrescoPersonPropertyLastName: kAlfrescoJSONLastName,
                                          kAlfrescoPersonPropertyJobTitle: kAlfrescoJSONJobTitle,
                                          kAlfrescoPersonPropertyLocation: kAlfrescoJSONLocation,
                                          kAlfrescoPersonPropertyDescription: kAlfrescoJSONPersonDescription,
                                          kAlfrescoPersonPropertyTelephoneNumber: kAlfrescoJSONTelephoneNumber,
                                          kAlfrescoPersonPropertyMobileNumber: kAlfrescoJSONMobileNumber,
                                          kAlfrescoPersonPropertyEmail: kAlfrescoJSONEmail,
                                          kAlfrescoPersonPropertySkypeId: kAlfrescoJSONSkype,
                                          kAlfrescoPersonPropertyInstantMessageId: kAlfrescoJSONInstantMessage,
                                          kAlfrescoPersonPropertyGoogleId: kAlfrescoJSONGoogle,
                                          kAlfrescoPersonPropertyStatus: kAlfrescoJSONStatus,
                                          kAlfrescoPersonPropertyStatusTime: kAlfrescoJSONStatusTime,
                                          kAlfrescoPersonPropertyCompanyName: kAlfrescoJSONCompanyName,
                                          kAlfrescoPersonPropertyCompanyAddressLine1: kAlfrescoJSONCompanyAddressLine1,
                                          kAlfrescoPersonPropertyCompanyAddressLine2: kAlfrescoJSONCompanyAddressLine2,
                                          kAlfrescoPersonPropertyCompanyAddressLine3: kAlfrescoJSONCompanyAddressLine3,
                                          kAlfrescoPersonPropertyCompanyPostcode: kAlfrescoJSONCompanyPostcode,
                                          kAlfrescoPersonPropertyCompanyTelephoneNumber: kAlfrescoJSONCompanyTelephone,
                                          kAlfrescoPersonPropertyCompanyFaxNumber: kAlfrescoJSONCompanyFaxNumber,
                                          kAlfrescoPersonPropertyCompanyEmail: kAlfrescoJSONCompanyEmail};
    
    NSArray *propertyKeys = [properties allKeys];
    NSMutableDictionary *updatedProperties = [[NSMutableDictionary alloc] init];
    
    
    for (NSString *key in propertyKeys)
    {
        NSString *mappedKey = mappedOnPremiseKeys[key];
        if (mappedKey)
        {
            [updatedProperties setValue:properties[key] forKey:mappedKey];
        }
    }
    return updatedProperties;
}

@end
