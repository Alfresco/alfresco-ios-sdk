//
//  CMISAtomPubBaseService.h
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 10/04/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISSessionParameters.h"

@class CMISWorkspace;

@interface CMISAtomPubBaseService : NSObject

@property (nonatomic, strong, readonly) CMISSessionParameters *sessionParameters;
@property (nonatomic, strong, readonly) NSArray *cmisWorkspaces;

- (id)initWithSessionParameters:(CMISSessionParameters *)sessionParameters andWithCMISWorkspaces:(NSArray *)cmisWorkspaces;

- (NSData *)executeRequest:(NSURL *)url error:(NSError **)outError;

@end
