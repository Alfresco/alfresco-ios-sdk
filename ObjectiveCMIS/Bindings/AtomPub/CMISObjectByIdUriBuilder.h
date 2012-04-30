//
// Alfresco Focus
//
// Created by Joram Barrez
//


#import <Foundation/Foundation.h>


@interface CMISObjectByIdUriBuilder : NSObject

@property (nonatomic, strong) NSString *templateUrl;
@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) NSString *filter;
@property BOOL includeAllowableActions;
@property BOOL includePolicyIds;
@property BOOL includeRelationships;
@property BOOL includeACL;
@property (nonatomic, strong) NSString *renditionFilter;

- (id)initWithTemplateUrl:(NSString *)templateUrl;
- (NSURL *)buildUrl;

@end