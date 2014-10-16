/*******************************************************************************
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
 ******************************************************************************/

#import "AlfrescoCloudPersonService.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoPropertyConstants.h"
#import "AlfrescoLog.h"
#import "AlfrescoErrors.h"
#import "CMISQueryAtomEntryWriter.h"
#import "CMISAtomFeedParser.h"

NSString * const kAlfrescoSearchNotImplemented = @"searchWithKeywords is not implemented as Alfresco in the Cloud does not have this capability";

@interface AlfrescoCloudPersonService ()
@property (nonatomic, strong, readwrite) id<AlfrescoSession> session;
@property (nonatomic, strong, readwrite) NSString *baseApiUrl;
@end

@implementation AlfrescoCloudPersonService

- (id)initWithSession:(id<AlfrescoSession>)session
{
    if (self = [super initWithSession:session])
    {
        self.session = session;
        self.baseApiUrl = [[self.session.baseUrl absoluteString] stringByAppendingString:kAlfrescoCloudAPIPath];
    }
    return self;
}

- (AlfrescoRequest *)searchWithKeywords:(NSString *)keywords completionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [AlfrescoErrors assertStringArgumentNotNilOrEmpty:keywords argumentName:@"keywords"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    AlfrescoListingContext *listingContext = [[AlfrescoListingContext alloc] initWithMaxItems:-1];
    return [self searchWithKeywords:keywords listingContext:listingContext
                    completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
        completionBlock(pagingResult.objects, error);
    }];
}

- (AlfrescoRequest *)searchWithKeywords:(NSString *)keywords
                         listingContext:(AlfrescoListingContext *)listingContext
                        completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [AlfrescoErrors assertStringArgumentNotNilOrEmpty:keywords argumentName:@"keywords"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    if (nil == listingContext)
    {
        listingContext = self.session.defaultListingContext;
    }
 
    // NOTE: This is a temporary solution, once the SDK fully supports the 1.1 bindings
    //       we can swap this implementation to use the SearchService, currently this will
    //       use the 1.0 binding URLs which don't support cmis:item queries required to
    //       search for people.
    
    // construct the URL
    NSURL *queryURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [self.session.baseUrl absoluteString], kAlfrescoCloudCMIS11AtomPath, kAlfrescoCloudAPIQuery]];
    
    // Build XML for query
    CMISQueryAtomEntryWriter *atomEntryWriter = [[CMISQueryAtomEntryWriter alloc] init];
    atomEntryWriter.statement = [self constructQueryForKeywords:keywords];
    atomEntryWriter.searchAllVersions = NO;
    atomEntryWriter.includeAllowableActions = NO;
    atomEntryWriter.relationships = CMISIncludeRelationshipNone;
    atomEntryWriter.renditionFilter = @"";
    if (listingContext.maxItems != -1)
    {
        atomEntryWriter.maxItems = [NSNumber numberWithInt:listingContext.maxItems];
    }
    if (listingContext.skipCount != -1)
    {
        atomEntryWriter.skipCount = [NSNumber numberWithInt:listingContext.skipCount];
    }
    
    // Execute HTTP call
    AlfrescoRequest *alfrescoRequest = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:queryURL session:self.session requestBody:[[atomEntryWriter generateAtomEntryXML] dataUsingEncoding:NSUTF8StringEncoding] method:kAlfrescoHTTPPost alfrescoRequest:alfrescoRequest completionBlock:^(NSData *data, NSError *error) {
        if (data)
        {
            // parse response
            CMISAtomFeedParser *feedParser = [[CMISAtomFeedParser alloc] initWithData:data];
            NSError *error = nil;
            if ([feedParser parseAndReturnError:&error])
            {
                // convert from CMIS objects to AlfrescoPerson objects
                NSArray *people = [self peopleArrayFromCMISObjectDataArray:feedParser.entries];
                
                // create paging result object
                NSString *nextLink = [feedParser.linkRelations linkHrefForRel:kCMISLinkRelationNext];
                AlfrescoPagingResult *result = [[AlfrescoPagingResult alloc] initWithArray:people
                                                                              hasMoreItems:(nextLink != nil)
                                                                                totalItems:feedParser.numItems];
                completionBlock(result, nil);
            }
            else
            {
                completionBlock(nil, error);
            }
        }
        else
        {
            completionBlock(nil, error);
        }
    }];
    
    return alfrescoRequest;
}

#pragma Private methods

- (NSString *)constructQueryForKeywords:(NSString *)keywords
{
    // process keywords into an array after replacing quotes and escaping apostrophes (MOBSDK-754)
    keywords = [keywords stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    keywords = [keywords stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
    NSArray *keywordArray = [keywords componentsSeparatedByString:@" "];
    
    NSMutableString *personQuery = [NSMutableString stringWithString:@"SELECT * FROM cm:person WHERE "];
    BOOL firstKeyword = YES;
    for (NSString *keyword in keywordArray)
    {
        if (!firstKeyword)
        {
            [personQuery appendString:@" OR "];
        }
        else
        {
            firstKeyword = NO;
        }
        
        [personQuery appendFormat:@"cm:firstName LIKE '%@%%' OR cm:lastName LIKE '%@%%' OR cm:userName LIKE '%@%%'", keyword, keyword, keyword];
    }
    
    AlfrescoLogDebug(@"Query: %@", personQuery);
    
    return personQuery;
}

- (NSArray *)peopleArrayFromCMISObjectDataArray:(NSArray *)cmisObjectDataArray
{
    NSMutableArray *people = [NSMutableArray array];
    
    for (CMISObjectData *objectData in cmisObjectDataArray)
    {
        [people addObject:[self personFromCMISObjectData:objectData]];
    }
    
    return people;
}

- (AlfrescoPerson *)personFromCMISObjectData:(CMISObjectData *)objectData
{
    NSMutableDictionary *personProperties = [NSMutableDictionary dictionary];
    
    // extract all the property objects
    CMISProperties *cmisProperties = objectData.properties;
    CMISPropertyData *identifierProperty = [cmisProperties propertyForId:kAlfrescoModelPropertyUserName];
    CMISPropertyData *firstNameProperty = [cmisProperties propertyForId:kAlfrescoModelPropertyFirstName];
    CMISPropertyData *lastNameProperty = [cmisProperties propertyForId:kAlfrescoModelPropertyLastName];
    CMISPropertyData *jobTitleProperty = [cmisProperties propertyForId:kAlfrescoModelPropertyJobTitle];
    CMISPropertyData *locationProperty = [cmisProperties propertyForId:kAlfrescoModelPropertyLocation];
    CMISPropertyData *descriptionProperty = [cmisProperties propertyForId:kAlfrescoModelPropertyPersonDescription];
    CMISPropertyData *telProperty = [cmisProperties propertyForId:kAlfrescoModelPropertyTelephone];
    CMISPropertyData *mobileProperty = [cmisProperties propertyForId:kAlfrescoModelPropertyMobile];
    CMISPropertyData *emailProperty = [cmisProperties propertyForId:kAlfrescoModelPropertyEmail];
    CMISPropertyData *skypeProperty = [cmisProperties propertyForId:kAlfrescoModelPropertySkype];
    CMISPropertyData *instantMsgProperty = [cmisProperties propertyForId:kAlfrescoModelPropertyInstantMsg];
    CMISPropertyData *googleProperty = [cmisProperties propertyForId:kAlfrescoModelPropertyGoogleUserName];
    CMISPropertyData *statusProperty = [cmisProperties propertyForId:kAlfrescoModelPropertyUserStatus];
    CMISPropertyData *statusTimeProperty = [cmisProperties propertyForId:kAlfrescoModelPropertyUserStatusTime];
    
    // add values to dictionary, if present
    if (identifierProperty.values.firstObject)
    {
        personProperties[kAlfrescoPersonIdentifier] = identifierProperty.values.firstObject;
    }
    if (firstNameProperty.values.firstObject)
    {
        personProperties[kAlfrescoPersonFirstName] = firstNameProperty.values.firstObject;
    }
    if (lastNameProperty.values.firstObject)
    {
        personProperties[kAlfrescoPersonLastName] = lastNameProperty.values.firstObject;
    }
    if (jobTitleProperty.values.firstObject)
    {
        personProperties[kAlfrescoPersonJobTitle] = jobTitleProperty.values.firstObject;
    }
    if (locationProperty.values.firstObject)
    {
        personProperties[kAlfrescoPersonLocation] = locationProperty.values.firstObject;
    }
    if (descriptionProperty.values.firstObject)
    {
        personProperties[kAlfrescoPersonSummary] = descriptionProperty.values.firstObject;
    }
    if (telProperty.values.firstObject)
    {
        personProperties[kAlfrescoPersonTelephoneNumber] = telProperty.values.firstObject;
    }
    if (mobileProperty.values.firstObject)
    {
        personProperties[kAlfrescoPersonMobileNumber] = mobileProperty.values.firstObject;
    }
    if (emailProperty.values.firstObject)
    {
        personProperties[kAlfrescoPersonEmail] = emailProperty.values.firstObject;
    }
    if (skypeProperty.values.firstObject)
    {
        personProperties[kAlfrescoPersonSkypeId] = skypeProperty.values.firstObject;
    }
    if (instantMsgProperty.values.firstObject)
    {
        personProperties[kAlfrescoPersonInstantMessageId] = instantMsgProperty.values.firstObject;
    }
    if (googleProperty.values.firstObject)
    {
        personProperties[kAlfrescoPersonGoogleId] = googleProperty.values.firstObject;
    }
    if (statusProperty.values.firstObject)
    {
        personProperties[kAlfrescoPersonStatus] = statusProperty.values.firstObject;
    }
    if (statusTimeProperty.values.firstObject)
    {
        personProperties[kAlfrescoPersonStatusTime] = statusTimeProperty.values.firstObject;
    }
    
    personProperties[kAlfrescoPersonCompany] = [self companyFromCMISObjectData:objectData];
    
    return [[AlfrescoPerson alloc] initWithDictionary:personProperties];
}

- (AlfrescoCompany *)companyFromCMISObjectData:(CMISObjectData *)objectData
{
    NSMutableDictionary *companyProperties = [NSMutableDictionary dictionary];
    
    // extract all the property objects
    CMISProperties *cmisProperties = objectData.properties;
    CMISPropertyData *nameProperty = [cmisProperties propertyForId:kAlfrescoModelPropertyOrganization];
    CMISPropertyData *address1Property = [cmisProperties propertyForId:kAlfrescoModelPropertyCompanyAddress1];
    CMISPropertyData *address2Property = [cmisProperties propertyForId:kAlfrescoModelPropertyCompanyAddress2];
    CMISPropertyData *address3Property = [cmisProperties propertyForId:kAlfrescoModelPropertyCompanyAddress3];
    CMISPropertyData *postCodeProperty = [cmisProperties propertyForId:kAlfrescoModelPropertyCompanyPostCode];
    CMISPropertyData *telProperty = [cmisProperties propertyForId:kAlfrescoModelPropertyCompanyTelephone];
    CMISPropertyData *faxProperty = [cmisProperties propertyForId:kAlfrescoModelPropertyCompanyFax];
    CMISPropertyData *emailProperty = [cmisProperties propertyForId:kAlfrescoModelPropertyCompanyEmail];
    
    // add values to dictionary, if present
    if (nameProperty.values.firstObject)
    {
        companyProperties[kAlfrescoCompanyName] = nameProperty.values.firstObject;
    }
    if (address1Property.values.firstObject)
    {
        companyProperties[kAlfrescoCompanyAddressLine1] = address1Property.values.firstObject;
    }
    if (address2Property.values.firstObject)
    {
        companyProperties[kAlfrescoCompanyAddressLine2] = address2Property.values.firstObject;
    }
    if (address3Property.values.firstObject)
    {
        companyProperties[kAlfrescoCompanyAddressLine3] = address3Property.values.firstObject;
    }
    if (postCodeProperty.values.firstObject)
    {
        companyProperties[kAlfrescoCompanyPostCode] = postCodeProperty.values.firstObject;
    }
    if (telProperty.values.firstObject)
    {
        companyProperties[kAlfrescoCompanyTelephoneNumber] = telProperty.values.firstObject;
    }
    if (faxProperty.values.firstObject)
    {
        companyProperties[kAlfrescoCompanyFaxNumber] = faxProperty.values.firstObject;
    }
    if (emailProperty.values.firstObject)
    {
        companyProperties[kAlfrescoCompanyEmail] = emailProperty.values.firstObject;
    }
    
    return [[AlfrescoCompany alloc] initWithDictionary:companyProperties];
}

@end
