//
//  FirstParty.m
//  FellowshipOneAPIClient
//
//  Created by Chad Meyer on 7/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FirstParty.h"
#import "FellowshipOneAPIClient.h"


@implementation FirstParty

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    // Tear-down code here.
    [super tearDown];
}


- (void)testAPIDomain {
    
    STAssertNotNil([FellowshipOneAPIClient apiDomainURL], @"cannot find the api base domain");
}

- (void) testSpecificAPIDomain {
    STAssertTrue([[FellowshipOneAPIClient apiDomainURL] isEqualToString:@"https://dc.fellowshiponeapi.com/v1/"], @"returned domain does not match.");
}

- (void) testPortalAuthentication {
    
    __block BOOL done= NO;
    
    // Testing using blocks for authentication
    FellowshipOneAPIClient *client = [[FellowshipOneAPIClient alloc] init];
    
    [client authenticatePortalUser:@"tcoulson" password:@"FT.Admin1" usingBlock:^(id block) {
        STAssertTrue([FellowshipOneAPIClient hasAccessToken], @"error while authenticating portal user.");
        done = YES;
    }];
    
    while (!done) {
        [self runLoop];
    }
    
    [client release];
}

- (void) testWeblinkAuthentication {
    __block BOOL done= NO;
    
    // Testing using blocks for authentication
    FellowshipOneAPIClient *client = [[FellowshipOneAPIClient alloc] init];
    
    [client authenticateWeblinkUser:@"cmeyer@fellowshiptech.com" password:@"Pa$$w0rd" usingBlock:^(id block) {
        STAssertTrue([FellowshipOneAPIClient hasAccessToken], @"Access token was still created.");
        done = YES;
    }];
    
    while (!done) {
        [self runLoop];
    }
    
    [client release];

}



@end
