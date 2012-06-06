//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CMISRenditionData : NSObject

/**  Identifies the rendition stream. */
@property (nonatomic, strong) NSString *streamId;

/** The MIME type of the rendition stream. */
@property (nonatomic, strong) NSString *mimeType;

/** Human readable information about the rendition (optional). */
@property (nonatomic, strong) NSString *title;

/** A categorization String associated with the rendition (optional). */
@property (nonatomic, strong) NSString *kind;

/** The length of the rendition stream in bytes (optional). */
@property (nonatomic, strong) NSNumber *length;

/** Typically used for 'image' renditions (expressed as pixels). SHOULD be present if kind = cmis:thumbnail (optional). */
@property (nonatomic, strong) NSNumber *height;

/** Typically used for 'image' renditions (expressed as pixels). SHOULD be present if kind = cmis:thumbnail. */
@property (nonatomic, strong) NSNumber *width;

/**
*  If specified, then the rendition can also be accessed as a document object in the CMIS services.
*  If not set, then the rendition can only be accessed via the rendition services. Referential integrity of this ID is repository-specific.
*
* TODO: needs to be changed to more generic 'ObjectId'
*/
@property (nonatomic, strong) NSString *renditionDocumentId;

- (id)initWithRenditionData:(CMISRenditionData *)renditionData;

@end