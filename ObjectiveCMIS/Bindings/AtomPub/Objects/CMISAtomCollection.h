//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CMISAtomCollection : NSObject

@property (nonatomic, strong) NSString *href;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *accept;
@property (nonatomic, strong) NSString *type;

@end