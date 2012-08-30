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

#import "AlfrescoObjectConverter.h"
#import "CMISDocument.h"
#import "CMISSession.h"
#import "CMISQueryResult.h"
#import "CMISObjectConverter.h"
#import "CMISEnums.h"
#import "CMISConstants.h"
#import "CMISQueryResult.h"
#import "AlfrescoActivityEntry.h"
#import "AlfrescoComment.h"
#import "AlfrescoProperty.h"
#import "AlfrescoPermissions.h"
#import "AlfrescoISO8601DateFormatter.h"
#import "AlfrescoErrors.h"
#import <objc/runtime.h>
#import "AlfrescoInternalConstants.h"
#import "AlfrescoRepositoryCapabilities.h"
#import "AlfrescoRepositorySession.h"
#import "AlfrescoCloudSession.h"

@interface AlfrescoObjectConverter ()
@property (nonatomic, assign) BOOL isCloud;
@property (nonatomic, strong)id<AlfrescoSession>session;
@property (nonatomic, strong)AlfrescoISO8601DateFormatter *dateFormatter;

+ (AlfrescoPropertyType)typeForCMISProperty:(NSString *)propertyIdentifier;
@end

@implementation AlfrescoObjectConverter

@synthesize session = _session;
@synthesize dateFormatter = _dateFormatter;
@synthesize isCloud = _isCloud;

- (id)initWithSession:(id<AlfrescoSession>)session
{
    if (self = [super init])
    {
        self.session = session;
        self.dateFormatter = [[AlfrescoISO8601DateFormatter alloc] init];
        if ([self.session isKindOfClass:[AlfrescoCloudSession class]])
        {
            self.isCloud = YES;
        }
        else
        {
            self.isCloud = NO;
        }
    }
    
    return self;
}

- (AlfrescoRepositoryInfo *)repositoryInfoFromCMISSession:(CMISSession *)cmisSession
{
    NSMutableDictionary *repoDictionary = [NSMutableDictionary dictionary];
    NSString *productName = cmisSession.repositoryInfo.productName;
    NSString *identifier = cmisSession.repositoryInfo.identifier;
    NSString *summary = cmisSession.repositoryInfo.desc;
    NSString *version = cmisSession.repositoryInfo.productVersion;
    NSArray *versionArray = [version componentsSeparatedByString:@"."];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *majorVersionNumber = [formatter numberFromString:[versionArray objectAtIndex:0]];
    NSNumber *minorVersionNumber = [formatter numberFromString:[versionArray objectAtIndex:1]];
    NSArray *buildArray = [[versionArray objectAtIndex:2] componentsSeparatedByString:@"("];
    NSNumber *maintenanceVersion = [formatter numberFromString:[[buildArray objectAtIndex:0] stringByReplacingOccurrencesOfString:@" " withString:@""]];
    NSString *buildNumber =  [[buildArray objectAtIndex:1] stringByReplacingOccurrencesOfString:@")" withString:@""];   
    

    [repoDictionary setObject:productName forKey:kAlfrescoRepositoryName];
    if ([productName rangeOfString:kAlfrescoRepositoryCommunity].location != NSNotFound)
    {
        [repoDictionary setObject:kAlfrescoRepositoryCommunity forKey:kAlfrescoRepositoryEdition];
    }
    else 
    {
        [repoDictionary setObject:kAlfrescoRepositoryEnterprise forKey:kAlfrescoRepositoryEdition];
    }
    [repoDictionary setObject:identifier forKey:kAlfrescoRepositoryIdentifier];
    [repoDictionary setObject:summary forKey:kAlfrescoRepositorySummary];
    [repoDictionary setObject:version forKey:kAlfrescoRepositoryVersion];
    [repoDictionary setObject:majorVersionNumber forKey:kAlfrescoRepositoryMajorVersion];    
    [repoDictionary setObject:minorVersionNumber forKey:kAlfrescoRepositoryMinorVersion];
    [repoDictionary setObject:maintenanceVersion forKey:kAlfrescoRepositoryMaintenanceVersion];
    [repoDictionary setObject:buildNumber forKey:kAlfrescoRepositoryBuildNumber];
    
    NSMutableDictionary *capabilities = [NSMutableDictionary dictionary];
    if (self.isCloud)
    {
        [capabilities setValue:[NSNumber numberWithBool:YES] forKey:kAlfrescoCapabilityLike];
        [capabilities setValue:[NSNumber numberWithBool:YES] forKey:kAlfrescoCapabilityCommentsCount];
    }
    else
    {
        if ([majorVersionNumber intValue] < 4)
        {
            [capabilities setValue:[NSNumber numberWithBool:NO] forKey:kAlfrescoCapabilityLike];
            [capabilities setValue:[NSNumber numberWithBool:NO] forKey:kAlfrescoCapabilityCommentsCount];
        }
        else
        {
            [capabilities setValue:[NSNumber numberWithBool:YES] forKey:kAlfrescoCapabilityLike];
            [capabilities setValue:[NSNumber numberWithBool:YES] forKey:kAlfrescoCapabilityCommentsCount];
        }
    }

    AlfrescoRepositoryCapabilities *repoCapabilities = [[AlfrescoRepositoryCapabilities alloc] initWithCapabilities:capabilities];
    [repoDictionary setValue:repoCapabilities forKey:kAlfrescoRepositoryCapabilities];
    AlfrescoRepositoryInfo *alfrescoRepositoryInfo = [[AlfrescoRepositoryInfo alloc] initWithParameters:repoDictionary];
    return alfrescoRepositoryInfo;
}

- (AlfrescoFolder *)folderFromCMISFolder:(CMISFolder *)cmisFolder
{
    AlfrescoFolder *alfFolder = [[AlfrescoFolder alloc] init];
    alfFolder.identifier = cmisFolder.identifier;
    alfFolder.name = cmisFolder.name;
    alfFolder.type = cmisFolder.objectType;
    alfFolder.createdBy = cmisFolder.createdBy;
    alfFolder.createdAt = cmisFolder.creationDate;
    alfFolder.modifiedBy = cmisFolder.lastModifiedBy;
    alfFolder.modifiedAt = cmisFolder.lastModificationDate;
    alfFolder.isFolder = YES;
    alfFolder.isDocument = NO;
    
    return alfFolder;
}

- (AlfrescoDocument *)documentFromCMISDocument:(CMISDocument *)cmisDocument
{
    AlfrescoDocument *alfDocument = [[AlfrescoDocument alloc] init];
    
    alfDocument.identifier = cmisDocument.identifier;
    alfDocument.name = cmisDocument.name;
    alfDocument.type = cmisDocument.objectType;
    alfDocument.createdBy = cmisDocument.createdBy;
    alfDocument.createdAt = cmisDocument.creationDate;
    alfDocument.modifiedBy = cmisDocument.lastModifiedBy;
    alfDocument.modifiedAt = cmisDocument.lastModificationDate;
    alfDocument.isDocument = YES;
    alfDocument.isFolder = NO;
    alfDocument.isLatestVersion = cmisDocument.isLatestVersion;
    alfDocument.versionLabel = cmisDocument.versionLabel;
    alfDocument.contentLength = cmisDocument.contentStreamLength;
    alfDocument.contentMimeType = cmisDocument.contentStreamMediaType;
    
    return alfDocument;
}


- (AlfrescoNode *)nodeFromCMISObject:(CMISObject *)cmisObject
{
    AlfrescoNode *alfNode = nil;
    
    if ([cmisObject isKindOfClass:[CMISFolder class]])
    {
        alfNode = [self folderFromCMISFolder:(CMISFolder *)cmisObject];
    }
    else if ([cmisObject isKindOfClass:[CMISDocument class]])
    {
        alfNode = [self documentFromCMISDocument:(CMISDocument *)cmisObject];
    }
    
    CMISProperties *properties = cmisObject.properties;
    NSArray *propertyArray = [properties propertyList];
    NSMutableDictionary *alfPropertiesDict = [NSMutableDictionary dictionaryWithCapacity:propertyArray.count];
    for (CMISPropertyData *propData in propertyArray) {
        AlfrescoProperty *alfProperty = [[AlfrescoProperty alloc] init];
        NSString *propertyStringType = propData.identifier;
        alfProperty.type = [AlfrescoObjectConverter typeForCMISProperty:propertyStringType];
        if(propData.values != nil && propData.values.count > 1)
        {
            alfProperty.isMultiValued = YES;
            alfProperty.value = propData.values;
        }
        else 
        {
            alfProperty.isMultiValued = NO;
            alfProperty.value = propData.firstValue;
        }
        [alfPropertiesDict setObject:alfProperty forKey:propData.identifier];
    }
    alfNode.properties = alfPropertiesDict;
    
    CMISAllowableActions *allowableActions = cmisObject.allowableActions;
    NSSet *actionSet = [allowableActions allowableActionTypesSet];
    
    AlfrescoPermissions *permissions = [[AlfrescoPermissions alloc] initWithPermissions:actionSet];
    objc_setAssociatedObject(alfNode, &kAlfrescoPermissionsObjectKey, permissions, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    
    NSMutableArray *alfrescoAspectArray = [NSMutableArray array];
    NSArray *extensionArray = [cmisObject extensionsForExtensionLevel:CMISExtensionLevelProperties];
    for (CMISExtensionElement *object in extensionArray) {
        if ([object.name isEqualToString:kAlfrescoAspects])
        {
            NSArray *aspectArray = [object children];
            for (CMISExtensionElement *aspect in aspectArray) {
                if ([aspect.name isEqualToString:kAlfrescoAppliedAspects])
                {
                    [alfrescoAspectArray addObject:aspect.value];
                }
                else if ([aspect.name isEqualToString:kAlfrescoAspectProperties])
                {
                    NSArray *propertyArray = [aspect children];
                    for (CMISExtensionElement *property in propertyArray) 
                    {
                        AlfrescoProperty *alfProperty = [[AlfrescoProperty alloc] init];
                        NSString *extensionPropertyString = [property.attributes valueForKey:kAlfrescoAspectPropertyDefinitionId];
                        alfProperty.type = [AlfrescoObjectConverter typeForCMISProperty:extensionPropertyString];
                        CMISExtensionElement *propertyValueElement = (CMISExtensionElement *)[property.children objectAtIndex:0];
                        alfProperty.value = propertyValueElement.value;
                        [alfNode.properties setValue:alfProperty forKey:extensionPropertyString];
                    }
                }
            }
        }
    }
    alfNode.aspects = alfrescoAspectArray;
    alfNode.title = [NSString stringWithFormat:@"%@", ((AlfrescoProperty *)[alfPropertiesDict valueForKey:kCMISTitle]).value];
    if(((AlfrescoProperty *)[alfPropertiesDict valueForKey:kCMISDescription]).value != nil)
    {
        alfNode.summary = [NSString stringWithFormat:@"%@", ((AlfrescoProperty *)[alfPropertiesDict valueForKey:kCMISDescription]).value];
    }
    
    return alfNode;
}

- (AlfrescoNode *)nodeFromCMISObjectData:(CMISObjectData *)cmisObjectData
{
    CMISSession *cmisSession = [self.session objectForParameter:kAlfrescoSessionKeyCmisSession];
    CMISObjectConverter *cmisObjectConverter = [[CMISObjectConverter alloc] initWithSession:cmisSession];
    
    CMISObject *cmisObject = [cmisObjectConverter convertObject:cmisObjectData];
    return [self nodeFromCMISObject:cmisObject];
}

- (AlfrescoDocument *)documentFromCMISQueryResult:(CMISQueryResult *)cmisQueryResult
{
    CMISSession *cmisSession = [self.session objectForParameter:kAlfrescoSessionKeyCmisSession];
    CMISObjectData *data = [[CMISObjectData alloc] init];
    data.identifier = [[cmisQueryResult propertyForId:kCMISPropertyObjectId] firstValue];
    data.baseType = CMISBaseTypeDocument;
    data.properties = cmisQueryResult.properties;
    data.allowableActions = cmisQueryResult.allowableActions;
    CMISObjectConverter *cmisObjectConverter = [[CMISObjectConverter alloc] initWithSession:cmisSession];
    
    CMISObject *cmisObject = [cmisObjectConverter convertObject:data];
    return (AlfrescoDocument *)[self nodeFromCMISObject:cmisObject];
}


+ (NSArray *)parseCloudJSONEntriesFromListData:(NSData *)data error:(NSError **)outError
{
    if (nil == data)
    {
        *outError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeJSONParsing withDetailedDescription:@"Parse JSON shouldn't be nil"];
        return nil;
    }
    NSError *error = nil;
    id jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (nil == jsonDictionary)
    {
        *outError = [AlfrescoErrors alfrescoError:error withAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
        return nil;
    }
    
    if (![jsonDictionary isKindOfClass:[NSDictionary class]])
    {
        *outError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeJSONParsing withDetailedDescription:@"JSON data set should map to NSDictionary"];
        return nil;
    }
    
    id listObject = [jsonDictionary valueForKey:kAlfrescoCloudJSONList];
    if (![listObject isKindOfClass:[NSDictionary class]])
    {
        *outError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeJSONParsing withDetailedDescription:@"JSON data set should map to NSDictionary"];
        return nil;
    }
    id entries = [listObject valueForKey:kAlfrescoCloudJSONEntries];
    if (![entries isKindOfClass:[NSArray class]])
    {
        *outError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeJSONParsing withDetailedDescription:@"JSON data set should map to NSArray"];
        return nil;
    }
    NSArray *entriesArray = [NSArray arrayWithArray:entries];
    return entriesArray;
}


+ (NSDictionary *)parseCloudJSONEntryFromListData:(NSData *)data error:(NSError **)outError
{
    if (nil == data)
    {
        *outError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeJSONParsing withDetailedDescription:@"Parse JSON shouldn't be nil"];
        return nil;
    }
    NSError *error = nil;
    id jsonSite = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if(nil == jsonSite)
    {
        *outError = [AlfrescoErrors alfrescoError:error withAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
        return nil;
    }
    if ([jsonSite isKindOfClass:[NSDictionary class]] == NO)
    {
        *outError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeJSONParsing withDetailedDescription:@"Parse result is no sites"];
        return nil;
    }
    if([[jsonSite valueForKeyPath:kAlfrescoJSONStatusCode] isEqualToNumber:[NSNumber numberWithInt:404]])
    {
        //        *outError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeSites withDetailedDescription:@"Parse result is no sites"];
        return nil;
    }
    id jsonDictObj = (NSDictionary *)jsonSite;
    if (![jsonDictObj isKindOfClass:[NSDictionary class]])
    {
        *outError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeJSONParsing withDetailedDescription:@"JSON data set should map to NSDictionary"];
        return nil;
    }
    NSDictionary *jsonDict = (NSDictionary *)jsonDictObj;
    NSDictionary *entryDict = [jsonDict valueForKey:kAlfrescoCloudJSONEntry];
    if (nil == entryDict)
    {
        *outError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeJSONParsing withDetailedDescription:@"no Entry element found in JSON"];
    }
    return entryDict;
}



#pragma mark internal methods
+ (AlfrescoPropertyType)typeForCMISProperty:(NSString *)propertyIdentifier
{
    if ([[propertyIdentifier lowercaseString] hasSuffix:kCMISPropertyIntValue]) 
    {
        return AlfrescoPropertyTypeInteger;
    }
    else if ([[propertyIdentifier lowercaseString] hasSuffix:kCMISPropertyBooleanValue]) 
    {
        return AlfrescoPropertyTypeBoolean;
    }
    else if ([[propertyIdentifier lowercaseString] hasSuffix:kCMISPropertyDatetimeValue]) 
    {
        return AlfrescoPropertyTypeDateTime;
    }
    else if ([[propertyIdentifier lowercaseString] hasSuffix:kCMISPropertyDecimalValue]) 
    {
        return AlfrescoPropertyTypeDecimal;
    }
    else if ([[propertyIdentifier lowercaseString] hasSuffix:kCMISPropertyIdValue]) 
    {
        return AlfrescoPropertyTypeId;
    }
    else
    {
        return AlfrescoPropertyTypeString;        
    }
}


@end
