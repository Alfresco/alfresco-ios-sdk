//
//  CMISConstants.h
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 15/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>

// Properties
extern NSString * const kCMISPropertyObjectId;
extern NSString * const kCMISPropertyName;
extern NSString * const kCMISPropertyCreatedBy;
extern NSString * const kCMISPropertyCreationDate;
extern NSString * const kCMISPropertyModifiedBy;
extern NSString * const kCMISPropertyModificationDate;
extern NSString * const kCMISProperyContentStreamId;
extern NSString * const kCMISPropertyContentStreamFileName;
extern NSString * const kCMISPropertyContentStreamLength;
extern NSString * const kCMISPropertyContentStreamMediaType;
extern NSString * const kCMISPropertyObjectTypeId;
extern NSString * const kCMISPropertyVersionSeriesId;
extern NSString * const kCMISPropertyVersionLabel;
extern NSString * const kCMISPropertyIsLatestVersion;
extern NSString * const kCMISPropertyIsMajorVersion;
extern NSString * const kCMISPropertyIsLatestMajorVersion;

// Property values
extern NSString * const kCMISPropertyObjectTypeIdValueDocument;
extern NSString * const kCMISPropertyObjectTypeIdValueFolder;

// Session cache keys

extern NSString * const kCMISSessionKeyWorkspaces;
