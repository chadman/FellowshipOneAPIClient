//
//  WebRequest.m
//  WSF
//
//  Created by Chad Meyer on 8/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WebRequest.h"


@implementation WebRequest

@synthesize requestURL;
@synthesize responseData;
@synthesize error;
@synthesize storedBlock;


- (void) makeWebRequest: (NSURL *) theUrl usingCallback:(void (^)(id))returnedResults {
    
    NSLog(@"Making request to %@", theUrl);
    
    self.storedBlock = returnedResults;
	
	// Create the request 
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:theUrl];	
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	responseData = [[NSMutableData data] retain];
}

- (id) putWebRequest:(NSURL *)theUrl withData:(NSData *)data {
    
    NSLog(@"Putting request to %@", theUrl);
    
    // Create the request 
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:theUrl];
	[request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
	[request setHTTPMethod:@"PUT"];
    [request setHTTPBody:data];
	
	responseData = (NSMutableData *)[NSURLConnection sendSynchronousRequest:request
                                                          returningResponse:&response
                                                                      error:&error];
	
    if (error) {
        NSLog(@"Error occurred :: %@", error);
    }
    else {
        NSString *responseBody = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSString *requestBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"Web Request Response :: %@", responseBody);
        NSLog(@"Request :: %@", requestBody);
        [responseBody release];
        [requestBody release];
        
    }

    
    return responseData;
}


- (void) putWebRequest: (NSURL *)theUrl withData: (NSData *)data usingCallback:(void (^)(id))returnedResults {
    
    NSLog(@"Posting request to %@", theUrl);
    
    self.storedBlock = returnedResults;
    
    // Create the request 
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:theUrl];	
    [request setHTTPMethod:@"PUT"];
    [request setHTTPBody:data];
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	responseData = [[NSMutableData data] retain];
}

- (id) postWebRequest:(NSURL *)theUrl withData:(NSData *)data {

    NSLog(@"Posting request to %@", theUrl);
    
    // Create the request 
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:theUrl];
	[request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
	[request setHTTPMethod:@"POST"];
    [request setHTTPBody:data];
	
	responseData = (NSMutableData *)[NSURLConnection sendSynchronousRequest:request
                                                          returningResponse:&response
                                                                      error:&error];
	
	NSLog(@"%@", error);
    
    return responseData;
}

- (void) postWebRequest: (NSURL *)theUrl withData: (NSData *)data usingCallback:(void (^)(id))returnedResults {
    
    NSLog(@"Posting request to %@", theUrl);
    
    self.storedBlock = returnedResults;
    
    // Create the request 
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:theUrl];	
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:data];
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	responseData = [[NSMutableData data] retain];
}

- (id) makeWebRequest: (NSURL *)theUrl {
	
    NSLog(@"Making request to %@", theUrl);
    
	// Create the request 
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:theUrl];
	[request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
	[request setHTTPMethod:@"GET"];
	
	responseData = (NSMutableData *)[NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
	if (error) {
        NSLog(@"Error occurred :: %@", error);
    }
    else {
        NSString *responseBody = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSLog(@"Web Request Response :: %@", responseBody);
        [responseBody release];
        
    }
    
    return responseData;
}

- (void) dealloc {
	
	connection = nil;
	self.requestURL = nil;
	response = nil;
	self.responseData = nil;
	self.error = nil;
    self.storedBlock = nil;
    
    [connection release];
    [requestURL release];
    [responseData release];
    [error release];
    [storedBlock release];


	[super dealloc];
}


#pragma mark NSURLConnection methods

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)aResponse {
	if (response)
		[response release];
	response = [aResponse retain];
	[responseData setLength:0];
}

- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)data {
	[responseData appendData:data];
	
	int statusCode = [((NSHTTPURLResponse *)response) statusCode];
   
	if (statusCode >= 400) {
			[connection cancel];  // stop connecting; no more delegate messages
			NSDictionary *errorInfo = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:
											  NSLocalizedString(@"Server returned status code %d",@""),
											  statusCode]
									  forKey:NSLocalizedDescriptionKey];
        NSError *statusError = [NSError errorWithDomain:@"dontknow"
							  code:statusCode
						  userInfo:errorInfo];
        [self connection:connection didFailWithError:statusError];
    }
}

- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)webError {
    self.storedBlock(webError);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection {
    
    self.storedBlock(responseData);

	[connection release];
	[responseData release];
}


@end
