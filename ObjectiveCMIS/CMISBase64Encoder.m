//
//  AlfrescoBase64Encoder.m
//  RemoteAPI
//
//  Created by Tijs Rademakers on 02/05/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISBase64Encoder.h"

static char *alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

@implementation CMISBase64Encoder

+(NSString *)encode:(NSData *)plainText 
{
    int encodedLength = (4 * (([plainText length] / 3) + (1 - (3 - ([plainText length] % 3)) / 3))) + 1;
    char *outputBuffer = malloc(encodedLength);
    unsigned char *inputBuffer = (unsigned char *)[plainText bytes];

    NSInteger i;
    NSInteger j = 0;
    int remain;

    for(i = 0; i < [plainText length]; i += 3) {
        remain = [plainText length] - i;
        
        outputBuffer[j++] = alphabet[(inputBuffer[i] & 0xFC) >> 2];
        outputBuffer[j++] = alphabet[((inputBuffer[i] & 0x03) << 4) | 
                                     ((remain > 1) ? ((inputBuffer[i + 1] & 0xF0) >> 4): 0)];
        
        if(remain > 1)
            outputBuffer[j++] = alphabet[((inputBuffer[i + 1] & 0x0F) << 2)
                                         | ((remain > 2) ? ((inputBuffer[i + 2] & 0xC0) >> 6) : 0)];
        else 
            outputBuffer[j++] = '=';
        
        if(remain > 2)
            outputBuffer[j++] = alphabet[inputBuffer[i + 2] & 0x3F];
        else
            outputBuffer[j++] = '=';			
    }

    outputBuffer[j] = 0;

    NSString *result = [NSString stringWithCString:outputBuffer encoding:NSASCIIStringEncoding];
    free(outputBuffer);

    return result;
}

@end
