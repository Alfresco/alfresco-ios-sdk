//
// ObjectiveCMIS
//
// Created by Joram Barrez
//


#import <Foundation/Foundation.h>


@interface CMISObjectId : NSObject

@property (nonatomic, strong, readonly) NSString *identifier;

- (id)initWithString:(NSString *)string;

@end