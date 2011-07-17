//
//  FTOAuth.m
//  Fellowship
//
//  Created by Chad Meyer on 4/29/09.
//  Copyright 2009 Fellowship Tech. All rights reserved.
//

#import "FTOAuth.h"
#import "FTUserDefaults.h"
#import "JSON.h"
#import "FellowshipOneAPIUtility.h"
#import "OAuthConsumer.h"
#import "ConsoleLog.h"
#import "Constants.h"


@interface FTOAuth (Private)

// Turns the HTTPMethod enum into a string
- (NSString *) getHTTPMethodString:(HTTPMethod)method;

// Turns the enum FTAPIRealm into a string
- (NSString *) getAPIRealmString:(FTAPIRealm)realm;

// Fetches an api url based on the suffix and the realm
- (NSURL *) fetchFTAPIURL: (NSString *)URLSuffix forRealm: (FTAPIRealm) realm;

// Constructs the url string for the fellowship one api
- (NSString *)APIURIForRealm: (FTAPIRealm)realm;

// Authenicate the user, making it a private method because the authentication can be for portal user or weblink user
- (void) authenticateUser:(NSString *)userName withPassword:(NSString *)password userType: (NSString *)userType;

- (void) callFTAPIWithURL:(NSURL *)url withHTTPMethod:(HTTPMethod)method withData:(NSData *)data;

int encode(unsigned s_len, char *src, unsigned d_len, char *dst);

@end


@implementation FTOAuth

@synthesize ftOAuthResult;
@synthesize storedBlock;

- (id) fetcher {
	return _fetcher;
}

- (void) setFetcher:(id)value {
	_fetcher = value;
}

// Getter for the delegate
- (id)delegate {
	return parentDelegate;
}

// setter for the delegate
- (void) setDelegate: (id)newDelegate {
	parentDelegate = newDelegate;
}

- (NSString *) domainBaseURL {

	return [self APIURIForRealm:FTAPIRealmBase];
}

// Initialize with a delegate
- (id) initWithDelegate: (id)delegate {
    
    self = [super init];

	if (self) {
		self.delegate = delegate;
		self.ftOAuthResult = [[FTOAuthResult alloc] init];
	}
	
	return self;
}

#if NS_BLOCKS_AVAILABLE
- (void)authenticatePortalUser: (NSString *)userName password: (NSString *)password usingBlock:(void (^)(id))block {
    
    self.storedBlock = block;
    [self authenticateUser:userName withPassword:password userType:@"PortalUser"];
}

- (void)authenticateWeblinkUser: (NSString *)userName password: (NSString *)password usingBlock:(void (^)(id))block {
    self.storedBlock = block;
    [self authenticateUser:userName withPassword:password userType:@"WeblinkUser"];
}

- (void) callFTAPIWithURLSuffix:(NSString *)URLSuffix forRealm: (FTAPIRealm)realm withHTTPMethod:(HTTPMethod)method withData:(NSData *)data usingBlock:(void (^)(id))block {
	
    self.storedBlock = block;
    [self callFTAPIWithURL:[self fetchFTAPIURL:URLSuffix forRealm:realm] withHTTPMethod:method withData:data];
}

- (void) callFTAPIWithURL:(NSString *)theUrl withHTTPMethod:(HTTPMethod)method withData:(NSData *)data usingBlock:(void (^)(id))block {
    
    self.storedBlock = block;
    [self callFTAPIWithURL:[NSURL URLWithString:theUrl] withHTTPMethod:method withData:data];
   
}
#endif


// Authenticates the user 
- (void)authenticateUser: (NSString *)userName 
			withPassword: (NSString *)password 
		  withChurchCode: (NSString *)churchCode 
				delegate: (id)aDelegate
		  finishSelector: (SEL)aFinishSelector
			failSelector: (SEL)aFailSelector
{

	parentDelegate = aDelegate;
	didFinishSelector = aFinishSelector;
	didFailSelector = aFailSelector;
	
	// set the church code for future use
	[[FTUserDefaults sharedInstance] setChurchCode:churchCode];

	// Create an OAConsumer object
	OAConsumer *oaConsumer = [[OAConsumer alloc] 
							  initWithKey: [self consumerKey]
							  secret:[self consumerSecret]];
	
	// Authenticating the user in this scenario will require having the acess token url, get it now
	NSURL *accessTokenURL = [self fetchFTAPIURL:@"PortalUser/AccessToken" forRealm:FTAPIRealmBase];

	// Encode the username and password with 64 bit encoding
	NSMutableString *userCreds = [NSMutableString stringWithString:userName];
	[userCreds appendString:@" "];
	[userCreds appendString:password];
	
	// Encode the user name and password
	NSData *encodeData = [userCreds dataUsingEncoding:NSUTF8StringEncoding];
	char encodeArray[512];	
	memset(encodeArray, '\0', sizeof(encodeArray));
	
	// Base64 Encode username and password
	encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);
	userCreds = [NSString stringWithCString:encodeArray encoding:NSUTF8StringEncoding];
	NSString *encodedUserCreds = [NSString stringWithFormat:@"ec=%@", [userCreds stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];

	OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:accessTokenURL
                                                                   consumer:oaConsumer
                                                                      token:nil   // we don't have a Token yet
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA1
    // Set the request to a POST for access token
	[request setHTTPMethod:@"POST"];
	
	// Set the body to be the encoded username and password
	[request setHTTPBody: [encodedUserCreds dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
	[request setValue:@"application/xml" forHTTPHeaderField:@"Content-Type"]; 
	

	if (self.fetcher) {
		[self.fetcher release];
	}
	
	// Fetch the data associated with the request		
	self.fetcher = [[OAAsynchronousDataFetcher alloc] initWithRequest:request 
														delegate:self 
											   didFinishSelector:@selector(accessTokenSucceed: withData:) 
												 didFailSelector:@selector(accessTokenFail: withData:)];
	
	// release the objects
	[request release];
	[oaConsumer release];

	// Start the fetch
	[self.fetcher start];
}

- (void) requestAccessToken: (NSString *)churchCode
				  delegate: (id)aDelegate
			finishSelector: (SEL)aFinishSelector
			  failSelector: (SEL)aFailSelector {
	
	parentDelegate = aDelegate;
	didFinishSelector = aFinishSelector;
	didFailSelector = aFailSelector;

	// Create an OAConsumer object
	OAConsumer *oaConsumer = [[[OAConsumer alloc] 
							   initWithKey:[self consumerKey] 
							   secret:[self consumerSecret]] autorelease];
	
	// Create an OAToken to pass to the methods
	OAToken *oaToken = [[OAToken alloc]
						initWithKey:[[FTUserDefaults sharedInstance] accessToken] 
						secret:[[FTUserDefaults sharedInstance] accessTokenSecret]];
	
	// Authenticating the user in this scenario will require having the acess token url, get it now
	NSURL *accessTokenURL = [self fetchFTAPIURL:@"Tokens/AccessToken" forRealm:FTAPIRealmBase];

	
	OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:accessTokenURL
																   consumer:oaConsumer
																	  token:oaToken   
																	  realm:nil   
														  signatureProvider:nil];
	
	[request setHTTPMethod:[self getHTTPMethodString:HTTPMethodPOST]];
	[request setValue:@"application/xml" forHTTPHeaderField:@"Content-Type"];
	
	if (self.fetcher) {
		[self.fetcher release];
	}
	
	
	// Fetch the data associated with the request		
	self.fetcher = [[OAAsynchronousDataFetcher alloc] initWithRequest:request 
															 delegate:self 
													didFinishSelector:@selector(accessTokenSucceed: withData:) 
													  didFailSelector:@selector(accessTokenFail: withData:)];
	
	// Release objects
	[oaToken release];
	[request release];
	
	// Start the async fetcher
	[self.fetcher start];

}

- (void) fetchRequestToken: (NSString *)churchCode
				  delegate: (id)aDelegate
			finishSelector: (SEL)aFinishSelector
			  failSelector: (SEL)aFailSelector {
	
	
	parentDelegate = aDelegate;
	didFinishSelector = aFinishSelector;
	didFailSelector = aFailSelector;
	
	// Set the church code and save it
	[[FTUserDefaults sharedInstance] setChurchCode:churchCode];
	
	// Create an OAConsumer object
	OAConsumer *oaConsumer = [[OAConsumer alloc] 
							  initWithKey:[self consumerKey] 
							  secret:[self consumerSecret]];
	
	// Authenticating the user in this scenario will require having the acess token url, get it now
	NSURL *requestTokenURL = [self fetchFTAPIURL:@"Tokens/RequestToken" forRealm:FTAPIRealmBase];
	
	OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:requestTokenURL
                                                                   consumer:oaConsumer
                                                                      token:nil   // we don't have a Token yet
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA1
    // Set the request to a POST for access token
	[request setHTTPMethod:@"POST"];
	
	// Set the body to be the encoded username and password
	[request setValue:@"application/xml" forHTTPHeaderField:@"Content-Type"]; 
	
	// Fetch the data associated with the request	
	self.fetcher = [[OAAsynchronousDataFetcher alloc] initWithRequest:request 
															 delegate:self 
													didFinishSelector:@selector(requestTokenSucceed: withData:) 
													  didFailSelector:@selector(accessTokenFail: withData:)];
	
	[request release];
	[oaConsumer release];
	
	// Start the fetch
	[self.fetcher start];
}

- (void) requestTokenSucceed: (OAServiceTicket *)ticket withData:(NSData *)data {
	
	NSLog(@"request token response");
	
	NSString *stringData = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	
	NSLog(@" %@", stringData);
	
	[parentDelegate performSelector: didFinishSelector
						 withObject: stringData];
}

// Construct a URL that will be used as the FT API url
- (NSURL *) fetchFTAPIURL: (NSString *)URLSuffix forRealm: (FTAPIRealm) realm {
	
	NSString *baseURL = [NSString stringWithFormat:@"%@%@", [self APIURIForRealm:realm], URLSuffix];
	
	// Convert the string into a NSURL
	NSURL *url = [NSURL URLWithString: [baseURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	
	NSLog(@"FT API URL: %@", baseURL);

	return url;
	
}

- (FTOAuthResult *) callSyncFTAPIWithURLSuffix:(NSString *)URLSuffix forRealm: (FTAPIRealm)realm withHTTPMethod:(HTTPMethod)method withData:(NSData *)data {

	return [self callSyncFTAPIWithURL:[self fetchFTAPIURL:URLSuffix forRealm: realm] 
						 forRealm:realm 
				   withHTTPMethod:method 
						 withData:data];
}

- (FTOAuthResult *) callSyncFTAPIWithURL:(NSURL *)url forRealm: (FTAPIRealm)realm withHTTPMethod:(HTTPMethod)method withData:(NSData *)data {
	// Create an OAConsumer object
	OAConsumer *oaConsumer = [[OAConsumer alloc] 
							  initWithKey:[self consumerKey] 
							  secret:[self consumerSecret]];
	
	// Create an OAToken to pass to the methods
	OAToken *oaToken = [[OAToken alloc]
						initWithKey:[[FTUserDefaults sharedInstance] accessToken] 
						secret:[[FTUserDefaults sharedInstance] accessTokenSecret]];
	
	
	OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:oaConsumer
                                                                      token:oaToken   
                                                                      realm:nil   
                                                          signatureProvider:nil];
	
	[oaConsumer release];
	
	[request setHTTPMethod:[self getHTTPMethodString:method]];
	[request setValue:@"application/xml" forHTTPHeaderField:@"Content-Type"];
	
	if (![data isKindOfClass:[NSNull class]]) {
		[request setHTTPBody:data];
	}
	
	// Fetch the data associated with the request
	
	OADataFetcher *syncFetcher = [[OADataFetcher alloc] init]; 
	
	
	[syncFetcher fetchDataWithRequest:request 
							 delegate:self 
					didFinishSelector:@selector(callSyncFTAPIDidFinish: withData:)
					  didFailSelector:@selector(callSyncFTAPIDidFail: withData:)];	
	
	// Release objects
	[oaToken release];
	[request release];
	[syncFetcher release];
	
	return [self.ftOAuthResult retain];
}

- (void) callFTAPIWithURLSuffix:(NSString *)URLSuffix forRealm: (FTAPIRealm)realm withHTTPMethod:(HTTPMethod)method withData:(NSData *)data {
	[self callFTAPIWithURL:[self fetchFTAPIURL:URLSuffix forRealm: realm] 
				  forRealm:realm 
			withHTTPMethod:method 
				  withData:data];
}

- (void) callFTAPIWithURL:(NSURL *)url forRealm: (FTAPIRealm)realm withHTTPMethod:(HTTPMethod)method withData:(NSData *)data {
	
	// access token and access token secret are needed for any request to the api. If these two things do not exist,
	// send something to the console explaining the need and return
	
	if ([[FTUserDefaults sharedInstance] accessToken] && [[FTUserDefaults sharedInstance] accessTokenSecret] && [[FTUserDefaults sharedInstance] churchCode]) {
	
		// Create an OAConsumer object
		OAConsumer *oaConsumer = [[[OAConsumer alloc] 
								   initWithKey:[self consumerKey] 
								   secret:[self consumerSecret]] autorelease];
		
		// Create an OAToken to pass to the methods
		OAToken *oaToken = [[OAToken alloc]
							initWithKey:[[FTUserDefaults sharedInstance] accessToken] 
							secret:[[FTUserDefaults sharedInstance] accessTokenSecret]];
		
		
		OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
																	   consumer:oaConsumer
																		  token:oaToken   
																		  realm:nil   
															  signatureProvider:nil];
		
		[request setHTTPMethod:[self getHTTPMethodString:method]];
		[request setValue:@"application/xml" forHTTPHeaderField:@"Content-Type"];
		
		if (![data isKindOfClass:[NSNull class]]) {
			[request setHTTPBody:data];
		}
		
		if (self.fetcher) {
			[self.fetcher release];
		}
		
		
		// Fetch the data associated with the request		
		self.fetcher = [[OAAsynchronousDataFetcher alloc] initWithRequest:request 
																 delegate:self 
														didFinishSelector:@selector(callFTAPIDidFinish: withData:) 
														  didFailSelector:@selector(callFTAPIDidFail: withData:)];	
		
		// Release objects
		[oaToken release];
		[request release];
		
		// Start the async fetcher
		[self.fetcher start];
	}
	else {
		[ConsoleLog LogMessage:@"Unable to connect to the fellowship one api because one of the required parameters are missing. One of the following has not been set: churchCode, accessToken, accessTokenSecret"];
	}
	
}

#pragma mark -
#pragma mark Private Category Methods
- (NSString *) getHTTPMethodString:(HTTPMethod)method {

	switch (method) {
		case (int)HTTPMethodGET:
			return @"GET";
			break;
		case (int)HTTPMethodPOST:
			return @"POST";
			break;
		case (int)HTTPMethodPUT:
			return @"PUT";
			break;
		default:
			return @"GET";
			break;
	}
}

- (NSString *) getAPIRealmString:(FTAPIRealm)realm {
	
	switch (realm) {
		case (int)FTAPIRealmBase:
			return @"";
			break;
		case (int)FTAPIRealmEvents:
			return @"Events/";
			break;
		case (int)FTAPIRealmGiving:
			return @"Giving/";
			break;
		case (int)FTAPIRealmGroups:
			return @"Groups/";
			break;
		default:
			return @"";
			break;
	}
}

- (void) authenticateUser:(NSString *)userName withPassword:(NSString *)password userType: (NSString *)userType {
    
    // Create an OAConsumer object
	OAConsumer *oaConsumer = [[OAConsumer alloc] 
							  initWithKey: [self consumerKey]
							  secret:[self consumerSecret]];
	
	// Authenticating the user in this scenario will require having the acess token url, get it now
	NSURL *accessTokenURL = [self fetchFTAPIURL:[NSString stringWithFormat:@"%@/AccessToken", userType] forRealm:FTAPIRealmBase];
    
	// Encode the username and password with 64 bit encoding
	NSMutableString *userCreds = [NSMutableString stringWithString:userName];
	[userCreds appendString:@" "];
	[userCreds appendString:password];
	
	// Encode the user name and password
	NSData *encodeData = [userCreds dataUsingEncoding:NSUTF8StringEncoding];
	char encodeArray[512];	
	memset(encodeArray, '\0', sizeof(encodeArray));
	
	// Base64 Encode username and password
	encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);
	userCreds = [NSString stringWithCString:encodeArray encoding:NSUTF8StringEncoding];
	NSString *encodedUserCreds = [NSString stringWithFormat:@"ec=%@", [userCreds stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    
	OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:accessTokenURL
                                                                   consumer:oaConsumer
                                                                      token:nil   // we don't have a Token yet
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA1
    // Set the request to a POST for access token
	[request setHTTPMethod:@"POST"];
	
	// Set the body to be the encoded username and password
	[request setHTTPBody: [encodedUserCreds dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
	[request setValue:@"application/xml" forHTTPHeaderField:@"Content-Type"]; 
	
    
	if (self.fetcher) {
		[self.fetcher release];
	}
	
	// Fetch the data associated with the request		
	self.fetcher = [[OAAsynchronousDataFetcher alloc] initWithRequest:request 
                                                             delegate:self 
                                                    didFinishSelector:@selector(accessTokenSucceed: withData:) 
                                                      didFailSelector:@selector(accessTokenFail: withData:)];
	
	// release the objects
	[request release];
	[oaConsumer release];
    
	// Start the fetch
	[self.fetcher start];
}

- (void) callFTAPIWithURL:(NSURL *)url withHTTPMethod:(HTTPMethod)method withData:(NSData *)data {
    
    // access token and access token secret are needed for any request to the api. If these two things do not exist,
	// send something to the console explaining the need and return
	
	if ([[FTUserDefaults sharedInstance] accessToken] && [[FTUserDefaults sharedInstance] accessTokenSecret] && [[FTUserDefaults sharedInstance] churchCode]) {
        
		// Create an OAConsumer object
		OAConsumer *oaConsumer = [[[OAConsumer alloc] 
								   initWithKey:[self consumerKey] 
								   secret:[self consumerSecret]] autorelease];
		
		// Create an OAToken to pass to the methods
		OAToken *oaToken = [[OAToken alloc]
							initWithKey:[[FTUserDefaults sharedInstance] accessToken] 
							secret:[[FTUserDefaults sharedInstance] accessTokenSecret]];
		
		
		OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
																	   consumer:oaConsumer
																		  token:oaToken   
																		  realm:nil   
															  signatureProvider:nil];
		
		[request setHTTPMethod:[self getHTTPMethodString:method]];
		[request setValue:@"application/xml" forHTTPHeaderField:@"Content-Type"];
		
		if (![data isKindOfClass:[NSNull class]]) {
			[request setHTTPBody:data];
		}
		
		if (self.fetcher) {
			[self.fetcher release];
		}
		
		// Fetch the data associated with the request		
		self.fetcher = [[OAAsynchronousDataFetcher alloc] initWithRequest:request 
																 delegate:self 
														didFinishSelector:@selector(callFTAPIDidFinish: withData:) 
														  didFailSelector:@selector(callFTAPIDidFail: withData:)];	
		
		// Release objects
		[oaToken release];
		[request release];
		
		// Start the async fetcher
		[self.fetcher start];
	}
	else {
		[ConsoleLog LogMessage:@"Unable to connect to the fellowship one api because one of the required parameters are missing. One of the following has not been set: churchCode, accessToken, accessTokenSecret"];
	}

}

#pragma mark Selector Methods
- (void) callSyncFTAPIDidFinish: (OAServiceTicket *)ticket withData:(NSData *)data {
	
	if (ticket.didSucceed) {
		
		if (!self.ftOAuthResult) {
			self.ftOAuthResult = [[[FTOAuthResult alloc] init] autorelease];
		}
		
		self.ftOAuthResult.isSucceed = YES;
		
		// Get the content type to determine how to return the response
		NSDictionary *responseHeaders = [(NSHTTPURLResponse *)[ticket response] allHeaderFields];
		
		// Look at the content type for the image
		NSString *contentType = [responseHeaders valueForKey:@"Content-Type"];
		
		if (![contentType isEqualToString:@"image/jpeg"]) {
			// Create new SBJSON parser object
			SBJSON *parser = [[SBJSON alloc] init];
			
			NSString *responseBody = [[[NSString alloc] initWithData:data
							encoding:NSUTF8StringEncoding] autorelease];
			
			// parse the JSON response into an object
			// {person:{}} -- Returns as an NSDictionary 
			NSDictionary *jsonData = [responseBody JSONValue];
			
			self.ftOAuthResult.returnData = jsonData;
			NSLog(@"HTTP OAuthResult Return Data: %@", self.ftOAuthResult.returnData);
			
			[parser release];
		}
		else {
			self.ftOAuthResult.returnImageData = data;
		}
	}
}

- (void) callFTAPIDidFail: (OAServiceTicket *)ticket withData:(NSData *)data {
	
	NSLog(@"fail");
	NSLog(@"fail data %@", data);
	// Write out the response headers
	NSLog(@"Fail Response Headers %@", [(NSHTTPURLResponse *)ticket.response allHeaderFields]);
	
	// Build a an FTOauthResult for the current object
	FTOAuthResult *oauthResult = [[FTOAuthResult alloc] init];
	
	oauthResult.isSucceed = NO;
	
	if ([self.delegate respondsToSelector:@selector(ftOauth: didComplete:)]) {
		// Call the did complete method on the protocol
		[[self delegate] ftOauth:self didComplete:oauthResult];
	}
    
    if (self.storedBlock) {
        self.storedBlock(oauthResult);
    }

	[oauthResult release];
}

- (void) callFTAPIDidFinish: (OAServiceTicket *)ticket withData:(NSData *)data {
	
	// Build a an FTOauthResult for the current object
	FTOAuthResult *oauthResult = [[[FTOAuthResult alloc] init] autorelease];
	
	NSString *dataString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	[dataString release];

	if (ticket.didSucceed) {

		oauthResult.isSucceed = YES;
		
		// Get the content type to determine how to return the response
		NSDictionary *responseHeaders = [(NSHTTPURLResponse *)[ticket response] allHeaderFields];
				
		// Look at the content type for the image
		NSString *contentType = [responseHeaders valueForKey:@"Content-Type"];
		
		if (![contentType isEqualToString:@"image/jpeg"]) {

			NSString *responseBody = [[NSString alloc] initWithData:data
					encoding:NSUTF8StringEncoding];
			
			// parse the JSON response into an object
			// {person:{}} -- Returns as an NSDictionary
			//NSDictionary *jsonData = [parser objectWithString:responseBody error:nil];
			oauthResult.returnData = [responseBody JSONValue];
		
			[responseBody release];
		}
		else {
			oauthResult.returnImageData = data;
		}
	}
	else {
		
		NSLog(@"fail");
		NSLog(@"fail data %@", data);
		// Write out the response headers
		NSLog(@"Fail Response Headers %@", [(NSHTTPURLResponse *)ticket.response allHeaderFields]);
	}
	
	if ([self.delegate respondsToSelector:@selector(ftOauth: didComplete:)]) {
		// Call the did complete method on the protocol
		[[self delegate] ftOauth:self didComplete:oauthResult];
	}
    
    if (self.storedBlock) {
        self.storedBlock(oauthResult);
    }
}

- (void) callSyncFTAPIDidFail: (OAServiceTicket *)ticket withData:(NSData *)data {
	
	NSLog(@"fail");
	
	// Write out the response headers
	NSLog(@"Fail Response Headers %@", [(NSHTTPURLResponse *)ticket.response allHeaderFields]);
	
	// Build a an FTOauthResult for the current object
	FTOAuthResult *oauthResult = [[FTOAuthResult alloc] init];
	
	oauthResult.isSucceed = NO;
	
	self.ftOAuthResult = oauthResult;
}

- (void) accessTokenSucceed: (OAServiceTicket *)ticket withData:(NSData *)data {
	
	NSLog(@"F1 API Access Token success message :: %@", data);
	
	// Build a an FTOauthResult for the current object
	FTOAuthResult *oauthResult = [[FTOAuthResult alloc] init];
	
	// Set the FTOauth succeed to the ticket succeed
	oauthResult.isSucceed = ticket.didSucceed;

	// If the authenticate was a success then find the My Info URL, 
	// store it and store the access token and secret
	if (ticket.didSucceed) {
		NSString *responseBody = [[NSString alloc] initWithData:data
							 encoding:NSUTF8StringEncoding];
		
		// Get the HTTPHeaders to find the Persons URL for "My Info"
		NSDictionary *responseHeaderDictionary = [NSDictionary dictionaryWithDictionary:[(NSHTTPURLResponse *)ticket.response allHeaderFields]];

		OAToken *accessTokenResponse = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
	
		// Assign the OAToken values to the NSUserDefaults
		[[FTUserDefaults sharedInstance] setAccessToken: [accessTokenResponse key]];
		[[FTUserDefaults sharedInstance] setAccessTokenSecret:[accessTokenResponse secret]];
		[[FTUserDefaults sharedInstance] setLoggedUserURI:[responseHeaderDictionary valueForKey:@"Content-Location"]];

		oauthResult.returnData = responseHeaderDictionary;
		
        if (didFinishSelector) {
            [parentDelegate performSelector: didFinishSelector
                                 withObject: responseBody];
		}
        
        // If called from blocks, call the block
        if (storedBlock) {
            self.storedBlock(responseHeaderDictionary);
        }
        
		// release objects no longer needed
		[responseBody release];
		[accessTokenResponse release];
        
	}
    else {
        
        if (didFinishSelector) {
            [parentDelegate performSelector: didFinishSelector
                                 withObject: nil];
        }
        
        // If called from blocks, call the block
        if (storedBlock) {
            self.storedBlock(nil);
        }
    }
	
	[oauthResult release];
}

- (void) accessTokenFail: (OAServiceTicket *)ticket withData:(NSError *)data {
	
	// Write out the response headers
	NSLog(@"Fail Response Headers %@", [(NSHTTPURLResponse *)ticket.response allHeaderFields]);	
	
	// Write out reason it failed
	NSLog(@"Error Message: %@", data);
	
	// Build a an FTOauthResult for the current object
	FTOAuthResult *oauthResult = [[FTOAuthResult alloc] init];
	
	// Set the FTOauth succeed to the ticket succeed
	oauthResult.isSucceed = ticket.didSucceed;
	

    if (didFailSelector) {
        [parentDelegate performSelector: didFailSelector
                             withObject: nil];
    }
    // If called from blocks, call the block
    if (storedBlock) {
        self.storedBlock(data);
    }
	
	[oauthResult release];
}


#pragma mark Properties -
// Return the consumer key from a plist
- (NSString *) consumerKey {
	return [FellowshipOneAPIUtility getValueFromPList:kApiPlistName withListKey:@"ConsumerKey"];	
}

// Return the consumer secret from a plist
- (NSString *) consumerSecret {
	return [FellowshipOneAPIUtility getValueFromPList:kApiPlistName withListKey:@"ConsumerSecret"];	
}

- (NSString *) apiVersionNumber {
	return [FellowshipOneAPIUtility getValueFromPList:kApiPlistName withListKey:@"APIVersionNumber"];	
}

- (NSString *) ftMinistryBaseURL {
	
	// Since this has become a library, the urls should be the same
	
	return [FellowshipOneAPIUtility getValueFromPList:kApiPlistName withListKey:@"BaseMinistryURL"];	
}

- (NSString *)APIURIForRealm: (FTAPIRealm)realm {
	
	// The parameters are as followed churchCode, API domain, realm, version
	NSMutableString *urlString = [NSMutableString stringWithFormat:[FellowshipOneAPIUtility getValueFromPList:kApiPlistName withListKey:@"APIDomain"], [[FTUserDefaults sharedInstance] churchCode]];
	[urlString appendFormat:@"%@", [self getAPIRealmString:realm]];
	[urlString appendFormat:@"%@/", [self apiVersionNumber]];
	
	[ConsoleLog LogMessage:[NSString stringWithFormat:@"F1 API URL %@", urlString]];
	
	return urlString;
	
}


- (void)dealloc {
	
	self.delegate = nil;
	[parentDelegate release];
	
	self.ftOAuthResult = nil;
	[ftOAuthResult release];
	
	_fetcher = nil;
	[_fetcher release];
    
    self.storedBlock = nil;
    [storedBlock release];
	[super dealloc];
}

	 

#pragma mark Base 64 encoding for credentials
static char base64[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
"abcdefghijklmnopqrstuvwxyz"
"0123456789"
"+/";

int encode(unsigned s_len, char *src, unsigned d_len, char *dst)
{
	unsigned triad;
	
	for (triad = 0; triad < s_len; triad += 3)
	{
		unsigned long int sr;
		unsigned byte;
		
		for (byte = 0; (byte<3)&&(triad+byte<s_len); ++byte)
		{
			sr <<= 8;
			sr |= (*(src+triad+byte) & 0xff);
		}
		
		sr <<= (6-((8*byte)%6))%6; /*shift left to next 6bit alignment*/
		
		if (d_len < 4) return 1; /* error - dest too short */
		
		*(dst+0) = *(dst+1) = *(dst+2) = *(dst+3) = '=';
		switch(byte)
		{
			case 3:
				*(dst+3) = base64[sr&0x3f];
				sr >>= 6;
			case 2:
				*(dst+2) = base64[sr&0x3f];
				sr >>= 6;
			case 1:
				*(dst+1) = base64[sr&0x3f];
				sr >>= 6;
				*(dst+0) = base64[sr&0x3f];
		}
		dst += 4; d_len -= 4;
	}
	
	return 0;
	
}
@end
