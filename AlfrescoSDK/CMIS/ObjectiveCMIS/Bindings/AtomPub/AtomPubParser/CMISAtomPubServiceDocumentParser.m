/*
  Licensed to the Apache Software Foundation (ASF) under one
  or more contributor license agreements.  See the NOTICE file
  distributed with this work for additional information
  regarding copyright ownership.  The ASF licenses this file
  to you under the Apache License, Version 2.0 (the
  "License"); you may not use this file except in compliance
  with the License.  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an
  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
  KIND, either express or implied.  See the License for the
  specific language governing permissions and limitations
  under the License.
 */

#import "CMISAtomPubServiceDocumentParser.h"
#import "CMISAtomWorkspace.h"
#import "CMISAtomCollection.h"
#import "CMISAtomLink.h"
#import "CMISAtomPubConstants.h"
#import "CMISLinkRelations.h"
#import "CMISLog.h"

@interface CMISAtomPubServiceDocumentParser ()

@property (nonatomic, strong) NSData *atomData;
@property (nonatomic, strong) NSMutableArray *internalWorkspaces;

@property (nonatomic, strong) NSMutableString *currentString;
@property (nonatomic, strong) CMISAtomWorkspace *currentWorkSpace;
@property (nonatomic, strong) CMISAtomCollection *currentCollection;
@property (nonatomic, strong) NSMutableSet *currentAtomLinks;
@property (nonatomic, strong) NSString *currentTemplate;
@property (nonatomic, strong) NSString *currentType;
@property (nonatomic, strong) NSString *currentMediaType;
@property (nonatomic, strong) id<NSXMLParserDelegate> childParserDelegate;

@end


@implementation CMISAtomPubServiceDocumentParser

@synthesize atomData = _atomData;
@synthesize internalWorkspaces = _internalWorkspaces;

@synthesize currentString = _currentString;
@synthesize currentWorkSpace = _currentWorkSpace;
@synthesize currentCollection = _currentCollection;
@synthesize currentAtomLinks = _currentAtomLinks;
@synthesize currentTemplate = _currentTemplate;
@synthesize currentType = _currentType;
@synthesize currentMediaType = _currentMediaType;
@synthesize childParserDelegate = _childParserDelegate;


- (id)initWithData:(NSData*)atomData
{
    self = [super init];
    if (self){
        self.atomData = atomData;
    }
    
    return self;
}

- (BOOL)parseAndReturnError:(NSError **)error;
{
    // create the array to hold the workspaces we find
    self.internalWorkspaces = [NSMutableArray array];
    
    // parse the AtomPub data
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.atomData];
    [parser setShouldProcessNamespaces:YES];
    [parser setDelegate:self];
    BOOL parseSuccessful = [parser parse];
    
    if (!parseSuccessful){
        NSError *parserError = [parser parserError];
        CMISLogError(@"Parsing error : %@", parserError);
        if (error) {
            *error = parserError;
        }
    }
    return parseSuccessful;
}

- (NSArray *)workspaces
{
    return [NSArray arrayWithArray:self.internalWorkspaces];
}

#pragma mark -
#pragma mark NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict 
{
    self.currentString = [[NSMutableString alloc] init];

    if ([elementName isEqualToString:kCMISAppWorkspace]) {
        self.currentWorkSpace = [[CMISAtomWorkspace alloc] init];
    } else if ([elementName isEqualToString:kCMISRestAtomRepositoryInfo]) {
        self.childParserDelegate = [CMISAtomPubRepositoryInfoParser repositoryInfoParserWithParentDelegate:self parser:parser];
    } else if ([elementName isEqualToString:kCMISAppCollection]) {
        self.currentCollection = [[CMISAtomCollection alloc] init];
        self.currentCollection.href = [attributeDict objectForKey:kCMISAtomLinkAttrHref];
    } else if ([elementName isEqualToString:kCMISAtomLink]) {
        if (self.currentAtomLinks == nil) {
            self.currentAtomLinks = [[NSMutableSet alloc] init];
        }
        
        CMISAtomLink *atomLink = [[CMISAtomLink alloc] initWithRelation:[attributeDict objectForKey:kCMISAtomLinkAttrRel]  
                                                                   type:[attributeDict objectForKey:kCMISAtomLinkAttrType] 
                                                                   href:[attributeDict objectForKey:kCMISAtomLinkAttrHref]];
        [self.currentAtomLinks addObject:atomLink];
    }
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
    // TODO: parser needs refactoring!

    if ([elementName isEqualToString:kCMISAppWorkspace]) {
        self.currentWorkSpace.linkRelations = [[CMISLinkRelations alloc] initWithLinkRelationSet:[self.currentAtomLinks copy]];
        self.currentAtomLinks = nil;
        
        [self.internalWorkspaces addObject:self.currentWorkSpace];
    } else if ([elementName isEqualToString:kCMISRestAtomUritemplate]) {
        if ([self.currentType isEqualToString:kCMISUriTemplateObjectById]) {
            self.currentWorkSpace.objectByIdUriTemplate = self.currentTemplate;
        } else if ([self.currentType isEqualToString:kCMISUriTemplateObjectByPath]) {
            self.currentWorkSpace.objectByPathUriTemplate = self.currentTemplate;
        } else if ([self.currentType isEqualToString:kCMISUriTemplateTypeById]) {
            self.currentWorkSpace.typeByIdUriTemplate = self.currentTemplate;
        } else if ([self.currentType isEqualToString:kCMISUriTemplateQuery]) {
            self.currentWorkSpace.queryUriTemplate = self.currentTemplate;
        }
    } else if ([elementName isEqualToString:kCMISRestAtomTemplate]) {
        self.currentTemplate = self.currentString;
    } else if ([elementName isEqualToString:kCMISRestAtomType]) {
        self.currentType = self.currentString;
    } else if ([elementName isEqualToString:kCMISRestAtomMediaType]) {
        self.currentMediaType = self.currentString;
    } else if ([elementName isEqualToString:kCMISAppCollection]) {
        if (self.currentWorkSpace.collections == nil) {
            self.currentWorkSpace.collections = [[NSMutableArray alloc] init];
        }
        [self.currentWorkSpace.collections addObject:self.currentCollection];
        self.currentCollection = nil;
    } else if ([elementName isEqualToString:kCMISAtomTitle]) {
        self.currentCollection.title = self.currentString;
    } else if ([elementName isEqualToString:kCMISAppAccept]) {
        self.currentCollection.accept = self.currentString;
    } else if ([elementName isEqualToString:kCMISRestAtomCollectionType]) {
        self.currentCollection.type = self.currentString;
    }

    self.currentString = nil;
}

#pragma mark -
#pragma mark CMISRepositoryInfoParserDelegate methods
- (void)repositoryInfoParser:(CMISAtomPubRepositoryInfoParser *)repositoryInfoParser didFinishParsingRepositoryInfo:(CMISRepositoryInfo *)repositoryInfo
{
    self.currentWorkSpace.repositoryInfo = repositoryInfo;
}

@end
