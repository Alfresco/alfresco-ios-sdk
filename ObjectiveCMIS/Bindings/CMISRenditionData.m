//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISRenditionData.h"


@implementation CMISRenditionData

@synthesize streamId = _streamId;
@synthesize mimeType = _mimeType;
@synthesize title = _title;
@synthesize kind = _kind;
@synthesize length = _length;
@synthesize height = _height;
@synthesize width = _width;
@synthesize renditionDocumentId = _renditionDocumentId;

- (id)initWithRenditionData:(CMISRenditionData *)renditionData
{
    self = [super init];
    if (self)
    {
        self.streamId = renditionData.streamId;
        self.mimeType = renditionData.mimeType;
        self.title = renditionData.title;
        self.kind = renditionData.kind;
        self.length = renditionData.length;
        self.height = renditionData.height;
        self.width = renditionData.width;
        self.renditionDocumentId = renditionData.renditionDocumentId;
    }
    return self;
}


@end