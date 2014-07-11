/*
 ******************************************************************************
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
 *****************************************************************************
 */

//
// AlfrescoCMISUtil 
//
#import "AlfrescoCMISUtil.h"
#import "CMISObject.h"
#import "CMISAtomPubConstants.h"
#import "CMISAtomPubParserUtil.h"
#import "CMISErrors.h"
#import "CMISConstants.h"
#import "CMISSession.h"
#import "CMISObjectConverter.h"
#import "AlfrescoErrors.h"
#import "AlfrescoConstants.h"
#import "AlfrescoInternalConstants.h"

#define ALFRESCO_EXTENSION_ASPECTS @"aspects"
#define ALFRESCO_EXTENSION_APPLIED_ASPECTS @"appliedAspects"
#define ALFRESCO_EXTENSION_PROPERTIES @"properties"
#define ALFRESCO_EXTENSION_PROPERTY_VALUE @"value"


@implementation AlfrescoCMISUtil

static NSSet *titledAspectProperties;
static NSSet *geographicAspectProperties;
static NSSet *exifAspectProperties;
static NSSet *audioAspectProperties;

+ (void)initialize
{
    // initialise all the aspect sets
    if (self == [AlfrescoCMISUtil class])
    {
        // unfortunately there isn't a literal syntax for creating NSSet, yet!
        titledAspectProperties = [[NSSet alloc] initWithObjects:kAlfrescoModelPropertyTitle,
                                  kAlfrescoModelPropertyDescription, nil];
        
        geographicAspectProperties = [[NSSet alloc] initWithObjects:kAlfrescoModelPropertyLatitude,
                                  kAlfrescoModelPropertyLongitude, nil];
        
        exifAspectProperties = [[NSSet alloc] initWithObjects:kAlfrescoModelPropertyExifDateTimeOriginal,
                                kAlfrescoModelPropertyExifPixelXDimension,
                                kAlfrescoModelPropertyExifPixelYDimension,
                                kAlfrescoModelPropertyExifExposureTime,
                                kAlfrescoModelPropertyExifFNumber,
                                kAlfrescoModelPropertyExifFlash,
                                kAlfrescoModelPropertyExifFocalLength,
                                kAlfrescoModelPropertyExifISOSpeedRating,
                                kAlfrescoModelPropertyExifManufacturer,
                                kAlfrescoModelPropertyExifModel,
                                kAlfrescoModelPropertyExifSoftware,
                                kAlfrescoModelPropertyExifOrientation,
                                kAlfrescoModelPropertyExifXResolution,
                                kAlfrescoModelPropertyExifYResolution,
                                kAlfrescoModelPropertyExifResolutionUnit, nil];
        
        audioAspectProperties = [[NSSet alloc] initWithObjects:kAlfrescoModelPropertyAudioAlbum,
                                 kAlfrescoModelPropertyAudioArtist,
                                 kAlfrescoModelPropertyAudioComposer,
                                 kAlfrescoModelPropertyAudioEngineer,
                                 kAlfrescoModelPropertyAudioGenre,
                                 kAlfrescoModelPropertyAudioTrackNumber,
                                 kAlfrescoModelPropertyAudioReleaseDate,
                                 kAlfrescoModelPropertyAudioSampleRate,
                                 kAlfrescoModelPropertyAudioSampleType,
                                 kAlfrescoModelPropertyAudioChannelType,
                                 kAlfrescoModelPropertyAudioCompressor, nil];
     }
}

+ (NSMutableArray *)processExtensionElementsForObject:(CMISObject *)cmisObject
{
    NSArray *alfrescoExtensions = [cmisObject extensionsForExtensionLevel:CMISExtensionLevelProperties];
    NSMutableArray *aspectTypeIds = [[NSMutableArray alloc] init];

    // We'll gather all the properties, and expose them as conveniently on the document
    NSMutableArray *propertyExtensionRootElements = [[NSMutableArray alloc] init];

    // Find all Alfresco aspects in the extensions
    if (alfrescoExtensions != nil && alfrescoExtensions.count > 0)
    {
        for (CMISExtensionElement *extensionElement in alfrescoExtensions)
        {
            if ([extensionElement.name isEqualToString:ALFRESCO_EXTENSION_ASPECTS])
            {
                for (CMISExtensionElement *childExtensionElement in extensionElement.children)
                {
                    if ([childExtensionElement.name isEqualToString:ALFRESCO_EXTENSION_APPLIED_ASPECTS])
                    {
                        [aspectTypeIds addObject:childExtensionElement.value];
                    }
                    else if ([childExtensionElement.name isEqualToString:ALFRESCO_EXTENSION_PROPERTIES])
                    {
                        [propertyExtensionRootElements addObject:childExtensionElement];
                    }
                }
            }
        }
    }

    // Convert all extended properties to 'real' properties
    for (CMISExtensionElement *propertyRootExtensionElement in propertyExtensionRootElements)
    {
        for (CMISExtensionElement *propertyExtension in propertyRootExtensionElement.children)
        {
            CMISPropertyData *propertyData = [[CMISPropertyData alloc] init];
            propertyData.identifier = (propertyExtension.attributes)[kCMISAtomEntryPropertyDefId];
            propertyData.displayName = (propertyExtension.attributes)[kCMISAtomEntryDisplayName];
            propertyData.queryName = (propertyExtension.attributes)[kCMISAtomEntryQueryName];
            propertyData.type = [CMISAtomPubParserUtil atomPubTypeToInternalType:propertyExtension.name];

            
            // MOBSDK-616: multi-valued aspect properties will have multiple children, not just one!
            NSMutableArray *propertyValues = [NSMutableArray array];
            for (CMISExtensionElement *valueExtensionElement in propertyExtension.children)
            {
                if (valueExtensionElement.value)
                {
                    [CMISAtomPubParserUtil parsePropertyValue:valueExtensionElement.value propertyType:propertyExtension.name addToArray:propertyValues];
                }
            }
            
            // if there were values add them to the property data object
            if (propertyValues.count > 0)
            {
                propertyData.values = (NSArray *)propertyValues;
            }

            [cmisObject.properties addProperty:propertyData];
        }
    }

    return aspectTypeIds;
}

+ (NSError *)alfrescoErrorWithCMISError:(NSError *)cmisError
{
    NSInteger cmisErrorCode = [cmisError code];
    NSError *alfrescoError = nil;
    switch (cmisErrorCode)
    {
        case kCMISErrorCodeUnknown:
            alfrescoError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:cmisError andAlfrescoErrorCode:kAlfrescoErrorCodeHTTPResponse];
            break;
        case kCMISErrorCodeConnection:
            alfrescoError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:cmisError andAlfrescoErrorCode:kAlfrescoErrorCodeSession];
            break;
        case kCMISErrorCodeProxyAuthentication:
            alfrescoError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:cmisError andAlfrescoErrorCode:kAlfrescoErrorCodeUnauthorisedAccess];
            break;
        case kCMISErrorCodeUnauthorized:
            alfrescoError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:cmisError andAlfrescoErrorCode:kAlfrescoErrorCodeUnauthorisedAccess];
            break;
        case kCMISErrorCodeNoRootFolderFound:
            alfrescoError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:cmisError andAlfrescoErrorCode:kAlfrescoErrorCodeRequestedNodeNotFound];
            break;
        case kCMISErrorCodeNoRepositoryFound:
            alfrescoError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:cmisError andAlfrescoErrorCode:kAlfrescoErrorCodeNoRepositoryFound];
            break;
        case kCMISErrorCodeCancelled:
            alfrescoError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:cmisError andAlfrescoErrorCode:kAlfrescoErrorCodeNetworkRequestCancelled];
            break;
        case kCMISErrorCodeInvalidArgument:
            alfrescoError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:cmisError andAlfrescoErrorCode:kAlfrescoErrorCodeHTTPResponse];
            break;
        case kCMISErrorCodeObjectNotFound:
            alfrescoError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:cmisError andAlfrescoErrorCode:kAlfrescoErrorCodeRequestedNodeNotFound];
            break;
        case kCMISErrorCodeNotSupported:
            alfrescoError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:cmisError andAlfrescoErrorCode:kAlfrescoErrorCodeHTTPResponse];
            break;
        case kCMISErrorCodePermissionDenied:
            alfrescoError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:cmisError andAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolderPermissions];
            break;
        case kCMISErrorCodeRuntime:
            alfrescoError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:cmisError andAlfrescoErrorCode:kAlfrescoErrorCodeUnknown];
            break;
        case kCMISErrorCodeConstraint:
            alfrescoError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:cmisError andAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolder];
            break;
        case kCMISErrorCodeContentAlreadyExists:
            alfrescoError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:cmisError andAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolderNodeAlreadyExists];
            break;
        case kCMISErrorCodeFilterNotValid:
            alfrescoError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:cmisError andAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolder];
            break;
        case kCMISErrorCodeNameConstraintViolation:
            alfrescoError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:cmisError andAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolder];
            break;
        case kCMISErrorCodeStorage:
            alfrescoError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:cmisError andAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolder];
            break;
        case kCMISErrorCodeStreamNotSupported:
            alfrescoError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:cmisError andAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolder];
            break;
        case kCMISErrorCodeUpdateConflict:
            alfrescoError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:cmisError andAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolder];
            break;
        case kCMISErrorCodeVersioning:
            alfrescoError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:cmisError andAlfrescoErrorCode:kAlfrescoErrorCodeHTTPResponse];
            break;
        case kCMISErrorCodeNoNetworkConnection:
            alfrescoError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:cmisError andAlfrescoErrorCode:kAlfrescoErrorCodeNoNetworkConnection];
            break;
            
        default:
            alfrescoError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeUnknown];
            break;
    }
    return alfrescoError;
}

+ (NSString *)prepareObjectTypeIdForProperties:(NSDictionary *)alfrescoProperties
                                          type:(NSString *)type
                                       aspects:(NSArray *)aspects
                                        folder:(BOOL)folder
{
    NSString *cmisTypeId = nil;
    
    // use the type if present (takes precedence over the property)
    if (type != nil)
    {
        // first check whether it's one of the base Alfresco types
        if ([type isEqualToString:kAlfrescoModelTypeContent])
        {
            cmisTypeId = kCMISPropertyObjectTypeIdValueDocument;
        }
        else if ([type isEqualToString:kAlfrescoModelTypeFolder])
        {
            cmisTypeId = kCMISPropertyObjectTypeIdValueFolder;
        }
        else if ([type isEqualToString:kCMISPropertyObjectTypeIdValueDocument])
        {
            cmisTypeId = kCMISPropertyObjectTypeIdValueDocument;
        }
        else if ([type isEqualToString:kCMISPropertyObjectTypeIdValueFolder])
        {
            cmisTypeId = kCMISPropertyObjectTypeIdValueFolder;
        }
        else
        {
            // custom type so prefix appropriately
            NSString *customTypePrefix = (folder) ? kAlfrescoCMISFolderTypePrefix : kAlfrescoCMISDocumentTypePrefix;
            cmisTypeId = [customTypePrefix stringByAppendingString:type];
        }
    }
    else
    {
        // check the objectTypeId property
        NSString *providedObjectTypeId = alfrescoProperties[kCMISPropertyObjectTypeId];
        if (providedObjectTypeId == nil)
        {
            if (folder)
            {
                cmisTypeId = kCMISPropertyObjectTypeIdValueFolder;
            }
            else
            {
                cmisTypeId = kCMISPropertyObjectTypeIdValueDocument;
            }
        }
        else
        {
            // swap any use of the Alfresco base types with the CMIS equivalent
            if ([providedObjectTypeId rangeOfString:kAlfrescoModelTypeFolder].location != NSNotFound)
            {
                cmisTypeId = [providedObjectTypeId stringByReplacingOccurrencesOfString:kAlfrescoModelTypeFolder withString:kCMISPropertyObjectTypeIdValueFolder];
            }
            else if ([providedObjectTypeId rangeOfString:kAlfrescoModelTypeContent].location != NSNotFound)
            {
                cmisTypeId = [providedObjectTypeId stringByReplacingOccurrencesOfString:kAlfrescoModelTypeContent withString:kCMISPropertyObjectTypeIdValueDocument];
            }
            else
            {
                // use the provided objectTypeId property
                cmisTypeId = providedObjectTypeId;
            }
        }
    }
    
    // create initial objectTypeId string
    NSMutableString *objectTypeId = [NSMutableString stringWithString:cmisTypeId];
    
    // process aspects
    NSMutableSet *aspectsSet = [NSMutableSet setWithArray:aspects];
    
    // go through the properties looking for well known aspect properties
    if (alfrescoProperties != nil)
    {
        [alfrescoProperties enumerateKeysAndObjectsUsingBlock:^(NSString *propertyName, id propertyValue, BOOL *stop) {
            // check for author property
            if ([propertyName isEqualToString:kAlfrescoModelPropertyAuthor])
            {
                [aspectsSet addObject:kAlfrescoModelAspectAuthor];
            }
            else
            {
                // check the aspect sets, if the property is found, add the corresponding aspect to the list
                if ([titledAspectProperties containsObject:propertyName])
                {
                    [aspectsSet addObject:kAlfrescoModelAspectTitled];
                }
                else if ([exifAspectProperties containsObject:propertyName])
                {
                    [aspectsSet addObject:kAlfrescoModelAspectExif];
                }
                else if ([geographicAspectProperties containsObject:propertyName])
                {
                    [aspectsSet addObject:kAlfrescoModelAspectGeographic];
                }
                else if ([audioAspectProperties containsObject:propertyName])
                {
                    [aspectsSet addObject:kAlfrescoModelAspectAudio];
                }
            }
        }];
    }
    
    // append aspects, if required
    if (aspectsSet.count > 0)
    {
        [aspectsSet enumerateObjectsUsingBlock:^(NSString *aspect, BOOL *stop){
            // ignore any system aspects
            if (![aspect hasPrefix:kAlfrescoSystemModelPrefix])
            {
                // append the aspect if it wasn't already present in the objectTypeId property
                if ([cmisTypeId rangeOfString:aspect].location == NSNotFound)
                {
                    [objectTypeId appendString:[NSString stringWithFormat:@",%@%@", kAlfrescoCMISAspectPrefix, aspect]];
                }
            }
        }];
    }
    
    return objectTypeId;
}

+ (void)preparePropertiesForUpdate:(NSDictionary *)alfrescoProperties
                              node:(AlfrescoNode *)node
                       cmisSession:(CMISSession *)cmisSession
                   completionBlock:(void (^)(CMISProperties *cmisProperties, NSError *error))completionBlock
{
    // swap the cm:name for cmis:name, if present
    NSMutableDictionary *cmisProperties = [NSMutableDictionary dictionaryWithDictionary:alfrescoProperties];
    if ([[alfrescoProperties allKeys] containsObject:kAlfrescoModelPropertyName])
    {
        NSString *name = [alfrescoProperties valueForKey:kAlfrescoModelPropertyName];
        [cmisProperties setValue:name forKey:kCMISPropertyName];
        [cmisProperties removeObjectForKey:kAlfrescoModelPropertyName];
    }
    
    // make sure there is a cmis:name property present
    if (![[cmisProperties allKeys] containsObject:kCMISPropertyName])
    {
        [cmisProperties setValue:node.name forKey:kCMISPropertyName];
    }
    
    // set the fully qualified objectTypeId
    NSString *objectTypeId = [AlfrescoCMISUtil prepareObjectTypeIdForProperties:alfrescoProperties type:node.type aspects:node.aspects folder:node.isFolder];
    [cmisProperties setValue:objectTypeId forKey:kCMISPropertyObjectTypeId];
    
    // TODO: determine if we really need to re-retrieve the object
    [cmisSession retrieveObject:node.identifier completionBlock:^(CMISObject *cmisObject, NSError *error) {
        if (nil == cmisObject)
        {
            NSError *alfrescoError = [AlfrescoCMISUtil alfrescoErrorWithCMISError:error];
            completionBlock(nil, alfrescoError);
        }
        else
        {
            // get the CMIS session to convert the raw dictionary into a CMISProperties object, this will
            // also call our overridden converter in order to build extension data representing aspects.
            [cmisSession.objectConverter convertProperties:cmisProperties
                                           forObjectTypeId:cmisObject.objectType
                                           completionBlock:^(CMISProperties *convertedProperties, NSError *conversionError){
                 if (nil == convertedProperties)
                 {
                     NSError *alfrescoError = [AlfrescoCMISUtil alfrescoErrorWithCMISError:conversionError];
                     completionBlock(nil, alfrescoError);
                 }
                 else
                 {
                     // re-build dictionary just to remove the objectTypeId property, CMISProperties should provide a remove method!
                     CMISProperties *updatedProperties = [[CMISProperties alloc] init];
                     NSEnumerator *enumerator = [convertedProperties.propertiesDictionary keyEnumerator];
                     for (NSString *cmisKey in enumerator)
                     {
                         if (![cmisKey isEqualToString:kCMISPropertyObjectTypeId])
                         {
                             CMISPropertyData *propData = (convertedProperties.propertiesDictionary)[cmisKey];
                             [updatedProperties addProperty:propData];
                         }
                     }
                     updatedProperties.extensions = convertedProperties.extensions;
                     
                     // return the properties
                     completionBlock(updatedProperties, nil);
                 }
             }];
        }
    }];
}

@end
