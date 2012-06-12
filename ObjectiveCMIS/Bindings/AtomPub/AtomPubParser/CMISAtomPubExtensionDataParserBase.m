//
//  CMISAtomPubExtensionDataParserBase.m
//  ObjectiveCMIS
//
//  Created by Gi Lee on 6/11/12.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

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
    
    self.childParserDelegate = nil;
}

@end
