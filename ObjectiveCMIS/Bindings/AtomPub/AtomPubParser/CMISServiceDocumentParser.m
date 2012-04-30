//
//  ServiceDoc.m
//  HybridApp
//
//  Created by Cornwell Gavin on 17/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISServiceDocumentParser.h"
#import "CMISWorkspace.h"

@interface CMISServiceDocumentParser ()

@property (nonatomic, strong) NSData *atomData;
@property (nonatomic, strong) CMISRepositoryInfo *currentRepositoryInfo;
@property (nonatomic, strong) NSMutableArray *internalWorkspaces;

@property (nonatomic, strong) NSMutableString *currentString;
@property (nonatomic, strong) CMISWorkspace *currentWorkSpace;
@property (nonatomic, strong) NSString *currentTemplate;
@property (nonatomic, strong) NSString *currentType;
@property (nonatomic, strong) NSString *currentMediaType;

@end

@implementation CMISServiceDocumentParser

@synthesize atomData = _atomData;
@synthesize currentRepositoryInfo = _currentRepositoryInfo;
@synthesize internalWorkspaces = _internalWorkspaces;

@synthesize currentString = _currentString;
@synthesize currentWorkSpace = _currentWorkSpace;
@synthesize currentTemplate = _currentTemplate;
@synthesize currentType = _currentType;
@synthesize currentMediaType = _currentMediaType;


- (id)initWithData:(NSData*)atomData
{
    self = [super init];
    if (self)
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
        NSLog(@"Parsing error : %@", [parser parserError]);
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
    self.currentString = [[NSMutableString alloc] init];

    if ([elementName isEqualToString:@"workspace"])
    {
        self.currentWorkSpace = [[CMISWorkspace alloc] init];
    }
    else if ([elementName isEqualToString:@"repositoryInfo"])
    {
        self.currentRepositoryInfo = [[CMISRepositoryInfo alloc] init];
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
    if ([elementName isEqualToString:@"workspace"])
    {
        [self.internalWorkspaces addObject:self.currentWorkSpace];
    }
    else if ([elementName isEqualToString:@"repositoryInfo"])
    {
        self.currentWorkSpace.repositoryInfo = self.currentRepositoryInfo;
    }
    else if ([elementName isEqualToString:@"uritemplate"])
    {
        if ([self.currentType isEqualToString:@"objectbyid"])
        {
            self.currentWorkSpace.objectByIdUriTemplate = self.currentTemplate;
        }
        else if ([self.currentType isEqualToString:@"objectbypath"])
        {
            self.currentWorkSpace.objectByPathUriTemplate = self.currentTemplate;
        }
        else if ([self.currentType isEqualToString:@"typebyid"])
        {
            self.currentWorkSpace.typeByIdUriTemplate = self.currentTemplate;
        }
        else if ([self.currentType isEqualToString:@"query"])
        {
            self.currentWorkSpace.queryUriTemplate = self.currentTemplate;
        }
    } else if ([elementName isEqualToString:@"repositoryId"])
    {
        self.currentRepositoryInfo.identifier = self.currentString;
    }
    else if ([elementName isEqualToString:@"repositoryName"])
    {
        self.currentRepositoryInfo.name = self.currentString;
    }
    else if ([elementName isEqualToString:@"repositoryDescription"])
    {
        self.currentRepositoryInfo.desc = self.currentString;
    }
    else if ([elementName isEqualToString:@"vendorName"])
    {
        self.currentRepositoryInfo.vendorName = self.currentString;
    }
    else if ([elementName isEqualToString:@"productName"])
    {
        self.currentRepositoryInfo.productName = self.currentString;
    }
    else if ([elementName isEqualToString:@"productVersion"])
    {
        self.currentRepositoryInfo.productVersion = self.currentString;
    }
    else if ([elementName isEqualToString:@"rootFolderId"])
    {
        self.currentRepositoryInfo.rootFolderId = self.currentString;
    }
    else if ([elementName isEqualToString:@"cmisVersionSupported"])
    {
        self.currentRepositoryInfo.cmisVersionSupported = self.currentString;
    }
    else if ([elementName isEqualToString:@"template"])
    {
        self.currentTemplate = self.currentString;
    }
    else if ([elementName isEqualToString:@"type"])
    {
        self.currentType = self.currentString;
    }
    else if ([elementName isEqualToString:@"mediaType"])
    {
        self.currentMediaType = self.currentString;
    }

    self.currentString = nil;
}

@end
