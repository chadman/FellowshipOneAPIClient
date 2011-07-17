//
//  WebRequest.h
//  WSF
//
//  Created by Chad Meyer on 8/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebRequest : NSObject {

	NSURL *requestURL;
	NSURLResponse *response;
	NSURLConnection *connection;
	NSMutableData *responseData;
	NSError *error;
}

@property (nonatomic, assign) NSURL *requestURL;
@property (nonatomic, assign) NSMutableData *responseData;
@property (nonatomic, assign) NSError *error;
@property(copy) void (^storedBlock)(id);

- (void) makeWebRequest: (NSURL *)theUrl usingCallback:(void (^)(id))returnedResults;

- (id) putWebRequest:(NSURL *)theUrl withData:(NSData *)data;

- (void) putWebRequest: (NSURL *)theUrl withData: (NSData *)data usingCallback:(void (^)(id))returnedResults;

- (id) postWebRequest: (NSURL *)theUrl withData: (NSData *)data;

- (void) postWebRequest: (NSURL *)theUrl withData: (NSData *)data usingCallback:(void (^)(id))returnedResults;

- (id) makeWebRequest: (NSURL *)theUrl;

@end

