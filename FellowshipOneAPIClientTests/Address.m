//
//  Address.m
//  FellowshipOneAPIClient
//
//  Created by Chad Meyer on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Address.h"
#import "FOAddress.h"
#import "FOParentObject.h"
#import "FOParentNamedObject.h"
#import "FellowshipOneAPIClient.h"


@implementation Address

- (void)setUp {
    [FellowshipOneAPIClient createOAuthTicket:@"b019af55-6279-457e-b64d-4c74cb931253" withSecret:@"e6e78ee2-6b04-4420-9fb8-b84625c2e14d" forChurchCode:@"dc"];    
}

- (void)tearDown {
    // Tear-down code here.
    [super tearDown];
}

- (void) testGetAddressByPerson {
    
    NSArray *addresses = [FOAddress getByPersonID:8266692];
    STAssertTrue([addresses count] > 0, @"no addresses were returned,");
}

- (void) testGetAddressesByPersonWithCallBack {
    __block BOOL done= NO;
    int count = 0;
    
    // Testing using blocks for authentication
    
    [FOAddress getByPersonID:8266692 usingCallback:^(NSArray *results) {
        
        STAssertTrue([results count] > 0, @"no addresses returned.");
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


- (void) testGetAddressByID {
    
    FOAddress *address = [FOAddress getByID:6403168];
    STAssertNotNil(address, @"address was not found.");
}

- (void) testGetAddressByIDWithCallBack {
    __block BOOL done= NO;
    int count = 0;
    
    // Testing using blocks for authentication
    
    [FOAddress getByID:6403168 usingCallback:^(FOAddress *returnAddress) {
        
        STAssertNotNil(returnAddress, @"address was not found.");
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

- (void) testUpdateAddress {
    
    NSString *street1 = [NSString stringWithString:@"123 Test Rd"];
    
    
    FOAddress *address = [FOAddress getByID:6403168];
    
    if ([address.street1 isEqualToString:street1]) {
        street1 = [NSString stringWithString:@"125 Test Rd."];
    }

    [address setStreet1:street1];
    [address save];
    
    FOAddress *newAddress = [FOAddress getByID:6403168];
    STAssertTrue([newAddress.street1 isEqualToString:street1], @"address was not updated.");
}

- (void) testUpdateAddressWithCallBack {
    __block BOOL done= NO;
    int count = 0;
    
    NSString *street1 = [NSString stringWithString:@"123 Test Rd"];
    
    
    FOAddress *address = [FOAddress getByID:6403168];
    
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
    [savedAddress delete];
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
        
        // Delete the address
        [returnAddress delete];
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

- (void) testDeleteAddress {
    
    FOAddress *savedAddress = [self createAnAddress];
    [savedAddress save];
    [savedAddress delete];
    
    FOAddress *deletedAddress = [[FOAddress getByID:savedAddress.myId] retain];
    
    STAssertNil(deletedAddress, @"Address still exists.");
    
    [deletedAddress release];
}

- (void) testDeleteAddressWithCallBack {
    __block BOOL done= NO;
    int count = 0;
    
    FOAddress *savedAddress = [self createAnAddress];
    [savedAddress save];
    
    [savedAddress deleteUsingCallback:^(BOOL successful) {
        STAssertTrue(successful, @"address was not deleted.");
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
            STFail(@"Did not complete testDeleteAddressWithCallBack");
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

@end
