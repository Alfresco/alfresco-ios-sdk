/*******************************************************************************
 * Copyright (C) 2005-2017 Alfresco Software Limited.
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

#import "AlfrescoSAMLTicket.h"

@interface AlfrescoSAMLTicket ()

@property (nonatomic, strong, readwrite) NSString *ticket;
@property (nonatomic, strong, readwrite) NSString *userID;

@end

@implementation AlfrescoSAMLTicket

- (instancetype)initWithTicket:(NSString *)ticket userID:(NSString *)userID
{
    if (self = [super init])
    {
        self.ticket = ticket;
        self.userID = userID;
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        self.ticket = [aDecoder decodeObjectForKey:@"ticket"];
        self.userID = [aDecoder decodeObjectForKey:@"userID"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    if (self.ticket)
    {
        [aCoder encodeObject:self.ticket forKey:@"ticket"];
    }
    
    if (self.userID)
    {
        [aCoder encodeObject:self.userID forKey:@"userID"];
    }
}

- (NSString *)description
{
    NSMutableString *description = [NSMutableString string];
    
    [description appendFormat:@"\nuserId:%@", self.userID];
    [description appendFormat:@"\nticket:%@", self.ticket];
    
    return description;
}

@end
