//
//  ObjectiveCMISTests.m
//  ObjectiveCMISTests
//
//  Created by Cornwell Gavin on 17/03/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "ObjectiveCMISTests.h"
#import "CMISSession.h"
#import "CMISConstants.h"
#import "CMISFolder.h"

@implementation ObjectiveCMISTests

@synthesize parameters = _parameters;
@synthesize repositoryId = _repositoryId;
@synthesize rootFolderId = _rootFolderId;

- (void)setUp
{
    [super setUp];
    
    self.parameters = [[CMISSessionParameters alloc] initWithBindingType:CMISBindingTypeAtomPub];
    
    self.parameters.username = @"admin";
    self.parameters.password = @"admin";
    
    self.parameters.atomPubUrl = [[NSURL alloc] initWithString:@"http://cmis.alfresco.com/service/cmis"];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testRepositories
{
    NSArray *repos = [CMISSession arrayOfRepositories:self.parameters error:nil];
    STAssertNotNil(repos, @"repos object should not be nil");
    
    for (CMISRepositoryInfo *repo in repos) 
    {
        NSLog(@"Repository ID: %@", [repo identifier]);
        
        // remember the last repository id
        self.repositoryId = repo.identifier; 
    }
}

- (void)testRootFolder
{
    // TODO: find a way to pass values between test runs
    //self.parameters.repositoryId = self.repositoryId;
    self.parameters.repositoryId = @"371554cd-ac06-40ba-98b8-e6b60275cca7";
    
    CMISSession *session = [CMISSession sessionWithParameters:self.parameters];
    STAssertNotNil(session, @"session object should not be nil");
    
    // authenticate the session, we should use the delegate to check for success but
    // we can't in a unit test so wait for a couple of seconds then check the authenticated flag
    [session authenticateWithDelegate:nil];
    sleep(2);
    STAssertTrue(session.isAuthenticated, @"session should be authenticated");
    
    if (session.isAuthenticated)
    {
        // make sure the repository info is available immediately after authentication
        CMISRepositoryInfo *repoInfo = session.repositoryInfo;
        STAssertNotNil(repoInfo, @"repoInfo object should not be nil");
        
        // check the repository info is what we expect
        STAssertTrue([repoInfo.productVersion isEqualToString:@"4.0.0 (b @build-number@)"], @"Product Version should be 4.0.0 (b @build-number@)");
        STAssertTrue([repoInfo.vendorName isEqualToString:@"Alfresco"], @"Vendor name should be Alfresco");
        
        // retrieve the root folder
        CMISFolder *rootFolder = [session rootFolder];
        STAssertNotNil(rootFolder, @"rootFolder object should not be nil");
        NSString *rootName = rootFolder.name;
        STAssertTrue([rootName isEqualToString:@"Company Home"], @"rootName should be Company Home");
        
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
        STAssertTrue([children count] > 10, @"There should be at least 10 children");
        
        for (CMISObject *object in children) 
        {
            NSLog(@"%@", object.name);
        }
    }
}

@end
