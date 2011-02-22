//
//  FTOAuth.h
//  Fellowship
//
//  Created by Chad Meyer on 4/29/09.
//  Copyright 2009 Fellowship Tech. All rights reserved.
//

#import "FTOAuthResult.h"
#import "Enum.h"

@protocol FTOAuthDelegate;

@interface FTOAuth : NSObject {
	
	id<FTOAuthDelegate>		parentDelegate;
	FTOAuthResult			*ftOAuthResult;
	NSString				*consumerKey;
	NSString				*consumerSecret;
	NSString				*apiVersionNumber;
	NSString				*ftMinistryBaseURL;
	SEL				didFinishSelector;
	SEL				didFailSelector;
	id _fetcher;
}

@property (nonatomic, assign) id<FTOAuthDelegate> delegate;
@property (readwrite, nonatomic, retain) FTOAuthResult *ftOAuthResult;
@property (readonly) NSString *consumerKey;
@property (readonly) NSString *consumerSecret;
@property (readonly) NSString *apiVersionNumber;
@property (readonly) NSString *ftMinistryBaseURL;
@property (nonatomic, retain) id fetcher;
@property (nonatomic, assign, readonly) NSString *domainBaseURL;

- (id) initWithDelegate: (id)delegate;
- (void) authenticateUser: (NSString *)userName withPassword: (NSString *)password withChurchCode: (NSString *)churchCode delegate: (id)aDelegate finishSelector: (SEL)aFinishSelector failSelector: (SEL)aFailSelector;
- (void) fetchRequestToken: (NSString *)churchCode delegate: (id)aDelegate finishSelector: (SEL)aFinishSelector failSelector: (SEL)aFailSelector;
- (void) requestAccessToken: (NSString *)churchCode delegate: (id)aDelegate finishSelector: (SEL)aFinishSelector failSelector: (SEL)aFailSelector;

#if NS_BLOCKS_AVAILABLE
- (void)authenticateUser: (NSString *)userName password: (NSString *)password church: (NSString *)churchCode usingBlock:(void (^)(NSString *))block NS_AVAILABLE(10_6, 4_0);
#endif

// Calls the F1 API 
// The URL suffix is the part of the url after the domain
// the realm is the which section of the API is the call for, currently there is PEOPLE and MINISTRY
// The HTTPMethod describes how to send the request, view HTTPMethod.h under Enums for a list
// The data is what needs to be sent as the body of the request
- (void) callFTAPIWithURLSuffix:(NSString *)URLSuffix forRealm: (FTAPIRealm)realm withHTTPMethod:(HTTPMethod)method withData:(NSData *)data;
- (void) callFTAPIWithURL:(NSURL *)url forRealm: (FTAPIRealm)realm withHTTPMethod:(HTTPMethod)method withData:(NSData *)data;

- (FTOAuthResult *) callSyncFTAPIWithURLSuffix:(NSString *)URLSuffix forRealm: (FTAPIRealm)realm withHTTPMethod:(HTTPMethod)method withData:(NSData *)data;
- (FTOAuthResult *) callSyncFTAPIWithURL:(NSURL *)url forRealm: (FTAPIRealm)realm withHTTPMethod:(HTTPMethod)method withData:(NSData *)data;


@end

@protocol FTOAuthDelegate<NSObject>

- (void) ftOauth: (FTOAuth *)ftOAuth didComplete: (FTOAuthResult *) result;

@end

