//
//  Household.m
//  FellowshipOneAPIClient
//
//  Created by Chad Meyer on 7/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Household.h"
#import "FOHousehold.h"
#import "FOHouseholdQO.h"
#import "FellowshipOneAPIClient.h"
#import "FOPagedEntity.h"


@implementation Household

- (void)setUp {
    [FellowshipOneAPIClient createOAuthTicket:@"b019af55-6279-457e-b64d-4c74cb931253" withSecret:@"e6e78ee2-6b04-4420-9fb8-b84625c2e14d" forChurchCode:@"dc"];    
}

- (void)tearDown {
    // Tear-down code here.
    [super tearDown];
}

- (void) testGetHouseholdByID {
    
    FOHousehold *household = [FOHousehold getByID:6140909];
    STAssertNotNil(household, @"household was not returned.");
}

- (void) testGetHouseholdByIDWithCallBack {
    __block BOOL done= NO;
    int count = 0;
    
    // Testing using blocks for authentication
    [FOHousehold getByID:6140909 usingCallback:^(FOHousehold *returnHousehold) {
        STAssertNotNil(returnHousehold, @"household was not returned.");
        done = YES;
    }];

    
    while (!done) {
        
        if (count < 20) {
            count++;
            [self runLoop];
        }
        else {
            done = YES;
            STFail(@"Did not complete testGetAddressesByPersonWithCallBack");
        }
    }
}

- (void) testSearchForHouseholds {
    __block BOOL done= NO;
    int count = 0;
    
    FOHouseholdQO *qo = [[FOHouseholdQO alloc] init];
    [qo setSearchTerm:@"meyer"];
    [qo setPageNumber:1];
    [qo setRecordsPerPage:2];
    
    [FOHousehold searchForHouseholds:qo usingCallback:^(FOPagedEntity *returnedResult) {
        STAssertTrue([returnedResult.results count] == 2, @"records per page is wrong");
        done = YES;
    }];
    
    
    while (!done) {
        
        if (count < 20) {
            count++;
            [self runLoop];
        }
        else {
            done = YES;
            STFail(@"Did not complete testGetAddressesByPersonWithCallBack");
        }
    }

}


- (void) testUpdateHousehold {
    
    NSInteger oldID = 12345;
    
    
    FOHousehold *household = [FOHousehold getByID:6140909];
    
    if (household.myOldId == oldID) {
        oldID = 54321;
    }
    
    [household setMyOldId:oldID];
    [household save];
    
    FOHousehold *newHousehold = [FOHousehold getByID:6140909];
    STAssertTrue(newHousehold.myOldId == oldID, @"household was not updated.");
}

/*
- (void) testUpdateAddressWithCallBack {
    __block BOOL done= NO;
    int count = 0;
    
    NSString *street1 = [NSString stringWithString:@"123 Test Rd"];
    
    
    FOAddress *address = [FOAddress getByAddressID:6403168];
    
    if ([address.street1 isEqualToString:street1]) {
        street1 = [NSString stringWithString:@"125 Test Rd."];
    }
    
    
    [address setStreet1:street1];
    
    [address saveUsingCallback:^(FOAddress *returnAddress) {
        STAssertTrue([returnAddress.street1 isEqualToString:street1], @"address was not updated.");
        done = YES;
    }];
    
    while (!done) {
        
        if (count < 20) {
            count++;
            [self runLoop];
        }
        else {
            done = YES;
            STFail(@"Did not complete testUpdateAddressWithCallBack");
        }
    }
}

- (void) testCreateAddress {
    
    FOAddress *savedAddress = [self createAnAddress];
    [savedAddress save];
    
    STAssertTrue(savedAddress.myId > 0, @"address not created.");
    
    [savedAddress release];
}

- (void) testCreateAddressWithCallBack {
    __block BOOL done= NO;
    int count = 0;
    
    FOAddress *savedAddress = [self createAnAddress];
    
    [savedAddress saveUsingCallback:^(FOAddress *returnAddress) {
        STAssertTrue(returnAddress.myId > 0, @"address was not created.");
        done = YES;
        [savedAddress release];
    }];
    
    while (!done) {
        
        if (count < 20) {
            count++;
            [self runLoop];
        }
        else {
            done = YES;
            STFail(@"Did not complete testCreateAddressWithCallBack");
        }
    }
}

- (FOAddress *) createAnAddress {
    FOAddress *address = [[FOAddress alloc] init];
    
    address.street1 = @"500 Create Road";
    address.city = @"Dallas";
    address.state = @"TX";
    address.postalCode = @"75038";
    address.person = [[FOParentObject alloc] init];
    address.person.myId = 8266692;
    address.household = [[FOParentObject alloc] init];
    address.household.myId = 6140909;
    address.addressType = [[FOParentNamedObject alloc] init];
    address.addressType.myId = 7;
    address.country = @"USA";
    
    return address;
}
*/
@end
