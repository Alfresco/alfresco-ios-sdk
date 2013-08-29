//
//  AlfrescoWorkflowUtils.m
//  AlfrescoSDK
//
//  Created by Tauseef Mughal on 13/08/2013.
//
//

#import "AlfrescoWorkflowUtils.h"
#import "AlfrescoInternalConstants.h"

@implementation AlfrescoWorkflowUtils

+ (NSString *)prefixForActivitiEngineType:(AlfrescoWorkflowEngineType)engineType
{
    NSString *returnString = nil;
    switch (engineType)
    {
        case AlfrescoWorkflowEngineTypeJBPM:
        {
            returnString = kAlfrescoWorkflowJBPMEnginePrefix;
        }
        break;
            
        case AlfrescoWorkflowEngineTypeActiviti:
        {
            returnString = kAlfrescoWorkflowActivitiEnginePrefix;
        }
        break;
            
        default:
            break;
    }
    return returnString;
}

+ (NSString *)nodeGUIDFromNodeIdentifier:(NSString *)nodeIdentifier
{
    NSString *nodeGUID = [nodeIdentifier stringByReplacingOccurrencesOfString:kAlfrescoWorkflowNodeRefPrefix withString:@""];
    NSRange range = [nodeGUID rangeOfString:@";" options:NSBackwardsSearch];
    nodeGUID = [nodeGUID substringToIndex:range.location];
    
    return nodeGUID;
}

@end
