//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CMISTypeByIdUriBuilder : NSObject

@property (nonatomic, strong) NSString *id;

- (id)initWithTemplateUrl:(NSString *)templateUrl;
- (NSURL *)buildUrl;

@end