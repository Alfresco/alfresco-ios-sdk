//
// Alfresco Focus
//
// Created by Joram Barrez
//


#import "CMISObjectId.h"


@interface  CMISObjectId ()
@property (nonatomic, strong, readwrite) NSString *identifier;
@end

@implementation CMISObjectId

@synthesize identifier = _identifier;

- (id)initWithString:(NSString *)string
{
    self = [super init];
    if (self)
    {
        self.identifier = string;
    }

    return self;
}

@end