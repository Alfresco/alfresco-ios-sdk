/*******************************************************************************
 * Copyright (C) 2005-2020 Alfresco Software Limited.
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


#define _XCTRegisterFailureWeakSelf(condition, format...) \
({ \
    _XCTFailureHandler(weakSelf, YES, __FILE__, __LINE__, condition, @"" format); \
})



/* A Copy of XCTAssertTrue that references "weakSelf" in place of "self" to avoid block retain cycle issues */

/// \def XCTAssertTrueWeakSelf(expression, format...)
/// \brief Generates a failure when expression evaluates to false.
/// \param expression The expression that is tested.
/// \param format An NSString object that contains a printf-style string containing an error message describing the failure condition and placeholders for the arguments.
/// \param ... The arguments displayed in the format string.
#define XCTAssertTrueWeakSelf(expression, format...) \
    _XCTPrimitiveAssertTrueWeakSelf(expression, ## format)

#define _XCTPrimitiveAssertTrueWeakSelf(expression, format...) \
({ \
    @try { \
        BOOL _evaluatedExpression = !!(expression); \
        if (!_evaluatedExpression) { \
        _XCTRegisterFailureWeakSelf(_XCTFailureDescription(_XCTAssertion_True, 0, @#expression),format); \
        } \
    } \
    @catch (id exception) { \
        _XCTRegisterFailureWeakSelf(_XCTFailureDescription(_XCTAssertion_True, 1, @#expression, [exception reason]),format); \
    }\
})


/* A Copy of XCTAssertFalse that references "weakSelf" in place of "self" to avoid block retain cycle issues */

/// \def XCTAssertFalseWeakSelf(expression, format...)
/// \brief Generates a failure when the expression evaluates to true.
/// \param expression The expression that is tested.
/// \param format An NSString object that contains a printf-style string containing an error message describing the failure condition and placeholders for the arguments.
/// \param ... The arguments displayed in the format string.
#define XCTAssertFalseWeakSelf(expression, format...) \
    _XCTPrimitiveAssertFalseWeakSelf(expression, ## format)

#define _XCTPrimitiveAssertFalseWeakSelf(expression, format...) \
({ \
    @try { \
        BOOL _evaluatedExpression = !!(expression); \
        if (_evaluatedExpression) { \
            _XCTRegisterFailureWeakSelf(_XCTFailureDescription(_XCTAssertion_False, 0, @#expression),format); \
        } \
    } \
    @catch (id exception) { \
        _XCTRegisterFailureWeakSelf(_XCTFailureDescription(_XCTAssertion_False, 1, @#expression, [exception reason]),format); \
    }\
})


/* A Copy of XCTAssertNotNil that references "weakSelf" in place of "self" to avoid block retain cycle issues */

/// \def XCTAssertNotNilWeakSelf(a1, format...)
/// \brief Generates a failure when a1 is nil.
/// \param a1 The object that is tested.
/// \param format An NSString object that contains a printf-style string containing an error message describing the failure condition and placeholders for the arguments.
/// \param ... The arguments displayed in the format string.
#define XCTAssertNotNilWeakSelf(a1, format...) \
    _XCTPrimitiveAssertNotNilWeakSelf(a1, ## format)

#define _XCTPrimitiveAssertNotNilWeakSelf(a1, format...) \
({ \
    @try { \
        id a1value = (a1); \
        if (a1value == nil) { \
            _XCTRegisterFailureWeakSelf(_XCTFailureDescription(_XCTAssertion_NotNil, 0, @#a1),format); \
        } \
    }\
    @catch (id exception) { \
        _XCTRegisterFailureWeakSelf(_XCTFailureDescription(_XCTAssertion_NotNil, 1, @#a1, [exception reason]),format); \
    }\
})
