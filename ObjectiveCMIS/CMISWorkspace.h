//
// Alfresco Focus
//
// Created by Joram Barrez
//


#import <Foundation/Foundation.h>

@class CMISRepositoryInfo;
@class CMISSessionParameters;

@interface CMISWorkspace : NSObject

@property (nonatomic, strong) CMISSessionParameters *sessionParameters;
@property (nonatomic, strong) CMISRepositoryInfo *repositoryInfo;

@property (nonatomic, strong) NSString *objectByIdUriTemplate;
@property (nonatomic, strong) NSString *objectByPathUriTemplate;
@property (nonatomic, strong) NSString *typeByIdUriTemplate;
@property (nonatomic, strong) NSString *queryUriTemplate;

@end