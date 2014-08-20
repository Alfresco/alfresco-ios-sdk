/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import <Foundation/Foundation.h>

/**
 * CMISQueryStatement.
 * Sample code:
 *
 * CMISQueryStatement *qs =
 *   [[CMISQueryStatement alloc] initWithStatement:@"SELECT ?, ? FROM ? WHERE ? > ? AND IN_FOLDER(?) OR ? IN (?)"];
 *
 * [qs setPropertyAtIndex:1 property:@"cmis:document"];
 * [qs setPropertyAtIndex:2 property:@"cmis:name"];
 * [qs setTypeAtIndex:3 type:@"cmis:document"];
 *
 * [qs setPropertyAtIndex:4 property:@"cmis:creationDate];
 * [qs setDateAtIndex:5 date:creationDate];
 *
 * [qs setStringAtIndex:6 string:cmisDocument.identifier];
 *
 * [qs setPropertyAtIndex:7 property:@"cmis:createdBy];
 * [qs setStringAtIndex:4 string:@"8, bob, tom, lisa"];
 *
 * NSString *statement = [qs queryString];
 */
@interface CMISQueryStatement : NSObject

/**
 * Initialize Query Statement. Use ? to define placeholders
 *
 * @param statement 
            THe SQL statement
 */
- (id)initWithStatement:(NSString*)statement;

/**
 * Sets the designated parameter to the query name of the given type.
 *
 * @param parameterIndex
 *            the parameter index (one-based)
 * @param type
 *            the object type
 */
- (void)setTypeAtIndex:(NSUInteger)parameterIndex type:(NSString*)type;

/**
 * Sets the designated parameter to the query name of the given property.
 *
 * @param parameterIndex
 *            the parameter index (one-based)
 * @param propertyId
 *            the property ID
 */
- (void)setPropertyAtIndex:(NSUInteger)parameterIndex property:(NSString*)property;

/**
 * Sets the designated parameter to the given string.
 *
 * @param parameterIndex
 *            the parameter index (one-based)
 * @param string
 *            the string
 */
- (void)setStringAtIndex:(NSUInteger)parameterIndex string:(NSString*)string;

/**
 * Sets the designated parameter to the given string. It does not escape
 * backslashes ('\') in front of '%' and '_'.
 *
 * @param parameterIndex
 *            the parameter index (one-based)
 * @param string
 *            the LIKE string
 */
- (void)setStringLikeAtIndex:(NSUInteger)parameterIndex string:(NSString*)string;

/**
 * Sets the designated parameter to the given string in a CMIS contains
 * statement.
 * <p>
 * Note that the CMIS specification requires two levels of escaping. The
 * first level escapes ', ", \ characters to \', \" and \\. The characters
 * *, ? and - are interpreted as text search operators and are not escaped
 * on first level. If *, ?, - shall be used as literals, they must be passed
 * escaped with \*, \? and \- to this method.
 * <p>
 * For all statements in a CONTAINS() clause it is required to isolate those
 * from a query statement. Therefore a second level escaping is performed.
 * On the second level grammar ", ', - and \ are escaped with a \. See the
 * spec for further details.
 * <p>
 * Summary (input --> first level escaping --> second level escaping and
 * output): * --> * --> * ? --> ? --> ? - --> - --> - \ --> \\ --> \\\\ (for
 * any other character following other than * ? -) \* --> \* --> \\* \? -->
 * \? --> \\? \- --> \- --> \\- ' --> \' --> \\\' " --> \" --> \\\"
 *
 * @param parameterIndex
 *            the parameter index (one-based)
 * @param string
 *            the CONTAINS string
 */
- (void)setStringContainsAtIndex:(NSUInteger)parameterIndex string:(NSString*)string;

/**
 * Sets the designated parameter to the given number.
 *
 * @param parameterIndex
 *            the parameter index (one-based)
 * @param number
 *            the number
 */
- (void)setNumberAtIndex:(NSUInteger)parameterIndex number:(NSNumber*)number;

/**
 * Sets the designated parameter to the given URL.
 *
 * @param parameterIndex
 *            the parameter index (one-based)
 * @param url
 *            the URL
 */
- (void)setUrlAtIndex:(NSUInteger)parameterIndex url:(NSURL*)url;

/**
 * Sets the designated parameter to the given boolean.
 *
 * @param parameterIndex
 *            the parameter index (one-based)
 * @param boolean
 *            the boolean
 */
- (void)setBooleanAtIndex:(NSUInteger)parameterIndex boolean:(BOOL)boolean;

/**
 * Sets the designated parameter to the given DateTime value with the prefix
 * 'TIMESTAMP '.
 *
 * @param parameterIndex
 *            the parameter index (one-based)
 * @param date
 *            the DateTime value as NSDate object
 */
- (void)setDateTimeAtIndex:(NSUInteger)parameterIndex date:(NSDate*)date;


/**
 * Returns the query statement.
 *
 * @return the query statement
 */
- (NSString*)queryString;

@end
