//
//  Communication.m
//  FellowshipOneAPIClient
//
//  Created by Chad Meyer on 7/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Communication.h"
#import "FOCommunication.h"
#import "FellowshipOneAPIClient.h"


@implementation Communication

- (void)setUp {
    [FellowshipOneAPIClient createOAuthTicket:@"b019af55-6279-457e-b64d-4c74cb931253" withSecret:@"e6e78ee2-6b04-4420-9fb8-b84625c2e14d" forChurchCode:@"dc"];    
}

- (void)tearDown {
    // Tear-down code here.
    [super tearDown];
}

- (void) testGetByPersonID {
    NSArray *communications = [FOCommunication getByPersonID:8266692];
    STAssertTrue([communications count] > 0, @"no communications returned.");
}


@end
