//
//  CMISRepositoryInfo.h
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 10/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMISRepositoryInfo : NSObject

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSString *rootFolderId;

@property (nonatomic, strong) NSString *cmisVersionSupported;
@property (nonatomic, strong) NSString *productName;
@property (nonatomic, strong) NSString *productVersion;
@property (nonatomic, strong) NSString *vendorName;

@end
