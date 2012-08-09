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

#import "CMISAtomPubExtensionDataParserBase.h"

@implementation CMISAtomPubExtensionDataParserBase

@synthesize childParserDelegate = _childParserDelegate;
@synthesize currentExtensions = _currentExtensions;
@synthesize currentExtensionData = _currentExtensionData;
@synthesize previousExtensionDataArray = _previousExtensionDataArray;

#pragma mark -
#pragma mark Initializers

// Designated Initializer
- (id)init
{
    self = [super init];
    if (self)
    {
        self.previousExtensionDataArray = [NSMutableArray array];
    }
    return self;
}

#pragma mark - 
#pragma mark Instance Methods

- (void)pushNewCurrentExtensionData:(CMISExtensionData *)extensionDataObject
{
    // Save the current state of the extensionData objects used for parsing
    if (self.currentExtensionData)
    {
        if (self.currentExtensions)
        {
            self.currentExtensionData.extensions = [self.currentExtensions copy];
        }
        
        [self.previousExtensionDataArray addObject:self.currentExtensionData];
    }
    
    // Set the new extensionData object provided to be the current
    self.currentExtensionData = extensionDataObject;
    // extensions are nil'ed out since we have a new extensionData object
    self.currentExtensions = nil;
}

- (void)saveCurrentExtensionsAndPushPreviousExtensionData
{
    // set the current extensions 
    self.currentExtensionData.extensions = [self.currentExtensions copy];
    self.currentExtensionData = nil;
    
    // set the previous extensionData object, note - we don't mind that the return values are nil
    self.currentExtensionData = self.previousExtensionDataArray.lastObject;
    self.currentExtensions = [self.currentExtensionData.extensions mutableCopy];
    
    // if previous actually existed, remove last object
    if (self.currentExtensionData)
    {
        [self.previousExtensionDataArray removeLastObject];
    }
}

#pragma mark -
#pragma mark CMISAtomPubExtensionElementParserDelegate Method

- (void)extensionElementParser:(CMISAtomPubExtensionElementParser *)parser didFinishParsingExtensionElement:(CMISExtensionElement *)extensionElement
{
    // TODO Should abstract the ExtensionData parsing as this pattern is repeated everywhere ExtensionData is getting parsed.
    
    if (self.currentExtensions == nil)
    {
        self.currentExtensions = [[NSMutableArray alloc] init];
    }
    
    [self.currentExtensions addObject:extensionElement];
    
//    self.childParserDelegate = nil;
}

@end
