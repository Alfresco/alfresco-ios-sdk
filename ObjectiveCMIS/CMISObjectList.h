//
// Alfresco Focus
//
// Created by Joram Barrez
//


#import <Foundation/Foundation.h>


// Class to hold the result of executing a query
@interface CMISObjectList : NSObject

/**
 * Array of CMISObjectData, representing a result of some query
 */
@property (nonatomic, strong) NSArray *objects;

/**
* TRUE if the Repository contains additional items after those contained in the response.
* FALSE otherwise. If TRUE, a request with a larger skipCount or larger maxItems is expected
* to return additional results (unless the contents of the repository has changed).
*
* TODO: not yet exposed --> how to represent that the property was not in the returned feed? Wrap it in an object?
*/
//@property BOOL hasMoreItems;

/**
 * If the repository knows the total number of items in a result set, the repository SHOULD include the number here.
 * If the repository does not know the number of items in a result set, this parameter SHOULD not be set.
 * The value in the parameter MAY NOT be accurate the next time the client retrieves the result set
 * or the next page in the result set.
*/
@property NSInteger numItems;

@end