//
//  ServiceDoc.m
//  HybridApp
//
//  Created by Cornwell Gavin on 17/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISServiceDocumentParser.h"

@interface CMISServiceDocumentParser ()
@property (nonatomic, strong) NSData *atomData;
@property (nonatomic, strong) NSString *elementBeingParsed;
@property (nonatomic, strong) CMISRepositoryInfo *currentRepositoryInfo;
@property (nonatomic, strong) NSMutableArray *internalWorkspaces;
@end

@implementation CMISServiceDocumentParser

@synthesize atomData = _atomData;
@synthesize elementBeingParsed = _elementBeingParsed;
@synthesize currentRepositoryInfo = _currentRepositoryInfo;
@synthesize internalWorkspaces = _internalWorkspaces;

- (id)initWithData:(NSData*)atomData
{
    if (self = [super init]) 
    {
        self.atomData = atomData;
    }
    
    return self;
}

- (BOOL)parseAndReturnError:(NSError **)error;
{
    BOOL parseSuccessful = YES;
    
    // create the array to hold the workspaces we find
    self.internalWorkspaces = [NSMutableArray array];
    
    // parse the AtomPub data
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.atomData];
    [parser setShouldProcessNamespaces:YES];
    [parser setDelegate:self];
    parseSuccessful = [parser parse];
    
    if (!parseSuccessful)
    {
        *error = [parser parserError];
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
    self.elementBeingParsed = elementName;
    
    if ([self.elementBeingParsed isEqualToString:@"repositoryInfo"])
    {
        self.currentRepositoryInfo = [[CMISRepositoryInfo alloc] init];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string 
{    
    if ([self.elementBeingParsed isEqualToString:@"repositoryId"])
    {
        self.currentRepositoryInfo.identifier = string;
    }
    else if ([self.elementBeingParsed isEqualToString:@"repositoryName"])
    {
        self.currentRepositoryInfo.name = string;
    }
    else if ([self.elementBeingParsed isEqualToString:@"repositoryDescription"])
    {
        self.currentRepositoryInfo.desc = string;
    }
    else if ([self.elementBeingParsed isEqualToString:@"vendorName"])
    {
        self.currentRepositoryInfo.vendorName = string;
    }
    else if ([self.elementBeingParsed isEqualToString:@"productName"])
    {
        self.currentRepositoryInfo.productName = string;
    }
    else if ([self.elementBeingParsed isEqualToString:@"productVersion"])
    {
        self.currentRepositoryInfo.productVersion = string;
    }
    else if ([self.elementBeingParsed isEqualToString:@"rootFolderId"])
    {
        self.currentRepositoryInfo.rootFolderId = string;
    }
    else if ([self.elementBeingParsed isEqualToString:@"cmisVersionSupported"])
    {
        self.currentRepositoryInfo.cmisVersionSupported = string;
    }
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName 
{
    if ([elementName isEqualToString:@"repositoryInfo"])
    {
        // create a workspace object and add the repo info to it
        CMISWorkspace *workspace = [[CMISWorkspace alloc] init];
        workspace.repositoryInfo = self.currentRepositoryInfo;
        
        // add workspace to list
        [self.internalWorkspaces addObject:workspace];
    }
    
    self.elementBeingParsed = nil;
}

@end


@implementation CMISWorkspace

@synthesize repositoryInfo = _repositoryInfo;

@end
