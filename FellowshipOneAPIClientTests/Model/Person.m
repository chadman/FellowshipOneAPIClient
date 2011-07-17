//
//  FOPerson.m
//  FellowshipOneAPIClient
//
//  Created by Chad Meyer on 7/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Person.h"
#import "FOPerson.h"
#import "FellowshipOneAPIClient.h"
#import "PagedEntity.h"
#import "FOAddress.h"


@implementation Person

- (void)setUp {
    [FellowshipOneAPIClient createOAuthTicket:@"b019af55-6279-457e-b64d-4c74cb931253" withSecret:@"e6e78ee2-6b04-4420-9fb8-b84625c2e14d" forChurchCode:@"dc"];    
}

- (void)tearDown {
    // Tear-down code here.
    [super tearDown];
}


- (void) testGetById {
    __block BOOL done= NO;
    int count = 0;
    
    // Testing using blocks for authentication
    
    [FOPerson getByID:8266692 usingCallback:^(FOPerson *returnedPerson) {
       
        STAssertNotNil(returnedPerson, @"Getting person by id failed.");
        done = YES;

    }];

    while (!done) {
        
        if (count < 20) {
            count++;
            [self runLoop];
        }
        else {
            done = YES;
            STFail(@"Did not complete testGetById");
        }
    }
}

- (void) testSearchResults {
    __block BOOL done= NO;
    int count = 0;
    
    // Testing using blocks for authentication
    
    [FOPerson searchForPeople:@"sm" withSearchIncludes:nil withPage:1 usingCallback:^(PagedEntity *pagedResults) {
        STAssertTrue([pagedResults.results count] > 0, @"No results were returned.");
        done = YES;
    }];
    
    while (!done) {
        
        if (count < 20) {
            count++;
            [self runLoop];
        }
        else {
            done = YES;
            STFail(@"Did not complete testSearchResults");
        }
    }
}

- (void) testSearchNoResults {
    __block BOOL done= NO;
    int count = 0;
    
    // Testing using blocks for authentication
    
    [FOPerson searchForPeople:@"asdfasdfaasdf" withSearchIncludes:nil withPage:1 usingCallback:^(PagedEntity *pagedResults) {
        STAssertTrue([pagedResults.results count] == 0, @"results were returned.");
        done = YES;
    }];
    
    while (!done) {
        
        if (count < 20) {
            count++;
            [self runLoop];
        }
        else {
            done = YES;
            STFail(@"Did not complete testSearchNoResults");
        }
    }
}

- (void) testSearchIncludeAddress {
    __block BOOL done= NO;
    __block BOOL foundAddress = NO;
    int count = 0;
    
    NSArray *includes = [[NSArray alloc] initWithObjects:[FOPerson getSearchIncludeString:PeopleSearchIncludeAddresses], nil];

    
    [FOPerson searchForPeople:@"meyer,chad" withSearchIncludes:includes withPage:1 usingCallback:^(PagedEntity *pagedResults) {
        
        // Looks through the results and look for addresses
        for (FOPerson *currentPerson in pagedResults.results) {
            
            if (currentPerson.addresses && [currentPerson.addresses count] > 0) {
                foundAddress = YES;
                break;
            }
        }
        done = YES;
    }];
    
    while (!done) {
        
        if (count < 20) {
            count++;
            [self runLoop];
        }
        else {
            done = YES;
            STFail(@"Did not complete testSearchIncludeAddress");
        }
    }
    
    [includes release];
    
    STAssertTrue(foundAddress, @"No addresses were found.");
}

- (void) testSearchIncludeCommunication {
    
    __block BOOL done= NO;
    __block BOOL foundCommunications = NO;
    int count = 0;
    
    NSArray *includes = [[NSArray alloc] initWithObjects:[FOPerson getSearchIncludeString:PeopleSearchIncludeCommunications], nil];
    
    
    [FOPerson searchForPeople:@"meyer,chad" withSearchIncludes:includes withPage:1 usingCallback:^(PagedEntity *pagedResults) {
        
        // Looks through the results and look for addresses
        for (FOPerson *currentPerson in pagedResults.results) {
            
            if (currentPerson.communications && [currentPerson.communications count] > 0) {
                foundCommunications = YES;
                break;
            }
        }
        done = YES;
    }];
    
    while (!done) {
        
        if (count < 20) {
            count++;
            [self runLoop];
        }
        else {
            done = YES;
            STFail(@"Did not complete testSearchIncludeCommunication");
        }
    }
    
    [includes release];
    
    STAssertTrue(foundCommunications, @"No communications were found.");
}

- (void) testSearchIncludeAttributes {
    
    
    /*
     __block BOOL done= NO;
     int count = 0;
    NSMutableArray *includes = [[NSMutableArray alloc] initWithObjects:nil];
    [includes addObject:(id)PeopleSearchIncludeAttributes];
    
    
    [FOPerson searchForPeople:@"meyer" withSearchIncludes:includes withPage:1 usingCallback:^(PagedEntity *pagedResults) {
        STAssertTrue([pagedResults.results count] == 0, @"results were returned.");
        done = YES;
    }];
    
    while (!done) {
        
        if (count < 20) {
            count++;
            [self runLoop];
        }
        else {
            done = YES;
            STFail(@"Did not complete testSearchNoResults");
        }
    }
    
    [includes release];
    
    */
}

- (void) testGetImage {
    __block BOOL done= NO;
    int count = 0;
    
    // Testing using blocks for authentication
    
    [FOPerson getImageData:8266692 withSize:@"M" usingCallback:^(NSData *returnedImage) {
        
        STAssertNotNil(returnedImage, @"Getting image by person id failed.");
        done = YES;
        
    }];
    
    while (!done) {
        
        if (count < 20) {
            count++;
            [self runLoop];
        }
        else {
            done = YES;
            STFail(@"Did not complete testGetImage");
        }
    }
}

@end
