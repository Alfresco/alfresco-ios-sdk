/*
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
 */

#import <Foundation/Foundation.h>
#import "CMISAtomPubConstants.h"
#import "CMISObjectData.h"
#import "CMISPropertyData.h"
#import "CMISProperties.h"
#import "CMISAtomEntryParser.h"

@interface CMISAtomFeedParser : NSObject <NSXMLParserDelegate, CMISAtomEntryParserDelegate>

/**
 * The entries contained in the feed (array of CMISObjectData objects).
 */
@property (nonatomic, strong, readonly) NSArray *entries;

/**
 * The links for the feed.
 */
@property (nonatomic, strong, readonly) CMISLinkRelations *linkRelations;

/**
 * Number of items will be returned when executing a query.
 */
@property (readonly) NSInteger numItems;

- (id)initWithData:(NSData*)feedData;
- (BOOL)parseAndReturnError:(NSError **)error;

@end
