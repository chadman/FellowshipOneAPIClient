/*
 Copyright (C) 2010 Fellowship Technologies. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 * Neither the name of the author nor the names of its contributors may be used
 to endorse or promote products derived from this software without specific
 prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/**
 
 FellowshipOneAPIClient is a Cocoa Touch static library responsibile for constrcuting
 well formed signed OAuth requests to the Fellowship One API. The library promises to 
 eliminate the need to understand the inner workings of OAuth and signing to allow 
 developers to quickly get up and running building cocoa touch applications that
 integrate with the Fellowship One API
 
 For more information on OAUTH, please visit http://www.oauth.net
 
 For more information on the Fellowship One API, please visit http://developer.fellowshipone.com/docs/
 
*/

/* 
 
 inferface purpose: In order to use the fellowship one api, the first steps is to acquire an access token from the server
 The purpose here is to provide all methods necessary to logging into the API and gaining an access token along with providing
 some global methods
 
*/

#import <Foundation/Foundation.h>

@interface FellowshipOneAPIClient : NSObject

// Sets the church code that the fellowshipone api will be working with. It is very important to set this before accessing any api resource
+ (void) setChurchCode: (NSString *)churchCode;

// Returns the base url to the F1 API
+ (NSString *) apiDomainURL;

// Once an access token is successfully requested, the url of the logged in person will be populated
+ (NSString *) loggedUserURL;

/* Sets the access token and access token secret for future requests for the current session. It also ties the church code for all future calls 
   to the API This is useful for when the developer acquires an access token and secret through another means outside this library 
   @accessToken: The access token to be saved to the library
   @accessTokenSecret: The access token secret to be saved to the library
   @churchCode: The church code to be saved to the library																		*/
+ (void)createOAuthTicket: (NSString *)accessToken withSecret: (NSString *)accessTokenSecret forChurchCode: (NSString *)churchCode;

/* Requests an unauthorized request token / secret from the FellowshipOne API that can then be used to navigate to the F1 API login page 
   @churchCode: The church code that the unauthorized request token is for
   @aDelegate: The delegate attached to calling this method. This is the parent object that will be in charge of firing the delegate methods
   @aFinishSelector: The selector method that will be called when the call is complete
   @aFailSelector: The selector method that will be called if the call fails */
- (void)fetchRequestToken: (NSString *)churchCode delegate:(id)aDelegate finishSelector:(SEL)aFinishSelector failSelector: (SEL)aFailSelector;

/* Requests an access token from the FellowshipOne API this happens after a 
   request token has been requested and the user has logged in via 3rd Party OAUTH
   @churchCode: The church code that the unauthorized request token is for
   @aDelegate: The delegate attached to calling this method. This is the parent object that will be in charge of firing the delegate methods
   @aFinishSelector: The selector method that will be called when the call is complete
   @aFailSelector: The selector method that will be called if the call fails */
- (void)requestAccessToken: (NSString *)churchCode delegate:(id)aDelegate finishSelector:(SEL)aFinishSelector failSelector: (SEL)aFailSelector;

// Determines if there is an access token and secret in the user defaults. At this point there is no way to determine if it is valid
// It is recommended for now that if the method returns YES, to do an API call to determine if the access token is correct
+ (BOOL) hasAccessToken;

// Removes the stored information for the oauth ticket including accessToken and accessTokenSecret. This would be considered a "logout"
+ (void) removeOAuthTicket;


#if NS_BLOCKS_AVAILABLE

// Authenticates a portal user to get an access token and secret based on credentials. This is only available for 1st and 2nd party apps
// This is also only available for developers using the iPhone 4.0+ OS SDK
- (void)authenticatePortalUser: (NSString *)userName password: (NSString *)password usingBlock:(void (^)(id))block NS_AVAILABLE(10_6, 4_0);

// Authenticates a weblink user to get an access token and secret based on credentials. This is only available for 1st and 2nd party apps
// This is also only available for developers using the iPhone 4.0+ OS SDK
- (void)authenticateWeblinkUser: (NSString *)userName password: (NSString *)password usingBlock:(void (^)(id))block NS_AVAILABLE(10_6, 4_0);
#endif
@end
