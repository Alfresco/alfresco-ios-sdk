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
// AlfrescoCMISDocument 
//
#import "AlfrescoCMISDocument.h"
#import "CMISSession.h"
#import "CMISConstants.h"
#import "AlfrescoCMISUtil.h"
#import "AlfrescoInternalConstants.h"

@implementation AlfrescoCMISDocument

- (id)initWithObjectData:(CMISObjectData *)objectData session:(CMISSession *)session
{
    self = [super initWithObjectData:objectData session:session];
    if (self)
    {
        self.aspectTypes = [AlfrescoCMISUtil processExtensionElementsForObject:self];
    }
    return self;
}

- (void)updateProperties:(NSDictionary *)properties completionBlock:(void (^)(CMISObject *object, NSError *error))completionBlock
{
    // We need to 'prepare' the properties first to include all aspects
    NSMutableDictionary *aspectAwareProperties = nil;
    if (properties != nil)
    {
        aspectAwareProperties = [[NSMutableDictionary alloc] initWithDictionary:properties];

        NSString *objectTypeId = [self.aspectTypes componentsJoinedByString:@","];

        CMISSessionParameters *sessionParameters = self.session.sessionParameters;
        BOOL isWebscriptImplementation = [[sessionParameters.atomPubUrl relativeString] hasSuffix:kAlfrescoLegacyCMISPath];
        if (isWebscriptImplementation)
        {
            // Must add the objectType to the property for the old implementation
            objectTypeId = [self.objectType stringByAppendingFormat:@",%@", objectTypeId];
        }
        
        
        [aspectAwareProperties setValue:objectTypeId forKey:kCMISPropertyObjectTypeId];
    }
    [super updateProperties:aspectAwareProperties completionBlock:completionBlock];    
}

/*
- (CMISObject *)updateProperties:(NSDictionary *)properties error:(NSError **)error
{
    // We need to 'prepare' the properties first to include all aspects
    NSMutableDictionary *aspectAwareProperties = nil;
    if (properties != nil)
    {
        aspectAwareProperties = [[NSMutableDictionary alloc] initWithDictionary:properties];

        NSMutableString *objectTypeIdBuilder = [[NSMutableString alloc] init];
        [objectTypeIdBuilder appendString:self.objectType];
        for (NSString *aspectTypeId in self.aspectTypes)
        {
            [objectTypeIdBuilder appendFormat:@", %@", aspectTypeId];
        }

        [aspectAwareProperties setValue:objectTypeIdBuilder forKey:kCMISPropertyObjectTypeId];
    }

    return [super updateProperties:aspectAwareProperties error:error];
}
*/

- (BOOL)hasAspect:(NSString *)aspectTypeId
{
    for (NSString *aspect in self.aspectTypes)
    {
        if ([aspect isEqualToString:aspectTypeId])
        {
            return YES;
        }
    }
    return NO;
}


@end