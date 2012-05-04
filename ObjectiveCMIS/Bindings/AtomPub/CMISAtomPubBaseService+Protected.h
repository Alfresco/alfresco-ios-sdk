//
//  CMISAtomPubBaseService+Protected.h
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 04/05/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMISAtomPubBaseService (Protected)

- (NSArray *)retrieveCMISWorkspacesWithError:(NSError * *)error;

- (CMISObjectData *)retrieveObjectInternal:(NSString *)objectId error:(NSError **)error;

- (NSData *)executeRequest:(NSURL *)url error:(NSError **)outError;

@end
