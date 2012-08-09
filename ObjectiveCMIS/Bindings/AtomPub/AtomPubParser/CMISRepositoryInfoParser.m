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

#import "CMISRepositoryInfoParser.h"
#import "CMISAtomPubConstants.h"
#import "CMISAtomCollection.h"

@interface CMISRepositoryInfoParser ()

@property (nonatomic, strong, readwrite) CMISRepositoryInfo *currentRepositoryInfo;

@property (nonatomic, weak) id<NSXMLParserDelegate, CMISRepositoryInfoParserDelegate> parentDelegate;
@property (nonatomic, strong) NSMutableString *currentString;
@property (nonatomic, strong) CMISAtomCollection *currentCollection;

// TODO Temporary object, replace with CMISRepositoryCapabilities object or similar when available
@property (nonatomic, strong) id currentCapabilities;

@property (nonatomic, assign) BOOL isParsingExtensionElement;
@end

@implementation CMISRepositoryInfoParser

@synthesize currentRepositoryInfo = _currentRepositoryInfo;
@synthesize parentDelegate = _parentDelegate;
@synthesize currentString = _currentString;
@synthesize currentCollection = _currentCollection;
@synthesize currentCapabilities = _currentCapabilities;
@synthesize isParsingExtensionElement = _isParsingExtensionElement;


- (id)initRepositoryInfoParserWithParentDelegate:(id<NSXMLParserDelegate, CMISRepositoryInfoParserDelegate>)parentDelegate parser:(NSXMLParser *)parser
{
    self = [super init];
    if (self)
    {
        self.currentString = [[NSMutableString alloc] init];
        self.currentRepositoryInfo = [[CMISRepositoryInfo alloc] init];
        self.parentDelegate = parentDelegate;
        
        self.isParsingExtensionElement = NO;
        
        [self pushNewCurrentExtensionData:self.currentRepositoryInfo];
        
        [parser setDelegate:self];
    }
    return self;
}

+ (id)repositoryInfoParserWithParentDelegate:(id<NSXMLParserDelegate, CMISRepositoryInfoParserDelegate>)parentDelegate parser:(NSXMLParser *)parser
{
    return [[self alloc] initRepositoryInfoParserWithParentDelegate:parentDelegate parser:parser];
}

#pragma mark -
#pragma mark NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict 
{
    self.currentString = [[NSMutableString alloc] init];
    
    if ([namespaceURI isEqualToString:kCMISNamespaceCmis])
    {
        if ([elementName isEqualToString:kCMISCoreCapabilities])
        {
            self.currentCapabilities = [NSMutableDictionary dictionaryWithCapacity:14];
        }
    }
    else if ( ![namespaceURI isEqualToString:kCMISNamespaceCmis] && ![namespaceURI isEqualToString:kCMISNamespaceApp] 
              && ![namespaceURI isEqualToString:kCMISNamespaceAtom] && ![namespaceURI isEqualToString:kCMISNamespaceCmisRestAtom]) 
    {
        self.isParsingExtensionElement = YES;
        self.childParserDelegate = [CMISAtomPubExtensionElementParser extensionElementParserWithElementName:elementName namespaceUri:namespaceURI attributes:attributeDict parentDelegate:self parser:parser];
    }
    
    // TODO Parse ACL Capabilities
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string 
{
    // Simply add the parsed string to the current string
    // Do not add any logic here, since the parser splits up data rather easily
    // (eg when an ampersand is used within a url, it will split it up and call this this method a few times)
    [self.currentString appendString:string];
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName 
{
    if ([namespaceURI isEqualToString:kCMISNamespaceCmis])
    {
        if ([elementName isEqualToString:kCMISCoreRepositoryId])
        {
            self.currentRepositoryInfo.identifier = self.currentString;
        }
        else if ([elementName isEqualToString:kCMISCoreRepositoryName])
        {
            self.currentRepositoryInfo.name = self.currentString;
        }
        else if ([elementName isEqualToString:kCMISCoreRepositoryDescription])
        {
            self.currentRepositoryInfo.desc = self.currentString;
        }
        else if ([elementName isEqualToString:kCMISCoreVendorName])
        {
            self.currentRepositoryInfo.vendorName = self.currentString;
        }
        else if ([elementName isEqualToString:kCMISCoreProductName])
        {
            self.currentRepositoryInfo.productName = self.currentString;
        }
        else if ([elementName isEqualToString:kCMISCoreProductVersion])
        {
            self.currentRepositoryInfo.productVersion = self.currentString;
        }
        else if ([elementName isEqualToString:kCMISCoreRootFolderId])
        {
            self.currentRepositoryInfo.rootFolderId = self.currentString;
        }
        else if ([elementName isEqualToString:kCMISCoreCmisVersionSupported])
        {
            self.currentRepositoryInfo.cmisVersionSupported = self.currentString;
        }
        else if ([elementName hasPrefix:_kCMISCoreCapabilityPrefix] && self.currentCapabilities)
        {
            [self.currentCapabilities setValue:self.currentString forKeyPath:elementName];
        }
        else if ([elementName isEqualToString:kCMISCoreCapabilities])
        {
            self.currentRepositoryInfo.repositoryCapabilities = self.currentCapabilities;
            self.currentCapabilities = nil;
        }
        else if ([elementName isEqualToString:kCMISCoreAclCapability] || [elementName isEqualToString:kCMISCorePermission]
                 || [elementName isEqualToString:kCMISCorePermissions]|| [elementName isEqualToString:kCMISCoreMapping]
                 || [elementName isEqualToString:kCMISCoreKey]|| [elementName isEqualToString:kCMISCoreSupportedPermissions]
                 || [elementName isEqualToString:kCMISCorePropagation] || [elementName isEqualToString:kCMISCoreDescription])
        {
            
            // TODO Handle ACL Capability tree
        }
        else 
        {
            /*
             TODO Parse these into the repoItem object
                kCMISCoreSupportedPermissions;
                kCMISCorePropagation;
                kCMISCoreCmisVersionSupported;
                kCMISCoreChangesIncomplete;
                kCMISCoreChangesOnType;
                kCMISCorePrincipalAnonymous;
                kCMISCorePrincipalAnyone;
             */
            
            //log(@"TODO Cmis-Core Element was ignored: ElementName=%@, Value=%@",elementName, self.currentString);
        } 
    }
    else if ([namespaceURI isEqualToString:kCMISNamespaceCmisRestAtom])
    {
        if ([elementName isEqualToString:kCMISRestAtomRepositoryInfo] && self.parentDelegate)
        {
            // Finished parsing Properties & its ExtensionData
            [self saveCurrentExtensionsAndPushPreviousExtensionData];

            // Reset the parser's delegate to its parent since we're done with the repositoryInfo node
            [self.parentDelegate repositoryInfoParser:self didFinishParsingRepositoryInfo:self.currentRepositoryInfo];
            [parser setDelegate:self.parentDelegate];
            [self.parentDelegate parser:parser didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];
            self.parentDelegate = nil;
        }
    }
    else if ([namespaceURI isEqualToString:kCMISNamespaceApp] || [namespaceURI isEqualToString:kCMISNamespaceAtom])
    {
        NSLog(@"WARNING: We should not get here");
    }
    else if (self.isParsingExtensionElement)
    {
        self.isParsingExtensionElement = NO;
    }
    
    self.currentString = nil;
}

#pragma mark -
#pragma mark CMISAtomPubExtensionElementParserDelegate Methods

- (void)extensionElementParser:(CMISAtomPubExtensionElementParser *)parser didFinishParsingExtensionElement:(CMISExtensionElement *)extensionElement
{
    if (self.currentExtensions == nil)
    {
        self.currentExtensions = [[NSMutableArray alloc] init];
    }
    
    [self.currentExtensions addObject:extensionElement];
    
//    self.childParserDelegate = nil;
}

@end
