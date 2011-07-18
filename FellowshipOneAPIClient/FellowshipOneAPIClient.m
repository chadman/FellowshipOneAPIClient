//
//  FellowshipTechAPI.m
//  FellowshipTechAPI
//
//  Created by Meyer, Chad on 5/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FellowshipOneAPIClient.h"
#import "FOUserDefaults.h"
#import "ConsoleLog.h"
#import "FTOAuth.h"

@interface FellowshipOneAPIClient ()

@property (nonatomic, retain) FTOAuth *oauth;

@end

@implementation FellowshipOneAPIClient
@synthesize oauth;

- (id) init {
    
    self = [super init];
    
    if (self) {
        self.oauth = [[FTOAuth alloc] initWithDelegate:self];
    }
    
    return self;
}

+ (NSString *) apiDomainURL {

	FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
	
	NSString *tmpURL = [NSString stringWithFormat:@"%@", [oauth domainBaseURL]];
	
	[oauth	release];
	
	return tmpURL;
}

+ (NSString *) loggedUserURL {
    return [[FOUserDefaults sharedInstance] loggedUserURI];
}

+ (void) setChurchCode: (NSString *)churchCode {
    
    [[FOUserDefaults sharedInstance] setChurchCode:churchCode];
}

// Sets the access token and access token secret for future requests for the current session
+ (void)createOAuthTicket: (NSString *)accessToken withSecret: (NSString *)accessTokenSecret forChurchCode: (NSString *)churchCode {

	[[FOUserDefaults sharedInstance] setAccessToken:accessToken];
	[[FOUserDefaults sharedInstance] setAccessTokenSecret:accessTokenSecret];
	[[FOUserDefaults sharedInstance] setChurchCode:churchCode];
	
	[ConsoleLog LogMessage:@"OAuth Ticket successfully created."];
}

- (void)fetchRequestToken: (NSString *)churchCode delegate:(id)aDelegate finishSelector:(SEL)aFinishSelector failSelector: (SEL)aFailSelector {
	[oauth fetchRequestToken:churchCode delegate:aDelegate finishSelector:aFinishSelector failSelector:aFailSelector];
}

- (void)requestAccessToken: (NSString *)churchCode delegate:(id)aDelegate finishSelector:(SEL)aFinishSelector failSelector: (SEL)aFailSelector {
	[oauth requestAccessToken:churchCode delegate:aDelegate finishSelector:aFinishSelector failSelector:aFailSelector];
}

- (void) authenticateUser: (NSString *)userName withPassword: (NSString *)password withChurchCode: (NSString *)churchCode delegate: (id)aDelegate finishSelector: (SEL)aFinishSelector failSelector: (SEL)aFailSelector {	

	[oauth authenticateUser:userName 
				 withPassword:password
			   withChurchCode:churchCode 
					 delegate:aDelegate 
			   finishSelector:aFinishSelector 
				 failSelector:aFailSelector];
}

+ (BOOL) hasAccessToken {

	if ([[FOUserDefaults sharedInstance] accessToken] && [[FOUserDefaults sharedInstance] accessTokenSecret]) {
		return YES;
	}
	
	return NO;
}

+ (void) removeOAuthTicket {
	[FOUserDefaults killAllFTDefaults];
}

#if NS_BLOCKS_AVAILABLE
- (void)authenticatePortalUser: (NSString *)userName password: (NSString *)password usingBlock:(void (^)(id))block NS_AVAILABLE(10_6, 4_0) {
    [oauth authenticatePortalUser:userName password:password usingBlock:block];
}

- (void)authenticateWeblinkUser: (NSString *)userName password: (NSString *)password usingBlock:(void (^)(id))block NS_AVAILABLE(10_6, 4_0) {
    [oauth authenticateWeblinkUser:userName password:password usingBlock:block];
}
#endif

- (void) dealloc {
    [oauth release];
    [super dealloc];
}

@end
