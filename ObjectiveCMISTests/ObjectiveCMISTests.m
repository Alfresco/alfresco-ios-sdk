//
//  ObjectiveCMISTests.m
//  ObjectiveCMISTests
//
//  Created by Cornwell Gavin on 17/03/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectiveCMISTests.h"
#import "CMISSession.h"
#import "CMISConstants.h"
#import "CMISFolder.h"
#import "CMISDocument.h"

@implementation ObjectiveCMISTests

@synthesize parameters = _parameters;
@synthesize repositoryId = _repositoryId;
@synthesize rootFolderId = _rootFolderId;

- (void)setUp
{
    [super setUp];
    
    self.parameters = [[CMISSessionParameters alloc] initWithBindingType:CMISBindingTypeAtomPub];
    self.parameters.username = @"admin";
    self.parameters.password = @"alzheimer";
    self.parameters.atomPubUrl = [[NSURL alloc] initWithString:@"http://ec2-79-125-44-131.eu-west-1.compute.amazonaws.com/alfresco/service/api/cmis"];
    self.parameters.repositoryId = @"246b1d64-9a1f-4c56-8900-594a4b85bd05";
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testRepositories
{
    NSError *error = nil;
    NSArray *repos = [CMISSession arrayOfRepositories:self.parameters error:&error];
    STAssertNil(error, @"Error when calling arrayOfRepositories : %@", [error description]);
    STAssertNotNil(repos, @"repos object should not be nil");
    STAssertTrue(repos.count > 0, @"There should be at least one repository");
}

//- (void)testAuthenticateWithInvalidCredentials
//{
//
//}

- (void)testGetRootFolder
{

    CMISSession *session = [CMISSession sessionWithParameters:self.parameters];
    STAssertNotNil(session, @"session object should not be nil");
    
    // authenticate the session, we should use the delegate to check for success but
    // we can't in a unit test so wait for a couple of seconds then check the authenticated flag
    NSError *error = nil;
    [session authenticateAndReturnError:&error];
    STAssertTrue(session.isAuthenticated, @"session should be authenticated");
    STAssertNil(error, @"Error while authenticating session: %@", [error description]);
    
    if (session.isAuthenticated)
    {
        // make sure the repository info is available immediately after authentication
        CMISRepositoryInfo *repoInfo = session.repositoryInfo;
        STAssertNotNil(repoInfo, @"repoInfo object should not be nil");
        
        // check the repository info is what we expect
        STAssertTrue([repoInfo.productVersion rangeOfString:@"4.0.0"].length > 0, @"Product Version should be 4.0.0 (b @build-number@), but was %@", repoInfo.productVersion);
        STAssertTrue([repoInfo.vendorName isEqualToString:@"Alfresco"], @"Vendor name should be Alfresco");
        
        // retrieve the root folder
        CMISFolder *rootFolder = [session rootFolder];
        STAssertNotNil(rootFolder, @"rootFolder object should not be nil");
        NSString *rootName = rootFolder.name;
        STAssertTrue([rootName isEqualToString:@"Company Home"], @"rootName should be Company Home, but was %@", rootName);
        
        // check it was modified and created by System and the dates are not nil
        NSString *createdBy = rootFolder.createdBy;
        STAssertTrue([createdBy isEqualToString:@"System"], @"root folder should be created by System");
        
        NSString *modifiedBy = rootFolder.lastModifiedBy;
        STAssertTrue([modifiedBy isEqualToString:@"System"], @"root folder should be modified by System");
        
        NSDate *createdDate = rootFolder.creationDate;
        STAssertNotNil(createdDate, @"created date should not be nil");
        
        NSDate *modifiedDate = rootFolder.lastModificationDate;
        STAssertNotNil(modifiedDate, @"modified date should not be nil");
        
        // retrieve the children of the root folder, there should be more than 10!
        CMISCollection *childrenCollection = [rootFolder collectionOfChildrenAndReturnError:nil];
        STAssertNotNil(childrenCollection, @"childrenCollection should not be nil");
        
        NSArray *children = childrenCollection.items;
        STAssertNotNil(children, @"children should not be nil");
        NSLog(@"There are %d children", [children count]);
        STAssertTrue([children count] > 5, @"There should be at least 5 children");
    }
}

- (void)testFileDownload
{

    NSError *error = nil;
    CMISSession *session = [CMISSession sessionWithParameters:self.parameters];

    error = nil;
    [session authenticateAndReturnError:&error];
    STAssertTrue(session.isAuthenticated, @"session should be authenticated");
    STAssertNil(error, @"Error while authenticating session: %@", [error description]);

    if (session.isAuthenticated)
    {
        CMISFolder *rootFolder = [session rootFolder];
        STAssertNotNil(rootFolder, @"rootFolder object should not be nil");

        CMISCollection *childrenCollection = [rootFolder collectionOfChildrenAndReturnError:nil];
        STAssertNotNil(childrenCollection, @"childrenCollection should not be nil");

        NSArray *children = childrenCollection.items;
        STAssertNotNil(children, @"children should not be nil");
        STAssertTrue([children count] > 5, @"There should be at least 5 children");

        CMISDocument *randomDoc = nil;
        for (CMISObject *object in children)
        {
            if ([object class] == [CMISDocument class])
            {
                randomDoc = (CMISDocument *)object;
            }
        }

        STAssertNotNil(randomDoc, @"Can only continue test if root folder contains at least one document");
        NSLog(@"Fetching content stream for document %@", randomDoc.name);

        // Writing content of CMIS document to local file
        NSString *filePath = @"testfile";
        [randomDoc writeContentToFile:filePath withError:&error];
        STAssertNil(error, @"Error while writing content: %@", [error description]);

        // Assert File exists and check file length
        STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:filePath], @"File does not exist");
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
        STAssertNil(error, @"Could not verify attributes of file %@: %@", filePath, [error description]);
        STAssertTrue([fileAttributes fileSize] > 512000, @"Expected a file large than 500 kb, but found one of %d kb", [fileAttributes fileSize]/1024);

        // Nice boys clean up after themselves
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        STAssertNil(error, @"Could not remove file %@: %@", filePath, [error description]);
    }
}

@end
