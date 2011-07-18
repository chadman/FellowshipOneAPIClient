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

@implementation FellowshipOneAPIClient

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

	FTOAuth *ftoauth = [[FTOAuth alloc] initWithDelegate:self];
	
	[ftoauth fetchRequestToken:churchCode delegate:aDelegate finishSelector:aFinishSelector failSelector:aFailSelector];
}

- (void)requestAccessToken: (NSString *)churchCode delegate:(id)aDelegate finishSelector:(SEL)aFinishSelector failSelector: (SEL)aFailSelector {
	
	FTOAuth *ftoauth = [[FTOAuth alloc] initWithDelegate:self];
	[ftoauth requestAccessToken:churchCode delegate:aDelegate finishSelector:aFinishSelector failSelector:aFailSelector];
}

- (void) authenticateUser: (NSString *)userName withPassword: (NSString *)password withChurchCode: (NSString *)churchCode delegate: (id)aDelegate finishSelector: (SEL)aFinishSelector failSelector: (SEL)aFailSelector {	
	
	FTOAuth *ftoauth = [[FTOAuth alloc] initWithDelegate:self];
	
	[ftoauth authenticateUser:userName 
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

	FTOAuth *ftoauth = [[[FTOAuth alloc] initWithDelegate:self] autorelease];
    [ftoauth authenticatePortalUser:userName password:password usingBlock:block];
}

- (void)authenticateWeblinkUser: (NSString *)userName password: (NSString *)password usingBlock:(void (^)(id))block NS_AVAILABLE(10_6, 4_0) {
    
	FTOAuth *ftoauth = [[[FTOAuth alloc] initWithDelegate:self] autorelease];
    [ftoauth authenticateWeblinkUser:userName password:password usingBlock:block];
}
#endif

@end
