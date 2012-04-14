//
//  CMISFolder.h
//  HybridApp
//
//  Created by Cornwell Gavin on 21/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISFileableObject.h"
#import "CMISCollection.h"

@interface CMISFolder : CMISFileableObject

- (CMISCollection *)collectionOfChildrenAndReturnError:(NSError *)error;

@end


