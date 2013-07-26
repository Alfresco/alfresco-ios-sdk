/*******************************************************************************
 * Copyright (C) 2005-2013 Alfresco Software Limited.
 *
 * This file is part of the Alfresco Mobile SDK.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 ******************************************************************************/

/* A Copy of STAssertTrue that references "weakSelf" in place of "self" to avoid block retain cycle issues
 
 " Generates a failure when expression evaluates to false.
 _{expr    The expression that is tested.}
 _{description A format string as in the printf() function. Can be nil or
 an empty string but must be present.}
 _{... A variable number of arguments to the format string. Can be absent.}
 "*/
#define STAssertTrueWeakSelf(expr, description, ...) \
do { \
    BOOL _evaluatedExpression = (expr);\
    if (!_evaluatedExpression) {\
        NSString *_expression = [NSString stringWithUTF8String:#expr];\
        [weakSelf failWithException:([NSException failureInCondition:_expression \
            isTrue:NO \
            inFile:[NSString stringWithUTF8String:__FILE__] \
            atLine:__LINE__ \
            withDescription:@"%@", STComposeString(description, ##__VA_ARGS__)])]; \
    } \
} while (0)


/* A Copy of STAssertFalse that references "weakSelf" in place of "self" to avoid block retain cycle issues
 
 "Generates a failure when the expression evaluates to true.
 _{expr    The expression that is tested.}
 _{description A format string as in the printf() function. Can be nil or
 an empty string but must be present.}
 _{... A variable number of arguments to the format string. Can be absent.}
 "*/
#define STAssertFalseWeakSelf(expr, description, ...) \
do { \
    BOOL _evaluatedExpression = (expr);\
    if (_evaluatedExpression) {\
        NSString *_expression = [NSString stringWithUTF8String:#expr];\
        [weakSelf failWithException:([NSException failureInCondition:_expression \
            isTrue:YES \
            inFile:[NSString stringWithUTF8String:__FILE__] \
            atLine:__LINE__ \
            withDescription:@"%@", STComposeString(description, ##__VA_ARGS__)])]; \
    } \
} while (0)


/* A Copy of STAssertNotNil that references "weakSelf" in place of "self" to avoid block retain cycle issues
 
 " Generates a failure when a1 is nil.
 _{a1    An object.}
 _{description A format string as in the printf() function. Can be nil or
 an empty string but must be present.}
 _{... A variable number of arguments to the format string. Can be absent.}
 "*/
#define STAssertNotNilWeakSelf(a1, description, ...) \
do { \
    @try {\
        id a1value = (a1); \
        if (a1value == nil) { \
            NSString *_a1 = [NSString stringWithUTF8String:#a1]; \
            NSString *_expression = [NSString stringWithFormat:@"((%@) != nil)", _a1]; \
            [weakSelf failWithException:([NSException failureInCondition:_expression \
                isTrue:NO \
                inFile:[NSString stringWithUTF8String:__FILE__] \
                atLine:__LINE__ \
                withDescription:@"%@", STComposeString(description, ##__VA_ARGS__)])]; \
        } \
    }\
    @catch (id anException) {\
        [weakSelf failWithException:([NSException failureInRaise:[NSString stringWithFormat:@"(%s) != nil fails", #a1] \
            exception:anException \
            inFile:[NSString stringWithUTF8String:__FILE__] \
            atLine:__LINE__ \
            withDescription:@"%@", STComposeString(description, ##__VA_ARGS__)])]; \
    }\
} while(0)
