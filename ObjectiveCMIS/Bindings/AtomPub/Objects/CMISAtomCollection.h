//
// Alfresco Focus
//
// Created by Joram Barrez
//


#import <Foundation/Foundation.h>


@interface CMISAtomCollection : NSObject

@property (nonatomic, strong) NSString *href;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *accept;
@property (nonatomic, strong) NSString *type;

@end