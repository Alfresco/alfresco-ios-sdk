//
//  AlfrescoWorkflowUtils.h
//  AlfrescoSDK
//
//  Created by Tauseef Mughal on 13/08/2013.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, AlfrescoWorkflowEngineType)
{
    AlfrescoWorkflowEngineTypeUnknown,
    AlfrescoWorkflowEngineTypeJBPM,
    AlfrescoWorkflowEngineTypeActiviti
};

@interface AlfrescoWorkflowUtils : NSObject

+ (NSString *)prefixForActivitiEngineType:(AlfrescoWorkflowEngineType)engineType;
+ (NSString *)nodeGUIDFromNodeIdentifier:(NSString *)nodeIdentifier;

@end
