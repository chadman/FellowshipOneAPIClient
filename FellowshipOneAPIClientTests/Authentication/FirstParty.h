//
//  FirstParty.h
//  FellowshipOneAPIClient
//
//  Created by Chad Meyer on 7/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
//  See Also: http://developer.apple.com/iphone/library/documentation/Xcode/Conceptual/iphone_development/135-Unit_Testing_Applications/unit_testing_applications.html


#import <SenTestingKit/SenTestingKit.h>
#import <Foundation/Foundation.h>
#import "BaseTest.h"


@interface FirstParty : BaseTest {
    
}

// Tests whether or not an API Base Domain is returned
- (void)testAPIDomain;

// Tests if the API Base domain that is returned is what is supposed to be returned
- (void) testSpecificAPIDomain;

- (void) testPortalAuthentication;

- (void) testAuthenticationLoggedUserURL;

- (void) testWeblinkAuthentication;

- (void) testChurchCodeIsLowercase;

@end
