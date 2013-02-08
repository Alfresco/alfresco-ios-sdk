/*
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */
#import <Foundation/Foundation.h>

@interface CMISHttpResponse : NSObject

@property NSInteger statusCode;
@property (nonatomic, strong) NSString *statusCodeMessage;
@property (nonatomic, strong, readonly) NSData *data;

+ (CMISHttpResponse *)responseUsingURLHTTPResponse:(NSHTTPURLResponse *)HTTPURLResponse andData:(NSData *)data;
+ (CMISHttpResponse *)responseWithStatusCode:(int)statusCode
                               statusMessage:(NSString *)message
                                     headers:(NSDictionary *)headers
                                responseData:(NSData *)data;

- (NSString*)exception;
- (NSString*)errorMessage;

@end
