//
// ObjectiveCMIS
//
// Created by Joram Barrez
//


#import <Foundation/Foundation.h>

@class CMISRepositoryInfo;
@class CMISSessionParameters;
@class CMISLinkRelations;

@interface CMISWorkspace : NSObject

@property (nonatomic, strong) CMISSessionParameters *sessionParameters;
@property (nonatomic, strong) CMISRepositoryInfo *repositoryInfo;

/**
* An array containing the parsed CMISAtomCollections.
*/
@property (nonatomic, strong) NSMutableArray *collections;

/**
 * An array of CMISAtomLink objects for the workspace
 */
@property (nonatomic, strong) CMISLinkRelations *linkRelations;

@property (nonatomic, strong) NSString *objectByIdUriTemplate;
@property (nonatomic, strong) NSString *objectByPathUriTemplate;
@property (nonatomic, strong) NSString *typeByIdUriTemplate;
@property (nonatomic, strong) NSString *queryUriTemplate;

/**
 * Returns the href link for a collection defined with the given type.
  * Returns nil if none is found.
 */
- (NSString *)collectionHrefForCollectionType:(NSString *)collectionType;

@end